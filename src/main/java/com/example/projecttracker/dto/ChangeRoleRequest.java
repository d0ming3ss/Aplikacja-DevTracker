package com.example.projecttracker.dto;

public class ChangeRoleRequest {

    private String email;
    private String newRole;

    // Domyślny konstruktor (wymagany)
    public ChangeRoleRequest() {}

    // Konstruktor z argumentami
    public ChangeRoleRequest(String email, String newRole) {
        this.email = email;
        this.newRole = newRole;
    }

    // Gettery i settery
    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getNewRole() {
        return newRole;
    }

    public void setNewRole(String newRole) {
        this.newRole = newRole;
    }
}


