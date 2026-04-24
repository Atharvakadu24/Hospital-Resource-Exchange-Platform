package com.hospital.exchange.controller;

import com.hospital.exchange.service.AuditLogService;
import com.hospital.exchange.service.HospitalService;
import com.hospital.exchange.service.ResourceAllocationService;
import com.hospital.exchange.service.ResourceService;
import com.hospital.exchange.entity.Hospital;
import com.hospital.exchange.entity.Resource;
import com.hospital.exchange.util.SecurityUtils;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/admin")
public class AdminController {

    private final AuditLogService auditLogService;
    private final HospitalService hospitalService;
    private final ResourceService resourceService;
    private final ResourceAllocationService allocationService;
    private final SecurityUtils securityUtils;

    public AdminController(AuditLogService auditLogService, HospitalService hospitalService, ResourceService resourceService,
                           ResourceAllocationService allocationService, SecurityUtils securityUtils) {
        this.auditLogService = auditLogService;
        this.hospitalService = hospitalService;
        this.resourceService = resourceService;
        this.allocationService = allocationService;
        this.securityUtils = securityUtils;
    }

    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        List<Resource> resources = resourceService.getAllResources();
        List<Hospital> hospitals = hospitalService.getAllHospitals();
        model.addAttribute("user", securityUtils.getCurrentUser());
        model.addAttribute("isAdmin", true);
        model.addAttribute("hospitals", hospitals);
        model.addAttribute("resources", resources);
        model.addAttribute("availableResources", resources.stream().filter(r -> r.getStatus() == Resource.ResourceStatus.AVAILABLE).count());
        model.addAttribute("activeAllocations", resources.stream().filter(r -> r.getStatus() != Resource.ResourceStatus.AVAILABLE).count());
        model.addAttribute("hospitalLoads", hospitals.stream().collect(Collectors.toMap(Hospital::getId, allocationService::getQuotaLoadPercent)));
        model.addAttribute("newHospital", new Hospital());
        return "dashboard";
    }

    @GetMapping("/logs")
    public String viewLogs(Model model) {
        model.addAttribute("logs", auditLogService.getAllLogs());
        return "logs";
    }

    @PostMapping("/hospitals")
    public String createHospital(@ModelAttribute("newHospital") Hospital hospital,
                                 @RequestParam(required = false) String adminUsername,
                                 @RequestParam(required = false) String adminPassword) {
        hospitalService.createHospital(hospital, adminUsername, adminPassword);
        return "redirect:/admin/dashboard";
    }

    @PostMapping("/hospitals/delete/{id}")
    public String deleteHospital(@PathVariable Long id) {
        hospitalService.deleteHospital(id);
        return "redirect:/admin/dashboard";
    }
}
