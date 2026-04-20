package com.hospital.exchange.controller;

import com.hospital.exchange.service.BookingService;
import com.hospital.exchange.service.ResourceAllocationService;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/allocations")
public class AllocationController {

    private final ResourceAllocationService allocationService;
    private final BookingService bookingService;

    public AllocationController(ResourceAllocationService allocationService, BookingService bookingService) {
        this.allocationService = allocationService;
        this.bookingService = bookingService;
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
        return "active_allocations";
    }

    @GetMapping("/monitor")
    public String monitor(Model model) {
        model.addAttribute("waitingRequests", allocationService.getWaitingRequests());
        // Simple dependency transformation for UI
        model.addAttribute("dependencies", allocationService.getActiveDependencies());
        return "monitor";
    }
}
