package com.hospital.exchange.controller;

import com.hospital.exchange.service.HospitalService;
import com.hospital.exchange.service.ResourceAllocationService;
import com.hospital.exchange.service.ResourceService;
import com.hospital.exchange.entity.Resource;
import com.hospital.exchange.util.SecurityUtils;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.List;

@Controller
public class DashboardController {

    private final HospitalService hospitalService;
    private final ResourceService resourceService;
    private final ResourceAllocationService allocationService;
    private final SecurityUtils securityUtils;

    public DashboardController(HospitalService hospitalService, ResourceService resourceService, 
                               ResourceAllocationService allocationService, SecurityUtils securityUtils) {
        this.hospitalService = hospitalService;
        this.resourceService = resourceService;
        this.allocationService = allocationService;
        this.securityUtils = securityUtils;
    }

    @GetMapping("/")
    public String index(Model model) {
        if (securityUtils.getCurrentUser() != null) {
            if (securityUtils.isAdmin()) {
                return "redirect:/admin/dashboard";
            } else {
                return "redirect:/hospital-admin/dashboard";
            }
        }
        model.addAttribute("hospitals", hospitalService.getAllHospitals());
        return "index";
    }

    @GetMapping("/dashboard")
    public String mainDashboard(Model model) {
        if (securityUtils.getCurrentUser() == null) return "redirect:/login";
        if (securityUtils.isAdmin()) return "redirect:/admin/dashboard";
        if (securityUtils.isHospitalAdmin()) return "redirect:/hospital-admin/dashboard";

        List<Resource> resources = resourceService.getAllResources();
        model.addAttribute("user", securityUtils.getCurrentUser());
        model.addAttribute("recentRequests", allocationService.getAllRequests());
        model.addAttribute("resources", resources);
        model.addAttribute("hospitals", hospitalService.getAllHospitals());
        model.addAttribute("availableResources", resources.stream().filter(r -> r.getStatus() == Resource.ResourceStatus.AVAILABLE).count());
        model.addAttribute("activeAllocations", resources.stream().filter(r -> r.getStatus() != Resource.ResourceStatus.AVAILABLE).count());
        model.addAttribute("isAdmin", securityUtils.isAdmin());
        
        return "dashboard";
    }
}
