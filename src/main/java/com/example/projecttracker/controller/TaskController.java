package com.example.projecttracker.controller;

import com.example.projecttracker.dto.ProjectDTO;
import com.example.projecttracker.dto.TaskDTO;
import com.example.projecttracker.dto.UserDTO;
import com.example.projecttracker.model.Project;
import com.example.projecttracker.model.Task;
import com.example.projecttracker.model.User;
import com.example.projecttracker.repository.ProjectRepository;
import com.example.projecttracker.repository.TaskRepository;
import com.example.projecttracker.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@CrossOrigin(origins = "http://localhost:52803/")
@RestController
@RequestMapping("/tasks")
public class TaskController {

    private final TaskRepository taskRepository;
    private final ProjectRepository projectRepository;
    private final UserRepository userRepository;

    @Autowired
    public TaskController(TaskRepository taskRepository, ProjectRepository projectRepository, UserRepository userRepository) {
        this.taskRepository = taskRepository;
        this.projectRepository = projectRepository;
        this.userRepository = userRepository;
    }

    // Pobieranie wszystkich zadań
    @GetMapping
    public List<TaskDTO> getAllTasks() {
        List<Task> tasks = taskRepository.findAll();
        System.out.println("Pobrano zadania: " + tasks.size());
        return tasks.stream()
                .map(this::convertToTaskDTO)
                .collect(Collectors.toList());
    }

    private TaskDTO convertToTaskDTO(Task task) {
        try {
            return new TaskDTO(
                    task.getId(),
                    task.getName(),
                    task.getDescription(),
                    task.getStartDate(),
                    task.getEndDate(),
                    new ProjectDTO(task.getProject().getId(), task.getProject().getName()),
                    task.getUsers().stream()
                            .map(user -> new UserDTO(user.getId(), user.getFirstName(), user.getLastName()))
                            .collect(Collectors.toSet())
            );
        } catch (Exception e) {
            System.err.println("Błąd konwersji zadania: " + task);
            throw e;
        }
    }


    // Pobieranie zadania po ID
    @GetMapping("/{id}")
    public ResponseEntity<Task> getTaskById(@PathVariable Long id) {
        Optional<Task> task = taskRepository.findById(id);
        return task.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }

    // Dodawanie zadania do konkretnego projektu
    @PostMapping("/projects/{projectId}/assign-users")
    public ResponseEntity<String> createTaskForProjectWithUsers(
            @PathVariable Long projectId,
            @RequestBody Task task,
            @RequestParam List<Long> userIds) {

        Optional<Project> projectOpt = projectRepository.findById(projectId);

        if (projectOpt.isPresent()) {
            Project project = projectOpt.get();
            task.setProject(project);

            // Znalezienie i przypisanie użytkowników do zadania
            List<User> users = userRepository.findAllById(userIds);
            task.setUsers(new HashSet<>(users));

            taskRepository.save(task);
            return ResponseEntity.status(HttpStatus.CREATED).body("Zadanie zostało pomyślnie przypisane do projektu z użytkownikami.");
        }

        return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Projekt o podanym ID nie został znaleziony.");
    }

    // Usuwanie zadania
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTask(@PathVariable Long id) {
        if (taskRepository.existsById(id)) {
            taskRepository.deleteById(id);
            return ResponseEntity.noContent().build();
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    // Pobieranie zadań przypisanych do użytkownika
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Task>> getTasksByUserId(@PathVariable Long userId) {
        Optional<User> userOpt = userRepository.findById(userId);

        if (userOpt.isPresent()) {
            User user = userOpt.get();
            List<Task> userTasks = taskRepository.findByUsersContaining(user);
            return ResponseEntity.ok(userTasks);
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
        }
    }

    // Aktualizacja zadania
    @PatchMapping("/{id}/complete")
    public ResponseEntity<Void> updateTaskStatus(@PathVariable Long id, @RequestBody Map<String, Boolean> body) {
        Optional<Task> taskOptional = taskRepository.findById(id);

        if (taskOptional.isPresent()) {
            Task task = taskOptional.get();
            task.setCompleted(body.getOrDefault("completed", false));
            taskRepository.save(task);
            return ResponseEntity.ok().build();
        } else {
            return ResponseEntity.notFound().build();
        }
    }
}

