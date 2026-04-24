package com.hospital.exchange.service;

import com.hospital.exchange.dto.HospitalResourceSummaryDTO;
import com.hospital.exchange.entity.AuditLog;
import com.hospital.exchange.entity.Hospital;
import com.hospital.exchange.entity.Resource;
import com.hospital.exchange.exception.ForbiddenOperationException;
import com.hospital.exchange.exception.ResourceNotFoundException;
import com.hospital.exchange.repository.AuditLogRepository;
import com.hospital.exchange.repository.ResourceRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
public class ResourceService {
    private final ResourceRepository resourceRepository;
    private final NotificationService notificationService;
    private final AuditLogRepository auditLogRepository;

    public ResourceService(ResourceRepository resourceRepository, 
                          NotificationService notificationService, 
                          AuditLogRepository auditLogRepository) {
        this.resourceRepository = resourceRepository;
        this.notificationService = notificationService;
        this.auditLogRepository = auditLogRepository;
    }

    public List<Resource> getAllResources() {
        return resourceRepository.findAll();
    }

    public List<Resource> getResourcesByHospital(Long hospitalId) {
        return resourceRepository.findByHospitalId(hospitalId);
    }

    public Resource getResourceById(Long id) {
        return resourceRepository.findById(id).orElseThrow(() -> new ResourceNotFoundException("Resource " + id + " was not found."));
    }

    @Transactional
    public Resource saveResource(Resource resource) {
        Resource saved = resourceRepository.save(resource);
        notificationService.notifyResourceUpdate(saved.getId(), saved.getStatus().name());
        return saved;
    }

    @Transactional
    public Resource updateResource(Long id, Resource updatedResource) {
        Resource existing = getResourceById(id);
        existing.setResourceName(updatedResource.getResourceName());
        existing.setType(updatedResource.getType());
        existing.setStatus(updatedResource.getStatus());
        Resource saved = resourceRepository.save(existing);
        logAudit("RESOURCE_UPDATED", "Updated resource " + saved.getResourceName(), "System", saved.getHospital());
        return saved;
    }

    @Transactional
    public void deleteResource(Long id) {
        Resource resource = getResourceById(id);
        if (resource.getStatus() != Resource.ResourceStatus.AVAILABLE) {
            throw new ForbiddenOperationException("Cannot delete a resource that is currently " + resource.getStatus() + ".");
        }
        resourceRepository.delete(resource);
        logAudit("RESOURCE_DELETED", "Deleted resource " + resource.getResourceName(), "System", resource.getHospital());
    }

    /**
     * Optimized aggregation of resources for a specific hospital.
     */
    public HospitalResourceSummaryDTO getHospitalResourceSummary(Long hospitalId) {
        List<Resource> resources = getResourcesByHospital(hospitalId);
        
        int icuT = 0, icuA = 0;
        int ventT = 0, ventA = 0;
        int ambT = 0, ambA = 0;
        int specT = 0, specA = 0;

        for (Resource r : resources) {
            boolean avail = r.getStatus() == Resource.ResourceStatus.AVAILABLE;
            switch (r.getType()) {
                case ICU_BED:      icuT++; if (avail) icuA++; break;
                case VENTILATOR:   ventT++; if (avail) ventA++; break;
                case AMBULANCE:    ambT++; if (avail) ambA++; break;
                case SPECIALIST:   specT++; if (avail) specA++; break;
            }
        }

        return HospitalResourceSummaryDTO.calculate(icuT, icuA, ventT, ventA, ambT, ambA, specT, specA);
    }

    private void logAudit(String action, String details, String user, Hospital hospital) {
        AuditLog log = AuditLog.builder()
                .action(action)
                .details(details)
                .performedBy(user)
                .hospital(hospital)
                .timestamp(java.time.LocalDateTime.now())
                .build();
        auditLogRepository.save(log);
    }
}
