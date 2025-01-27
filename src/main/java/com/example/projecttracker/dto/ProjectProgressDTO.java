package com.example.projecttracker.dto;

public class ProjectProgressDTO {
    private Long projectId;
    private String projectName;
    private double completionPercentage;

    // Konstruktor
    public ProjectProgressDTO(Long projectId, String projectName, double completionPercentage) {
        this.projectId = projectId;
        this.projectName = projectName;
        this.completionPercentage = completionPercentage;
    }

    // Gettery
    public Long getProjectId() {
        return projectId;
    }

    public String getProjectName() {
        return projectName;
    }

    public double getCompletionPercentage() {
        return completionPercentage;
    }

    // Settery
    public void setProjectId(Long projectId) {
        this.projectId = projectId;
    }

    public void setProjectName(String projectName) {
        this.projectName = projectName;
    }

    public void setCompletionPercentage(double completionPercentage) {
        this.completionPercentage = completionPercentage;
    }
}
