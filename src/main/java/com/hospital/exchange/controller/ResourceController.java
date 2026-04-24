package com.hospital.exchange.controller;

import com.hospital.exchange.entity.Resource;
import com.hospital.exchange.exception.ForbiddenOperationException;
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

    @GetMapping({"", "/"})
    public String listResources(Model model) {
        return marketplace(model);
    }

    @GetMapping("/marketplace")
    public String marketplace(Model model) {
        model.addAttribute("allResources", resourceService.getAllResources());
        model.addAttribute("isAdmin", securityUtils.isAdmin());
        model.addAttribute("isHospitalAdmin", securityUtils.isHospitalAdmin());
        model.addAttribute("currentHospitalId", securityUtils.getCurrentHospital() != null ? securityUtils.getCurrentHospital().getId() : null);
        return "marketplace";
    }

    @GetMapping("/{id}")
    public String getResource(@PathVariable Long id, Model model) {
        model.addAttribute("resource", resourceService.getResourceById(id));
        return "resource_detail";
    }

    @GetMapping("/edit/{id}")
    @PreAuthorize("hasAnyAuthority('ADMIN', 'HOSPITAL_ADMIN')")
    public String editResource(@PathVariable Long id, Model model) {
        Resource resource = resourceService.getResourceById(id);
        verifyOwnership(resource);
        populateResourceForm(model, resource);
        return "resource_edit";
    }

    @PostMapping("/update/{id}")
    @PreAuthorize("hasAnyAuthority('ADMIN', 'HOSPITAL_ADMIN')")
    public String updateResource(@PathVariable Long id, @Valid @ModelAttribute("resource") Resource resource, BindingResult result,
                                 Model model) {
        if (result.hasErrors()) {
            populateResourceForm(model, resource);
            return "resource_edit";
        }
        
        Resource existing = resourceService.getResourceById(id);
        verifyOwnership(existing);
        
        resourceService.updateResource(id, resource);
        return "redirect:/resources/" + id;
    }

    @PostMapping("/delete/{id}")
    @PreAuthorize("hasAnyAuthority('ADMIN', 'HOSPITAL_ADMIN')")
    public String deleteResource(@PathVariable Long id) {
        Resource existing = resourceService.getResourceById(id);
        verifyOwnership(existing);
        
        resourceService.deleteResource(id);
        return "redirect:/marketplace";
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

    private void verifyOwnership(Resource resource) {
        if (securityUtils.isHospitalAdmin() &&
                !resource.getHospital().getId().equals(securityUtils.getCurrentHospital().getId())) {
            throw new ForbiddenOperationException("You can manage only your hospital's resources.");
        }
    }

    private void populateResourceForm(Model model, Resource resource) {
        model.addAttribute("resource", resource);
        model.addAttribute("resourceTypes", com.hospital.exchange.model.ResourceType.values());
        model.addAttribute("resourceStatuses", Resource.ResourceStatus.values());
    }
}
