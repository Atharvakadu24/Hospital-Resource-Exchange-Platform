package com.hospital.exchange.controller;

import com.hospital.exchange.entity.Hospital;
import com.hospital.exchange.entity.Resource;
import com.hospital.exchange.service.ResourceService;
import com.hospital.exchange.service.ResourceAllocationService;
import com.hospital.exchange.util.SecurityUtils;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/hospital-admin")
@PreAuthorize("hasAuthority('HOSPITAL_ADMIN')")
public class HospitalAdminController {

    private final ResourceService resourceService;
    private final ResourceAllocationService allocationService;
    private final SecurityUtils securityUtils;

    public HospitalAdminController(ResourceService resourceService, ResourceAllocationService allocationService,
                                   SecurityUtils securityUtils) {
        this.resourceService = resourceService;
        this.allocationService = allocationService;
        this.securityUtils = securityUtils;
    }

    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        Hospital currentHospital = securityUtils.getCurrentHospital();
        if (currentHospital == null) return "redirect:/login";

        model.addAttribute("hospital", currentHospital);
        model.addAttribute("resources", resourceService.getResourcesByHospital(currentHospital.getId()));
        model.addAttribute("user", securityUtils.getCurrentUser());
        model.addAttribute("currentQuotaLoad", allocationService.getQuotaLoadPercent(currentHospital));
        model.addAttribute("pendingRequests", allocationService.getRequestsByHospital(currentHospital.getId()).stream()
                .filter(req -> req.getStatus() == com.hospital.exchange.entity.AllocationRequest.RequestStatus.WAITING
                        || req.getStatus() == com.hospital.exchange.entity.AllocationRequest.RequestStatus.PENDING)
                .count());
        return "hospital_admin_dashboard";
    }

    @PostMapping("/resource/add")
    public String addResource(@ModelAttribute Resource resource) {
        Hospital currentHospital = securityUtils.getCurrentHospital();
        resource.setHospital(currentHospital);
        resource.setStatus(Resource.ResourceStatus.AVAILABLE);
        resourceService.saveResource(resource);
        return "redirect:/hospital-admin/dashboard";
    }

    @PostMapping("/resource/delete/{id}")
    public String deleteResource(@PathVariable Long id) {
        // Additional security check: ensure resource belongs to current hospital
        Resource resource = resourceService.getResourceById(id);
        if (resource.getHospital().getId().equals(securityUtils.getCurrentHospital().getId())) {
            resourceService.deleteResource(id);
        }
        return "redirect:/hospital-admin/dashboard";
    }
}
