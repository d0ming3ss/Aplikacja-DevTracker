package com.example.projecttracker.dto;

public class AuthResponse {

    private String email;
    private String message;

    // Konstruktor z parametrami
    public AuthResponse(String email, String message) {
        this.email = email;
        this.message = message;
    }

    // Konstruktor domyślny
    public AuthResponse() {
    }

    // Gettery i settery
    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
