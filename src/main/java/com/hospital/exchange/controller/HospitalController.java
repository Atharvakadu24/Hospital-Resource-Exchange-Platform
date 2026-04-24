package com.hospital.exchange.controller;

import com.hospital.exchange.dto.HospitalResourceSummaryDTO;
import com.hospital.exchange.entity.Hospital;
import com.hospital.exchange.entity.Resource;
import com.hospital.exchange.service.HospitalService;
import com.hospital.exchange.service.ResourceService;
import com.hospital.exchange.util.SecurityUtils;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import java.util.List;

/**
 * Controller for viewing general hospital profiles and resource lists.
 * Accessible to all authenticated network users.
 */
@Controller
public class HospitalController {

    private final HospitalService hospitalService;
    private final ResourceService resourceService;
    private final SecurityUtils securityUtils;

    public HospitalController(HospitalService hospitalService, ResourceService resourceService, SecurityUtils securityUtils) {
        this.hospitalService = hospitalService;
        this.resourceService = resourceService;
        this.securityUtils = securityUtils;
    }

    /**
     * Renders the public-facing hospital detail page.
     * Shows basic info and real-time inventory levels.
     */
    @GetMapping("/hospital/{id}")
    public String viewHospital(@PathVariable Long id, Model model) {
        Hospital hospital = hospitalService.getHospitalById(id);
        List<Resource> resources = resourceService.getResourcesByHospital(id);
        HospitalResourceSummaryDTO summary = resourceService.getHospitalResourceSummary(id);

        model.addAttribute("hospital", hospital);
        model.addAttribute("resources", resources);
        model.addAttribute("summary", summary);
        model.addAttribute("isAdmin", securityUtils.isAdmin());
        model.addAttribute("isHospitalAdmin", securityUtils.isHospitalAdmin());
        model.addAttribute("currentHospitalId", securityUtils.getCurrentHospital() != null ? securityUtils.getCurrentHospital().getId() : null);
        return "hospital_detail";
    }
}
