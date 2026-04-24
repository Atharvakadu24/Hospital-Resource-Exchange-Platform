package com.hospital.exchange.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class NavigationController {

    @GetMapping("/marketplace")
    public String marketplaceAlias() {
        return "redirect:/resources/marketplace";
    }

    @GetMapping("/monitor")
    public String monitorAlias() {
        return "redirect:/allocations/monitor";
    }
}
