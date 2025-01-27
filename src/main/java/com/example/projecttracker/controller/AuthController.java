package com.example.projecttracker.controller;

import com.example.projecttracker.dto.AuthRequest;
import com.example.projecttracker.dto.AuthResponse;
import com.example.projecttracker.dto.RegisterRequest;
import com.example.projecttracker.model.User;
import com.example.projecttracker.service.AuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/auth")
public class AuthController {

    private final AuthService authService;

    @Autowired
    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@RequestBody RegisterRequest registerRequest) {
        User registeredUser = authService.register(registerRequest);
        return ResponseEntity.status(HttpStatus.CREATED).body(new AuthResponse(registeredUser.getEmail(), "Użytkownik zarejestrowany pozytywnie"));
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody AuthRequest authRequest) {
        Map<String, Object> loginResponse = authService.login(authRequest);
        return ResponseEntity.ok(loginResponse);
    }

}
