////package com.example.projecttracker.model;
////
////import com.fasterxml.jackson.annotation.JsonIgnore;
////import com.fasterxml.jackson.annotation.JsonInclude;
////import com.fasterxml.jackson.annotation.JsonManagedReference;
////
////import javax.persistence.*;
////import javax.validation.constraints.NotNull;
////import java.time.LocalDate;
////import java.util.HashSet;
////import java.util.Set;
////
////@Entity
////public class Project {
////
////    @Id
////    @GeneratedValue(strategy = GenerationType.IDENTITY)
////    private Long id;
////
////    @NotNull(message = "Nazwa projektu jest wymagana.")
////    private String name;
////
////    @NotNull(message = "Opis projektu jest wymagany.")
////    private String description;
////
////    private LocalDate startDate;
////    private LocalDate endDate;
////
////    @ManyToMany
////    @JoinTable(
////            name = "project_user",
////            joinColumns = @JoinColumn(name = "project_id"),
////            inverseJoinColumns = @JoinColumn(name = "user_id")
////    )
//////    @JsonIgnore
//////    @JsonManagedReference
////    private Set<User> users = new HashSet<>();
////
////    // Gettery i settery
////    public Long getId() {
////        return id;
////    }
////
////    public void setId(Long id) {
////        this.id = id;
////    }
////
////    public String getName() {
////        return name;
////    }
////
////    public void setName(String name) {
////        this.name = name;
////    }
////
////    public String getDescription() {
////        return description;
////    }
////
////    public void setDescription(String description) {
////        this.description = description;
////    }
////
////    public LocalDate getStartDate() {
////        return startDate;
////    }
////
////    public void setStartDate(LocalDate startDate) {
////        this.startDate = startDate;
////    }
////
////    public LocalDate getEndDate() {
////        return endDate;
////    }
////
////    public void setEndDate(LocalDate endDate) {
////        this.endDate = endDate;
////    }
////
////    public Set<User> getUsers() {
////        return users;
////    }
////
////    public void setUsers(Set<User> users) {
////        this.users = users;
////    }
////}
//package com.example.projecttracker.model;
//
//import com.fasterxml.jackson.annotation.JsonIgnore;
//import com.fasterxml.jackson.annotation.JsonManagedReference;
//
//import javax.persistence.*;
//import javax.validation.constraints.NotNull;
//import java.time.LocalDate;
//import java.util.HashSet;
//import java.util.Set;
//
//@Entity
//public class Project {
//
//    @Id
//    @GeneratedValue(strategy = GenerationType.IDENTITY)
//    private Long id;
//
//    @NotNull(message = "Nazwa projektu jest wymagana.")
//    private String name;
//
//    @NotNull(message = "Opis projektu jest wymagany.")
//    private String description;
//
//    private LocalDate startDate;
//    private LocalDate endDate;
//
//    @ManyToMany
//    @JoinTable(
//            name = "project_user",
//            joinColumns = @JoinColumn(name = "project_id"),
//            inverseJoinColumns = @JoinColumn(name = "user_id")
//    )
//    private Set<User> users = new HashSet<>();
//
//    // Nowe pole `tasks` reprezentujące listę zadań przypisanych do projektu
//    @OneToMany(mappedBy = "project", cascade = CascadeType.ALL, orphanRemoval = true)
//    @JsonIgnore
//    private Set<Task> tasks = new HashSet<>();
//
//    // Gettery i settery
//    public Long getId() {
//        return id;
//    }
//
//    public void setId(Long id) {
//        this.id = id;
//    }
//
//    public String getName() {
//        return name;
//    }
//
//    public void setName(String name) {
//        this.name = name;
//    }
//
//    public String getDescription() {
//        return description;
//    }
//
//    public void setDescription(String description) {
//        this.description = description;
//    }
//
//    public LocalDate getStartDate() {
//        return startDate;
//    }
//
//    public void setStartDate(LocalDate startDate) {
//        this.startDate = startDate;
//    }
//
//    public LocalDate getEndDate() {
//        return endDate;
//    }
//
//    public void setEndDate(LocalDate endDate) {
//        this.endDate = endDate;
//    }
//
//    public Set<User> getUsers() {
//        return users;
//    }
//
//    public void setUsers(Set<User> users) {
//        this.users = users;
//    }
//
//    public Set<Task> getTasks() {
//        return tasks;
//    }
//
//    public void setTasks(Set<Task> tasks) {
//        this.tasks = tasks;
//    }
//}
package com.example.projecttracker.model;

import com.fasterxml.jackson.annotation.JsonIgnore;

import javax.persistence.*;
import javax.validation.constraints.NotNull;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Entity
public class Project {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull(message = "Nazwa projektu jest wymagana.")
    private String name;

    @NotNull(message = "Opis projektu jest wymagany.")
    private String description;

    private LocalDate startDate;
    private LocalDate endDate;

    @ManyToMany
    @JoinTable(
            name = "project_user",
            joinColumns = @JoinColumn(name = "project_id"),
            inverseJoinColumns = @JoinColumn(name = "user_id")
    )
    private Set<User> users = new HashSet<>();

    // Nowe pole `tasks` reprezentujące listę zadań przypisanych do projektu
    @OneToMany(mappedBy = "project", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonIgnore
    private Set<Task> tasks = new HashSet<>();

    // Gettery i settery
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public LocalDate getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }

    public LocalDate getEndDate() {
        return endDate;
    }

    public void setEndDate(LocalDate endDate) {
        this.endDate = endDate;
    }

    public List<User> getUsers() {
        return new ArrayList<>(users); // Konwersja Set na List
    }

    public void setUsers(Set<User> users) {
        this.users = users;
    }

    public List<Task> getTasks() {
        return new ArrayList<>(tasks); // Konwersja Set na List
    }

    public void setTasks(Set<Task> tasks) {
        this.tasks = tasks;
    }
}

