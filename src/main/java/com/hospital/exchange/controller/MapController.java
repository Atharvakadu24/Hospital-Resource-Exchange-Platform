package com.hospital.exchange.controller;

import com.hospital.exchange.dto.HospitalResourceSummaryDTO;
import com.hospital.exchange.entity.Hospital;
import com.hospital.exchange.entity.Resource;
import com.hospital.exchange.service.HospitalService;
import com.hospital.exchange.service.ResourceService;
import com.hospital.exchange.util.SecurityUtils;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.*;

@Controller
public class MapController {

    private final HospitalService hospitalService;
    private final ResourceService resourceService;
    private final SecurityUtils securityUtils;

    @org.springframework.beans.factory.annotation.Value("${google.maps.api.key:}")
    private String googleMapsApiKey;

    public MapController(HospitalService hospitalService, ResourceService resourceService, SecurityUtils securityUtils) {
        this.hospitalService = hospitalService;
        this.resourceService = resourceService;
        this.securityUtils = securityUtils;
    }

    @GetMapping("/map")
    public String mapView(Model model) {
        if (securityUtils.getCurrentUser() == null) return "redirect:/login";
        boolean googleMapsEnabled = googleMapsApiKey != null
                && !googleMapsApiKey.isBlank()
                && !googleMapsApiKey.contains("YOUR_ACTUAL");
        model.addAttribute("isAdmin", securityUtils.isAdmin());
        model.addAttribute("googleMapsApiKey", googleMapsApiKey);
        model.addAttribute("googleMapsEnabled", googleMapsEnabled);
        return "map";
    }

    @GetMapping("/api/map/hospitals")
    @ResponseBody
    public ResponseEntity<List<Map<String, Object>>> getHospitalsForMap() {
        List<Hospital> hospitals = hospitalService.getAllHospitals();
        List<Map<String, Object>> result = new ArrayList<>();

        for (Hospital hospital : hospitals) {
            Map<String, Object> data = new LinkedHashMap<>();
            data.put("id", hospital.getId());
            data.put("name", hospital.getName());
            data.put("location", hospital.getLocation());
            data.put("contactNumber", hospital.getContactNumber());
            data.put("lat", hospital.getLatitude());
            data.put("lng", hospital.getLongitude());

            // Centralized Resource Summary
            HospitalResourceSummaryDTO summary = resourceService.getHospitalResourceSummary(hospital.getId());
            data.put("resources", summary);
            data.put("status", summary.getStatus());
            data.put("quota", hospital.getResourceQuota());

            result.add(data);
        }

        return ResponseEntity.ok(result);
    }
}
