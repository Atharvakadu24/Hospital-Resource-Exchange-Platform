package com.hospital.exchange.controller;

import com.hospital.exchange.entity.AllocationRequest;
import com.hospital.exchange.entity.Hospital;
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
        return "request_list";
    }

    @GetMapping("/new")
    @PreAuthorize("hasAuthority('HOSPITAL_ADMIN')")
    public String showRequestPanel(@RequestParam Long resourceId, Model model) {
        Hospital current = securityUtils.getCurrentHospital();
        model.addAttribute("targetResource", resourceService.getResourceById(resourceId));
        model.addAttribute("currentQuotaLoad", allocationService.getQuotaLoadPercent(current));
        return "request_panel";
    }

    @PostMapping("/new")
    @PreAuthorize("hasAuthority('HOSPITAL_ADMIN')")
    public String createRequest(@ModelAttribute AllocationRequest request, @RequestParam Long resourceId) {
        Hospital current = securityUtils.getCurrentHospital();
        // Logical connection: Resource type is implicitly derived from targetResource
        allocationService.createRequest(current, resourceService.getResourceById(resourceId).getType(), 
                                      request.getPriority(), request.getStartTime(), request.getEndTime());
        return "redirect:/requests";
    }

    @PostMapping("/cancel/{id}")
    @PreAuthorize("hasAnyAuthority('ADMIN', 'HOSPITAL_ADMIN')")
    public String cancelRequest(@PathVariable Long id) {
        // Ownership check for HOSPITAL_ADMIN
        if (securityUtils.isHospitalAdmin()) {
            AllocationRequest request = allocationService.getRequestById(id); // Need to add this to service
            if (request == null || !request.getRequesterHospital().getId().equals(securityUtils.getCurrentHospital().getId())) {
                return "redirect:/error/403";
            }
        }
        
        allocationService.cancelRequest(id);
        return "redirect:/requests";
    }
}
