package com.hospital.exchange.controller;

import com.hospital.exchange.entity.AllocationRequest;
import com.hospital.exchange.entity.Hospital;
import com.hospital.exchange.entity.Resource;
import com.hospital.exchange.exception.ForbiddenOperationException;
import com.hospital.exchange.service.HospitalService;
import com.hospital.exchange.service.ResourceService;
import com.hospital.exchange.service.ResourceAllocationService;
import com.hospital.exchange.util.SecurityUtils;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

/**
 * Controller for medical resource request management.
 * Handles the creation, tracking, and cancellation of allocation requests.
 */
@Controller
@RequestMapping("/requests")
public class RequestController {

    private final ResourceAllocationService allocationService;
    private final ResourceService resourceService;
    private final HospitalService hospitalService;
    private final SecurityUtils securityUtils;

    public RequestController(ResourceAllocationService allocationService, ResourceService resourceService, 
                            HospitalService hospitalService, SecurityUtils securityUtils) {
        this.allocationService = allocationService;
        this.resourceService = resourceService;
        this.hospitalService = hospitalService;
        this.securityUtils = securityUtils;
    }

    /**
     * Lists all requests for the platform admin or specific hospital admin.
     */
    @GetMapping
    public String listRequests(Model model) {
        if (securityUtils.isAdmin()) {
            model.addAttribute("requests", allocationService.getAllRequests());
        } else {
            Hospital current = securityUtils.getCurrentHospital();
            model.addAttribute("requests", allocationService.getRequestsByHospital(current.getId()));
        }
        model.addAttribute("isAdmin", securityUtils.isAdmin());
        model.addAttribute("currentHospitalId", securityUtils.getCurrentHospital() != null ? securityUtils.getCurrentHospital().getId() : null);
        return "request_list";
    }

    @GetMapping("/new")
    @PreAuthorize("hasAnyAuthority('ADMIN', 'HOSPITAL_ADMIN')")
    public String showRequestPanel(@RequestParam Long resourceId, Model model) {
        Resource targetResource = resourceService.getResourceById(resourceId);
        Hospital requesterHospital = resolveRequesterHospital(null);
        if (requesterHospital != null && targetResource.getHospital().getId().equals(requesterHospital.getId())) {
            throw new ForbiddenOperationException("Your hospital cannot request its own resource.");
        }

        model.addAttribute("targetResource", targetResource);
        model.addAttribute("currentQuotaLoad", requesterHospital != null ? allocationService.getQuotaLoadPercent(requesterHospital) : 0);
        model.addAttribute("requesterHospital", requesterHospital);
        model.addAttribute("requesterHospitals", hospitalService.getAllHospitals());
        model.addAttribute("isAdmin", securityUtils.isAdmin());
        return "request_panel";
    }

    @PostMapping("/new")
    @PreAuthorize("hasAnyAuthority('ADMIN', 'HOSPITAL_ADMIN')")
    public String createRequest(@ModelAttribute AllocationRequest request, @RequestParam Long resourceId,
                                @RequestParam(required = false) Integer durationHours,
                                @RequestParam(required = false) Long requesterHospitalId) {
        Hospital requesterHospital = resolveRequesterHospital(requesterHospitalId);
        Resource targetResource = resourceService.getResourceById(resourceId);
        if (requesterHospital == null) {
            return "redirect:/login";
        }
        if (targetResource.getHospital().getId().equals(requesterHospital.getId())) {
            throw new ForbiddenOperationException("Your hospital cannot request its own resource.");
        }

        if (request.getStartTime() == null) {
            throw new IllegalArgumentException("Start time is required.");
        }
        if (request.getEndTime() == null && durationHours != null && durationHours > 0) {
            request.setEndTime(request.getStartTime().plusHours(durationHours));
        }
        if (request.getEndTime() == null || !request.getEndTime().isAfter(request.getStartTime())) {
            throw new IllegalArgumentException("End time must be after start time.");
        }

        // Logical connection: Resource type is implicitly derived from targetResource
        allocationService.createRequest(requesterHospital, targetResource.getType(),
                                      request.getPriority(), request.getStartTime(), request.getEndTime());
        return "redirect:/requests";
    }

    private Hospital resolveRequesterHospital(Long requesterHospitalId) {
        if (securityUtils.isAdmin()) {
            if (requesterHospitalId == null) {
                return null;
            }
            return hospitalService.getHospitalById(requesterHospitalId);
        }
        return securityUtils.getCurrentHospital();
    }

    @PostMapping("/cancel/{id}")
    @PreAuthorize("hasAnyAuthority('ADMIN', 'HOSPITAL_ADMIN')")
    public String cancelRequest(@PathVariable Long id) {
        // Ownership check for HOSPITAL_ADMIN
        if (securityUtils.isHospitalAdmin()) {
            AllocationRequest request = allocationService.getRequestById(id);
            if (request == null || !request.getRequesterHospital().getId().equals(securityUtils.getCurrentHospital().getId())) {
                throw new ForbiddenOperationException("You can cancel only your hospital's own requests.");
            }
        }
        
        allocationService.cancelRequest(id);
        return "redirect:/requests";
    }

    @PostMapping("/allocate/{id}")
    @PreAuthorize("hasAuthority('ADMIN')")
    public String allocateRequest(@PathVariable Long id) {
        allocationService.allocateRequest(id);
        return "redirect:/requests";
    }
}
