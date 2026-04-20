package com.hospital.exchange.controller;

import com.hospital.exchange.service.AuditLogService;
import com.hospital.exchange.service.HospitalService;
import com.hospital.exchange.service.ResourceService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/admin")
public class AdminController {

    private final AuditLogService auditLogService;
    private final HospitalService hospitalService;
    private final ResourceService resourceService;

    public AdminController(AuditLogService auditLogService, HospitalService hospitalService, ResourceService resourceService) {
        this.auditLogService = auditLogService;
        this.hospitalService = hospitalService;
        this.resourceService = resourceService;
    }

    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        model.addAttribute("hospitals", hospitalService.getAllHospitals());
        model.addAttribute("resources", resourceService.getAllResources());
        return "dashboard";
    }

    @GetMapping("/logs")
    public String viewLogs(Model model) {
        model.addAttribute("logs", auditLogService.getAllLogs());
        return "logs";
    }
}
