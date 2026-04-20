package com.hospital.exchange.controller;

import com.hospital.exchange.service.HospitalService;
import com.hospital.exchange.service.ResourceService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

/**
 * Controller for viewing general hospital profiles and resource lists.
 * Accessible to all authenticated network users.
 */
@Controller
public class HospitalController {

    private final HospitalService hospitalService;
    private final ResourceService resourceService;

    public HospitalController(HospitalService hospitalService, ResourceService resourceService) {
        this.hospitalService = hospitalService;
        this.resourceService = resourceService;
    }

    /**
     * Renders the public-facing hospital detail page.
     * Shows basic info and real-time inventory levels.
     */
    @GetMapping("/hospital/{id}")
    public String viewHospital(@PathVariable Long id, Model model) {
        model.addAttribute("hospital", hospitalService.getHospitalById(id));
        model.addAttribute("resources", resourceService.getResourcesByHospital(id));
        return "hospital_detail";
    }
}
