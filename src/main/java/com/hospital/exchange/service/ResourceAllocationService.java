package com.hospital.exchange.service;

import com.hospital.exchange.entity.*;
import com.hospital.exchange.model.ResourceType;
import com.hospital.exchange.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;

/**
 * Core Service for managing medical resource allocations between hospitals.
 * Handles request lifecycle, queuing, priority-based allocation, and deadlock prevention.
 */
@Service
public class ResourceAllocationService {

    private final AllocationRequestRepository requestRepository;
    private final ResourceRepository resourceRepository;
    private final BookingRepository bookingRepository;
    private final DeadlockDetectionService deadlockDetectionService;
    private final AuditLogRepository auditLogRepository;
    private final NotificationService notificationService;

    public ResourceAllocationService(
            AllocationRequestRepository requestRepository,
            ResourceRepository resourceRepository,
            BookingRepository bookingRepository,
            DeadlockDetectionService deadlockDetectionService,
            AuditLogRepository auditLogRepository,
            NotificationService notificationService) {
        this.requestRepository = requestRepository;
        this.resourceRepository = resourceRepository;
        this.bookingRepository = bookingRepository;
        this.deadlockDetectionService = deadlockDetectionService;
        this.auditLogRepository = auditLogRepository;
        this.notificationService = notificationService;
    }

    /**
     * Creates a new resource allocation request and attempts immediate fulfillment.
     * If resources are busy, it performs deadlock checking and queues the request.
     */
    @Transactional
    public AllocationRequest createRequest(Hospital requester, ResourceType type, 
                                          AllocationRequest.RequestPriority priority, 
                                          LocalDateTime startTime, LocalDateTime endTime) {
        
        AllocationRequest request = AllocationRequest.builder()
                .requesterHospital(requester)
                .resourceType(type)
                .priority(priority)
                .status(AllocationRequest.RequestStatus.PENDING)
                .requestedAt(LocalDateTime.now())
                .startTime(startTime)
                .endTime(endTime)
                .build();

        request = requestRepository.save(request);
        notificationService.notifyNewRequest(request.getId(), requester.getName(), type.name());

        // Try immediate allocation
        boolean allocated = attemptAllocation(request);
        
        if (!allocated) {
            // Check for deadlock if we were to wait
            List<Resource> busyResources = resourceRepository.findByTypeAndStatusIn(
                    type,
                    List.of(Resource.ResourceStatus.RESERVED, Resource.ResourceStatus.IN_USE)
            );
            
            boolean potentialDeadlock = false;
            for (Resource r : busyResources) {
                if (deadlockDetectionService.wouldCreateDeadlock(requester.getId(), r.getHospital().getId())) {
                    potentialDeadlock = true;
                    break;
                }
            }

            if (potentialDeadlock) {
                request.setStatus(AllocationRequest.RequestStatus.REJECTED_DEADLOCK);
                logAudit("DEADLOCK_PREVENTION_REJECT", "Request rejected to prevent circular dependency cycle", "System", requester, request);
            } else {
                busyResources.stream()
                        .map(Resource::getHospital)
                        .filter(Objects::nonNull)
                        .map(Hospital::getId)
                        .filter(holdingHospitalId -> !holdingHospitalId.equals(requester.getId()))
                        .forEach(holdingHospitalId -> deadlockDetectionService.addDependency(requester.getId(), holdingHospitalId));
                request.setStatus(AllocationRequest.RequestStatus.WAITING);
                logAudit("REQUEST_QUEUED", "Resource type " + type + " busy. Added to priority queue.", "System", requester, request);
            }
        }

        return requestRepository.save(request);
    }

    @Transactional
    public synchronized boolean attemptAllocation(AllocationRequest request) {
        // Strict Quota Check FIRST
        long currentLoad = getCurrentLoad(request.getRequesterHospital());

        if (currentLoad >= request.getRequesterHospital().getResourceQuota()) {
            logAudit("QUOTA_EXCEEDED", "Hospital limit reached: " + currentLoad, "System", request.getRequesterHospital(), request);
            return false;
        }

        List<Resource> availableResources = resourceRepository.findByTypeAndStatus(request.getResourceType(), Resource.ResourceStatus.AVAILABLE)
                .stream()
                .filter(resource -> !resource.getHospital().getId().equals(request.getRequesterHospital().getId()))
                .toList();
        
        if (availableResources.isEmpty()) return false;

        // --- SMART ALLOCATION: Pick the Nearest Hospital ---
        Hospital requester = request.getRequesterHospital();
        Resource bestResource = availableResources.stream()
                .min(Comparator.comparingDouble(res -> calculateDistance(
                        requester.getLatitude(), requester.getLongitude(),
                        res.getHospital().getLatitude(), res.getHospital().getLongitude())))
                .orElse(availableResources.get(0));

        bestResource.setStatus(Resource.ResourceStatus.RESERVED);
        resourceRepository.save(bestResource);

        Booking booking = Booking.builder()
                .request(request)
                .resource(bestResource)
                .confirmedAt(LocalDateTime.now())
                .releaseAt(request.getEndTime())
                .released(false)
                .build();
        
        bookingRepository.save(booking);
        
        request.setStatus(AllocationRequest.RequestStatus.APPROVED);
        deadlockDetectionService.clearAllDependencies(requester.getId()); // CLEANUP dependency graph

        logAudit("RESOURCE_ALLOCATED", "Successfully allocated " + bestResource.getResourceName() + " to " + requester.getName(), "System", requester, request);
        notificationService.notifyAllocationComplete(booking.getId(), requester.getName(), bestResource.getResourceName());
        
        return true;
    }

    private double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        if (lat1 == 0 || lon1 == 0 || lat2 == 0 || lon2 == 0) return Double.MAX_VALUE;
        double R = 6371; // Earth radius in KM
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                   Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                   Math.sin(dLon / 2) * Math.sin(dLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }

    /**
     * Re-processes the waiting requests in strict priority + FIFO order.
     * Triggered whenever a resource is released.
     */
    @Transactional
    public void processWaitingRequests() {
        List<AllocationRequest> waitingRequests = requestRepository.findByStatusOrderByPriorityDescRequestedAtAsc(AllocationRequest.RequestStatus.WAITING);

        for (AllocationRequest req : waitingRequests) {
            if (attemptAllocation(req)) {
                requestRepository.save(req);
            }
        }
    }

    @Transactional
    public void cancelRequest(Long requestId) {
        AllocationRequest request = requestRepository.findById(requestId).orElse(null);
        if (request != null && (request.getStatus() == AllocationRequest.RequestStatus.PENDING || 
                               request.getStatus() == AllocationRequest.RequestStatus.WAITING)) {
            request.setStatus(AllocationRequest.RequestStatus.CANCELLED);
            requestRepository.save(request);
            deadlockDetectionService.clearAllDependencies(request.getRequesterHospital().getId());
            logAudit("REQUEST_CANCELLED", "Request cancelled by user", "User", request.getRequesterHospital(), request);
        }
    }

    private void logAudit(String action, String details, String user, Hospital hospital, AllocationRequest request) {
        AuditLog log = AuditLog.builder()
                .action(action)
                .details(details + (request != null ? " [Request# " + request.getId() + "]" : ""))
                .performedBy(user)
                .hospital(hospital)
                .timestamp(LocalDateTime.now())
                .build();
        auditLogRepository.save(log);
    }

    public List<AllocationRequest> getAllRequests() {
        return requestRepository.findAll();
    }

    public List<AllocationRequest> getRequestsByHospital(Long hospitalId) {
        return requestRepository.findByRequesterHospitalId(hospitalId);
    }

    public AllocationRequest getRequestById(Long requestId) {
        return requestRepository.findById(requestId).orElse(null);
    }

    public List<AllocationRequest> getWaitingRequests() {
        return requestRepository.findByStatusOrderByPriorityDescRequestedAtAsc(AllocationRequest.RequestStatus.WAITING);
    }

    @Transactional
    public boolean allocateRequest(Long requestId) {
        AllocationRequest request = getRequestById(requestId);
        if (request == null) {
            return false;
        }
        if (request.getStatus() != AllocationRequest.RequestStatus.PENDING
                && request.getStatus() != AllocationRequest.RequestStatus.WAITING) {
            return false;
        }
        return attemptAllocation(request);
    }

    public Map<Long, Set<Long>> getActiveDependencies() {
        return deadlockDetectionService.getWaitForGraph(); // Need to expose this in deadlock service
    }

    public int getQuotaLoadPercent(Hospital hospital) {
        long currentLoad = getCurrentLoad(hospital);
        int quota = hospital.getResourceQuota();
        if (quota == 0) return 0;
        return (int) ((currentLoad * 100) / quota);
    }

    private long getCurrentLoad(Hospital hospital) {
        return bookingRepository.countByRequestRequesterHospitalIdAndReleasedFalse(hospital.getId());
    }
}
