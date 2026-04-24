package com.hospital.exchange.controller;

import com.hospital.exchange.exception.ForbiddenOperationException;
import com.hospital.exchange.exception.ResourceNotFoundException;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ResourceNotFoundException.class)
    public String handleNotFound(ResourceNotFoundException ex, HttpServletRequest request, Model model) {
        return populateError(model, request, 404, "Requested data was not found.", ex.getMessage());
    }

    @ExceptionHandler({ForbiddenOperationException.class, org.springframework.security.access.AccessDeniedException.class})
    public String handleForbidden(Exception ex, HttpServletRequest request, Model model) {
        return populateError(model, request, 403, "You do not have permission to perform this action.", ex.getMessage());
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public String handleBadRequest(IllegalArgumentException ex, HttpServletRequest request, Model model) {
        return populateError(model, request, 400, "Please review the submitted information.", ex.getMessage());
    }

    @ExceptionHandler(Exception.class)
    public String handleGeneric(Exception ex, HttpServletRequest request, Model model) {
        return populateError(model, request, 500, "Something unexpected happened while processing the request.", ex.getMessage());
    }

    private String populateError(Model model, HttpServletRequest request, int status, String title, String message) {
        model.addAttribute("status", status);
        model.addAttribute("title", title);
        model.addAttribute("message", message);
        model.addAttribute("path", request.getRequestURI());
        return "error";
    }
}
