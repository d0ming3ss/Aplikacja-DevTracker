package com.example.projecttracker.controller;

import com.example.projecttracker.dto.ChangeRoleRequest;
import com.example.projecttracker.model.Project;
import com.example.projecttracker.model.Role;
import com.example.projecttracker.model.User;
import com.example.projecttracker.repository.ProjectRepository;
import com.example.projecttracker.repository.RoleRepository;
import com.example.projecttracker.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import com.example.projecttracker.service.AuthService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.*;
import java.util.stream.Collectors; // Import dla Collectors


import javax.validation.Valid;
import java.util.List;

@RestController
@RequestMapping("/users")
public class UserController {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final ProjectRepository projectRepository;
    private final AuthService authService;

    @Autowired
    public UserController(UserRepository userRepository, RoleRepository roleRepository, ProjectRepository projectRepository, AuthService authService) {
        this.userRepository = userRepository;
        this.roleRepository = roleRepository;
        this.projectRepository = projectRepository;
        this.authService = authService;
    }

    @GetMapping
    public ResponseEntity<List<Map<String, String>>> getAllUsers() {
        List<User> users = userRepository.findAll();
        List<Map<String, String>> userList = users.stream()
                .map(user -> Map.of(
                        "id", String.valueOf(user.getId()),
                        "firstName", user.getFirstName(),
                        "lastName", user.getLastName(),
                        "email", user.getEmail(),
                        "roles", user.getRoles().stream().map(Role::getName).collect(Collectors.joining(", "))
                ))
                .collect(Collectors.toList());
        return ResponseEntity.ok(userList);
    }

    @GetMapping("/{id}")
    public ResponseEntity<User> getUserById(@PathVariable Long id) {
        Optional<User> user = userRepository.findById(id);
        return user.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PostMapping("/register")
    public ResponseEntity<String> registerUser(@Valid @RequestBody User user, BindingResult result) {
        if (result.hasErrors()) {
            return ResponseEntity.badRequest().body(result.getAllErrors().toString());
        }

        // Sprawdź, czy email już istnieje
        if (userRepository.findByEmail(user.getEmail()).isPresent()) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body("Email already in use");
        }

        // Tworzenie użytkownika
        User savedUser = userRepository.save(user);

        // Przypisanie domyślnej roli "Programista"
        Role defaultRole = roleRepository.findByName("Programista");
        if (defaultRole != null) {
            savedUser.getRoles().add(defaultRole);
            userRepository.save(savedUser);
        }

        return ResponseEntity.status(HttpStatus.CREATED).body("User registered successfully");
    }

    @PostMapping("/login")
    public ResponseEntity<String> loginUser(@RequestParam String email, @RequestParam String password) {
        Optional<User> userOpt = userRepository.findByEmail(email);

        if (userOpt.isPresent()) {
            User user = userOpt.get();
            if (user.getPassword().equals(password)) {
                return ResponseEntity.ok("Login successful");
            }
        }

        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid email or password");
    }

    @PutMapping("/{id}")
    public ResponseEntity<User> updateUser(@PathVariable Long id, @RequestBody User updatedUser) {
        if (userRepository.existsById(id)) {
            updatedUser.setId(id);
            User savedUser = userRepository.save(updatedUser);
            return ResponseEntity.ok(savedUser);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        if (userRepository.existsById(id)) {
            userRepository.deleteById(id);
            return ResponseEntity.noContent().build();
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{userId}/roles/{roleId}")
    @PreAuthorize("hasRole('Administrator')")
    public ResponseEntity<User> addRoleToUser(@PathVariable Long userId, @PathVariable Long roleId) {
        Optional<User> userOpt = userRepository.findById(userId);
        Optional<Role> roleOpt = roleRepository.findById(roleId);

        if (userOpt.isPresent() && roleOpt.isPresent()) {
            User user = userOpt.get();
            Role role = roleOpt.get();
            user.getRoles().add(role);
            userRepository.save(user);
            return ResponseEntity.ok(user);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @PutMapping("/{userId}/roles/{roleId}")
    @PreAuthorize("hasRole('Administrator')")
    public ResponseEntity<User> changeUserRole(@PathVariable Long userId, @PathVariable Long roleId) {
        Optional<User> userOpt = userRepository.findById(userId);
        Optional<Role> roleOpt = roleRepository.findById(roleId);

        if (userOpt.isPresent() && roleOpt.isPresent()) {
            User user = userOpt.get();
            Role role = roleOpt.get();
            Set<Role> roles = user.getRoles();

            roles.removeIf(existingRole -> existingRole.getId().equals(roleId));
            roles.add(role);

            user.setRoles(roles);
            userRepository.save(user);
            return ResponseEntity.ok(user);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/change-role")
    public ResponseEntity<String> changeUserRole(@RequestBody ChangeRoleRequest request) {
        try {
            authService.changeUserRole(request.getEmail(), request.getNewRole());
            return ResponseEntity.ok("Rola użytkownika została zmieniona na: " + request.getNewRole());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Wystąpił błąd podczas zmiany roli: " + e.getMessage());
        }
    }

    @PostMapping("/{userId}/projects/{projectId}")
    public ResponseEntity<User> assignProjectToUser(@PathVariable Long userId, @PathVariable Long projectId) {
        Optional<User> userOpt = userRepository.findById(userId);
        Optional<Project> projectOpt = projectRepository.findById(projectId);

        if (userOpt.isPresent() && projectOpt.isPresent()) {
            User user = userOpt.get();
            Project project = projectOpt.get();

            // Dodajemy projekt do użytkownika
            user.getProjects().add(project);
            // Dodajemy użytkownika do projektu
            project.getUsers().add(user);

            // Zapisujemy zmiany w obu encjach
            userRepository.save(user);
            projectRepository.save(project);

            return ResponseEntity.ok(user);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/{userId}/projects/{projectId}/users")
    public ResponseEntity<List<User>> getUsersAssignedToProject(@PathVariable Long projectId) {
        Optional<Project> projectOpt = projectRepository.findById(projectId);
        if (projectOpt.isPresent()) {
            Project project = projectOpt.get();
            return ResponseEntity.ok(new ArrayList<>(project.getUsers()));
        } else {
            return ResponseEntity.notFound().build();
        }
    }


}
