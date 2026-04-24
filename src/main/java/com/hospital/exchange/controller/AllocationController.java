package com.hospital.exchange.controller;

import com.hospital.exchange.service.BookingService;
import com.hospital.exchange.service.HospitalService;
import com.hospital.exchange.service.ResourceAllocationService;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Controller
@RequestMapping("/allocations")
public class AllocationController {

    private final ResourceAllocationService allocationService;
    private final BookingService bookingService;
    private final HospitalService hospitalService;

    public AllocationController(ResourceAllocationService allocationService, BookingService bookingService,
                                HospitalService hospitalService) {
        this.allocationService = allocationService;
        this.bookingService = bookingService;
        this.hospitalService = hospitalService;
    }

    @GetMapping
    public String listAllocations(Model model) {
        model.addAttribute("bookings", bookingService.getAllBookings());
        return "allocation_list";
    }

    @GetMapping("/active")
    @PreAuthorize("hasAuthority('ADMIN')")
    public String viewActiveAllocations(Model model) {
        model.addAttribute("bookings", bookingService.getAllBookings());
        model.addAttribute("isAdmin", true);
        return "active_allocations";
    }

    @PostMapping("/release/{id}")
    @PreAuthorize("hasAuthority('ADMIN')")
    public String releaseAllocation(@PathVariable Long id) {
        bookingService.releaseBooking(id);
        return "redirect:/allocations/active";
    }

    @GetMapping({"/monitor", "/network-monitor"})
    public String monitor(Model model) {
        model.addAttribute("waitingRequests", allocationService.getWaitingRequests());
        model.addAttribute("dependencies", buildDependencyView());
        return "monitor";
    }

    private List<Map<String, String>> buildDependencyView() {
        List<Map<String, String>> dependencies = new ArrayList<>();
        for (Map.Entry<Long, Set<Long>> entry : allocationService.getActiveDependencies().entrySet()) {
            String fromHospital = hospitalService.getHospitalById(entry.getKey()).getName();
            for (Long targetHospitalId : entry.getValue()) {
                dependencies.add(Map.of(
                        "fromHospital", fromHospital,
                        "toHospital", hospitalService.getHospitalById(targetHospitalId).getName()
                ));
            }
        }
        return dependencies;
    }
}
