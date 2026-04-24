package com.hospital.exchange.controller;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/error")
public class ErrorViewController {

    @GetMapping
    public String error(HttpServletRequest request, Model model) {
        Object statusCode = request.getAttribute(RequestDispatcher.ERROR_STATUS_CODE);
        int status = statusCode instanceof Integer ? (Integer) statusCode : 500;
        model.addAttribute("status", status);
        model.addAttribute("title", status == 404 ? "Page not found." : "Application request failed.");
        model.addAttribute("message", "The request could not be completed. Please retry or return to the dashboard.");
        model.addAttribute("path", request.getAttribute(RequestDispatcher.ERROR_REQUEST_URI));
        return "error";
    }

    @GetMapping("/403")
    public String forbidden(Model model) {
        model.addAttribute("status", 403);
        model.addAttribute("title", "Access denied.");
        model.addAttribute("message", "You do not have permission to open this page.");
        model.addAttribute("path", "/error/403");
        return "error";
    }
}
