package com.example.projecttracker.controller;

import com.example.projecttracker.dto.ProjectDTO;
import com.example.projecttracker.dto.ProjectProgressDTO;
import com.example.projecttracker.dto.UserDTO;
import com.example.projecttracker.model.Project;
import com.example.projecttracker.model.Task;
import com.example.projecttracker.model.User;
import com.example.projecttracker.repository.ProjectRepository;
import com.example.projecttracker.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/projects")
public class ProjectController {

    private final ProjectRepository projectRepository;
    private final UserRepository userRepository;

    @Autowired
    public ProjectController(ProjectRepository projectRepository, UserRepository userRepository) {
        this.projectRepository = projectRepository;
        this.userRepository = userRepository;
    }

    // Pobieranie wszystkich projektów
    @GetMapping
    public List<ProjectDTO> getAllProjects() {
        List<Project> projects = projectRepository.findAll();
        return projects.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    // Metoda pomocnicza do konwersji Project na ProjectDTO
    private ProjectDTO convertToDTO(Project project) {
        Set<UserDTO> userDTOs = project.getUsers().stream()
                .map(this::convertUserToDTO)
                .collect(Collectors.toSet());
        return new ProjectDTO(project.getId(), project.getName(), project.getDescription(),
                project.getStartDate(), project.getEndDate(), userDTOs);
    }

    // Metoda pomocnicza do konwersji User na UserDTO
    private UserDTO convertUserToDTO(User user) {
        return new UserDTO(user.getId(), user.getFirstName(), user.getLastName(), user.getEmail());
    }


    // Pobieranie projektu po ID
    @GetMapping("/{id}")
    public ResponseEntity<Project> getProjectById(@PathVariable Long id) {
        Optional<Project> project = projectRepository.findById(id);
        return project.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }

    // Dodawanie nowego projektu
    @PostMapping
    public ResponseEntity<Project> createProject(@Valid @RequestBody Project project) {
        Project savedProject = projectRepository.save(project);
        return ResponseEntity.status(HttpStatus.CREATED).body(savedProject);
    }

    // Obsługa błędów walidacji
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, String>> handleValidationExceptions(MethodArgumentNotValidException ex) {
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getAllErrors().forEach((error) -> {
            String fieldName = ((FieldError) error).getField();
            String errorMessage = error.getDefaultMessage();
            errors.put(fieldName, errorMessage);
        });
        return ResponseEntity.badRequest().body(errors);
    }

    // Aktualizowanie istniejącego projektu
    @PutMapping("/{id}")
    public ResponseEntity<Project> updateProject(@PathVariable Long id, @RequestBody Project updatedProject) {
        Optional<Project> optionalProject = projectRepository.findById(id);
        if (optionalProject.isPresent()) {
            updatedProject.setId(id);
            Project savedProject = projectRepository.save(updatedProject);
            return ResponseEntity.ok(savedProject);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    // Usuwanie projektu
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProject(@PathVariable Long id) {
        Optional<Project> project = projectRepository.findById(id);
        if (project.isPresent()) {
            projectRepository.deleteById(id);
            return ResponseEntity.noContent().build();
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    // Przypisywanie użytkownika do projektu
    @PostMapping("/{projectId}/users/{userId}")
    public ResponseEntity<String> assignUserToProject(@PathVariable Long projectId, @PathVariable Long userId) {
        Optional<Project> projectOpt = projectRepository.findById(projectId);
        Optional<User> userOpt = userRepository.findById(userId);

        if (projectOpt.isPresent() && userOpt.isPresent()) {
            Project project = projectOpt.get();
            User user = userOpt.get();

            // Sprawdź, czy użytkownik posiada rolę "Programista" lub "Manager"
            boolean hasValidRole = user.getRoles().stream()
                    .anyMatch(role -> role.getName().equals("Programista") || role.getName().equals("Manager"));

            if (!hasValidRole) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body("Użytkownik musi mieć rolę 'Programista' lub 'Manager' aby być przypisanym do projektu.");
            }

            // Przypisanie użytkownika do projektu
            project.getUsers().add(user);
            projectRepository.save(project);

            return ResponseEntity.ok("Użytkownik przypisany do projektu pomyślnie.");
        }

        return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Projekt lub użytkownik nie został znaleziony.");
    }

    // Usuwanie użytkownika z projektu
    @DeleteMapping("/{projectId}/users/{userId}")
    public ResponseEntity<String> removeUserFromProject(@PathVariable Long projectId, @PathVariable Long userId) {
        Optional<Project> projectOpt = projectRepository.findById(projectId);
        Optional<User> userOpt = userRepository.findById(userId);

        if (projectOpt.isPresent() && userOpt.isPresent()) {
            Project project = projectOpt.get();
            User user = userOpt.get();

            // Usunięcie użytkownika z projektu
            project.getUsers().remove(user);
            projectRepository.save(project);

            return ResponseEntity.ok("Użytkownik został usunięty z projektu pomyślnie.");
        }

        return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Projekt lub użytkownik nie został znaleziony.");
    }

    // Pobieranie przypisanych użytkowników do projektu
    @GetMapping("/{projectId}/users")
    public ResponseEntity<List<UserDTO>> getAssignedUsers(@PathVariable Long projectId) {
        Optional<Project> projectOpt = projectRepository.findById(projectId);

        if (projectOpt.isPresent()) {
            Project project = projectOpt.get();
            List<UserDTO> assignedUsers = project.getUsers().stream()
                    .map(this::convertUserToDTO)
                    .collect(Collectors.toList());
            return ResponseEntity.ok(assignedUsers);
        }

        return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
    }

    // Pobieranie liczby procentowej potępu projektu
    @GetMapping("/progress")
    public List<ProjectProgressDTO> getProjectProgress() {
        List<Project> projects = projectRepository.findAll();

        return projects.stream().map(project -> {
            List<Task> tasks = (List<Task>) project.getTasks();
            long completedTasks = tasks.stream().filter(Task::isCompleted).count();
            double completionPercentage = tasks.isEmpty() ? 0 : (double) completedTasks / tasks.size() * 100;

            return new ProjectProgressDTO(project.getId(), project.getName(), completionPercentage);
        }).collect(Collectors.toList());
    }

}
