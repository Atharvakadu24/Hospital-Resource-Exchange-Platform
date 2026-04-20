package com.hospital.exchange.service;

import com.hospital.exchange.entity.Booking;
import com.hospital.exchange.entity.Resource;
import com.hospital.exchange.repository.BookingRepository;
import com.hospital.exchange.repository.ResourceRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class AutoReleaseScheduler {

    private static final Logger log = LoggerFactory.getLogger(AutoReleaseScheduler.class);

    private final BookingRepository bookingRepository;
    private final ResourceRepository resourceRepository;
    private final ResourceAllocationService allocationService;
    private final DeadlockDetectionService deadlockDetectionService;
    private final NotificationService notificationService;

    public AutoReleaseScheduler(
            BookingRepository bookingRepository,
            ResourceRepository resourceRepository,
            ResourceAllocationService allocationService,
            DeadlockDetectionService deadlockDetectionService,
            NotificationService notificationService) {
        this.bookingRepository = bookingRepository;
        this.resourceRepository = resourceRepository;
        this.allocationService = allocationService;
        this.deadlockDetectionService = deadlockDetectionService;
        this.notificationService = notificationService;
    }

    /**
     * Runs every minute to check for expired bookings.
     */
    @Scheduled(fixedRate = 60000)
    @Transactional
    public void releaseExpiredResources() {
        log.debug("Checking for expired resource bookings...");
        List<Booking> expiredBookings = bookingRepository.findByReleasedFalseAndReleaseAtBefore(LocalDateTime.now());

        for (Booking booking : expiredBookings) {
            Resource resource = booking.getResource();
            log.info("Releasing resource {} from request {}", resource.getResourceName(), booking.getRequest().getId());

            // 1. Mark resource as available
            resource.setStatus(Resource.ResourceStatus.AVAILABLE);
            resourceRepository.save(resource);
            notificationService.notifyResourceUpdate(resource.getId(), "AVAILABLE");

            // 2. Mark booking as released
            booking.setReleased(true);
            bookingRepository.save(booking);
        }

        if (!expiredBookings.isEmpty()) {
            // 4. Try to re-allocate released resources to next in queue
            allocationService.processWaitingRequests();
        }
    }
}
