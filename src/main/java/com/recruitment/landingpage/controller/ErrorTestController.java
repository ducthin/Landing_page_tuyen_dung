package com.recruitment.landingpage.controller;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.server.ResponseStatusException;

@Controller
public class ErrorTestController {

    @GetMapping("/test-errors")
    public String showErrorTestPage() {
        return "test-errors";
    }

    @GetMapping("/favicon-guide")
    public String showFaviconGuide() {
        return "favicon-guide";
    }

    @GetMapping("/favicon-test")
    public String showFaviconTest() {
        return "favicon-test";
    }

    @GetMapping("/test-404")
    public String test404() {
        throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Test 404 Error");
    }

    @GetMapping("/test-500")
    public String test500() {
        throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Test 500 Error");
    }

    @GetMapping("/test-403")
    public String test403() {
        throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Test 403 Error");
    }

    @GetMapping("/test-400")
    public String test400() {
        throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Test 400 Error");
    }
}
