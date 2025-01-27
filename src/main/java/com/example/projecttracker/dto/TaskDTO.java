package com.example.projecttracker.dto;

import java.time.LocalDate;
import java.util.Set;

public class TaskDTO {
    private Long id;
    private String name;
    private String description;
    private LocalDate startDate;
    private LocalDate endDate;
    private ProjectDTO project; // Reprezentuje projekt przypisany do zadania
    private Set<UserDTO> users; // Lista przypisanych użytkowników
    private Boolean completed = false;

    // Konstruktor
    public TaskDTO(Long id, String name, String description, LocalDate startDate, LocalDate endDate, ProjectDTO project, Set<UserDTO> users) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.startDate = startDate;
        this.endDate = endDate;
        this.project = project;
        this.users = users;
        this.completed = completed;
    }

    // Gettery i settery
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }

    public LocalDate getEndDate() { return endDate; }
    public void setEndDate(LocalDate endDate) { this.endDate = endDate; }

    public ProjectDTO getProject() { return project; }
    public void setProject(ProjectDTO project) { this.project = project; }

    public Set<UserDTO> getUsers() { return users; }
    public void setUsers(Set<UserDTO> users) { this.users = users; }

    public boolean isCompleted() { return completed; }
    public void setCompleted(boolean completed) { this.completed = completed; }
}
