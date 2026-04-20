package com.hospital.exchange.controller;

import com.hospital.exchange.entity.Resource;
import com.hospital.exchange.service.ResourceService;
import com.hospital.exchange.util.SecurityUtils;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;

/**
 * Controller for managing individual medical resources (Beds, Ventilators, etc).
 * Accessible by hospital administrators to manage their inventory.
 */
@Controller
@RequestMapping("/resources")
public class ResourceController {

    private final ResourceService resourceService;
    private final SecurityUtils securityUtils;

    public ResourceController(ResourceService resourceService, SecurityUtils securityUtils) {
        this.resourceService = resourceService;
        this.securityUtils = securityUtils;
    }

    @GetMapping("/marketplace")
    public String marketplace(Model model) {
        model.addAttribute("allResources", resourceService.getAllResources());
        return "marketplace";
    }

    @GetMapping("/{id}")
    public String getResource(@PathVariable Long id, Model model) {
        model.addAttribute("resource", resourceService.getResourceById(id));
        return "resource_detail";
    }

    @PostMapping("/update/{id}")
    @PreAuthorize("hasAnyAuthority('ADMIN', 'HOSPITAL_ADMIN')")
    public String updateResource(@PathVariable Long id, @Valid @ModelAttribute Resource resource, BindingResult result) {
        if (result.hasErrors()) {
            return "resource_edit";
        }
        
        // Ownership check for HOSPITAL_ADMIN
        if (securityUtils.isHospitalAdmin()) {
            Resource existing = resourceService.getResourceById(id);
            if (!existing.getHospital().getId().equals(securityUtils.getCurrentHospital().getId())) {
                return "redirect:/error/403";
            }
        }
        
        resourceService.updateResource(id, resource);
        return "redirect:/resources/" + id;
    }

    @PostMapping("/delete/{id}")
    @PreAuthorize("hasAnyAuthority('ADMIN', 'HOSPITAL_ADMIN')")
    public String deleteResource(@PathVariable Long id) {
        // Ownership check for HOSPITAL_ADMIN
        if (securityUtils.isHospitalAdmin()) {
            Resource existing = resourceService.getResourceById(id);
            if (!existing.getHospital().getId().equals(securityUtils.getCurrentHospital().getId())) {
                return "redirect:/error/403";
            }
        }
        
        resourceService.deleteResource(id);
        return "redirect:/resources";
    }

    /**
     * REST endpoint for status checking.
     * Used by real-time frontend monitors.
     */
    @GetMapping("/api/status/{id}")
    @ResponseBody
    public String getResourceStatus(@PathVariable Long id) {
        return resourceService.getResourceById(id).getStatus().name();
    }
}
