package com.example.projecttracker.service;

import com.example.projecttracker.dto.AuthRequest;
import com.example.projecttracker.dto.RegisterRequest;
import com.example.projecttracker.model.Role;
import com.example.projecttracker.model.User;
import com.example.projecttracker.repository.RoleRepository;
import com.example.projecttracker.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;

    @Autowired
    public AuthService(UserRepository userRepository, RoleRepository roleRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.roleRepository = roleRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public User register(RegisterRequest registerRequest) {
        if (userRepository.existsByEmail(registerRequest.getEmail())) {
            throw new RuntimeException("Ten adres email już jest zajęty");
        }

        User user = new User();
        user.setFirstName(registerRequest.getFirstName());
        user.setLastName(registerRequest.getLastName());
        user.setEmail(registerRequest.getEmail());
        user.setPassword(passwordEncoder.encode(registerRequest.getPassword()));

        // Przypisywanie roli "Programista" dla nowego użytkownika
        Role developerRole = roleRepository.findByName("Programista");
        user.getRoles().add(developerRole);

        return userRepository.save(user);
    }

    public Map<String, Object> login(AuthRequest authRequest) {
        Optional<User> userOpt = userRepository.findByEmail(authRequest.getEmail());

        if (userOpt.isPresent()) {
            User user = userOpt.get();
            if (passwordEncoder.matches(authRequest.getPassword(), user.getPassword())) {
                // Pobieranie ról użytkownika i tworzenie odpowiedzi
                Set<Role> roles = user.getRoles();
                List<String> roleNames = roles.stream()
                        .map(Role::getName)
                        .collect(Collectors.toList());

                System.out.println("Roles for user: " + roleNames);

                Map<String, Object> response = new HashMap<>();
                response.put("email", user.getEmail());
                response.put("roles", roleNames);

                return response;
            } else {
                throw new RuntimeException("Niepoprawne dane");
            }
        } else {
            throw new RuntimeException("Nie znaleziono użytkownika");
        }
    }

    public void changeUserRole(String email, String newRoleName) {
        Optional<User> userOpt = userRepository.findByEmail(email);

        if (userOpt.isPresent()) {
            User user = userOpt.get();
            Role newRole = roleRepository.findByName(newRoleName);

            if (newRole != null) {
                // Usuwamy stare role użytkownika i przypisujemy nową rolę
                user.getRoles().clear();
                user.getRoles().add(newRole);
                userRepository.save(user);
            } else {
                throw new RuntimeException("Rola o nazwie " + newRoleName + " nie istnieje.");
            }
        } else {
            throw new RuntimeException("Nie znaleziono użytkownika z adresem e-mail: " + email);
        }
    }

}
