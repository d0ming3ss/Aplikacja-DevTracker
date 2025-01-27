package com.example.projecttracker.controller;

import com.example.projecttracker.service.JiraService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders; // Zmiana importu
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/jira")
//@CrossOrigin(origins = "http://localhost:8080")
public class JiraController {

    private final JiraService jiraService;

    @Autowired
    public JiraController(JiraService jiraService) {
        this.jiraService = jiraService;
    }

    // Pobieranie listy tablic JIRA
    @GetMapping("/boards")
    public String getBoards(@RequestHeader HttpHeaders headers) {
        // Logowanie nagłówków
        System.out.println("Received headers: " + headers);

        // Sprawdź, czy nagłówek Authorization jest obecny
        if (!headers.containsKey("Authorization")) {
            System.out.println("Authorization header is missing.");
        } else {
            System.out.println("Authorization header: " + headers.getFirst("Authorization"));
        }

        return jiraService.getBoards();
    }


    // Pobieranie zgłoszeń z wybranej tablicy JIRA
    @GetMapping("/boards/{boardId}/issues")
    public String getIssuesFromBoard(@PathVariable int boardId) {
        return jiraService.getIssuesFromBoard(boardId);
    }

    // Tworzenie nowego zgłoszenia
    @PostMapping("/issues")
    public ResponseEntity<?> createIssue(@RequestBody Map<String, Object> issueData) {
        System.out.println("Received issue data: " + issueData);

        String projectKey = (String) issueData.get("projectKey");
        String summary = (String) issueData.get("summary");
        String description = (String) issueData.get("description");

        // Sprawdzanie poprawności danych
        if (projectKey == null || summary == null || description == null) {
            System.out.println("Missing required fields.");
            Map<String, String> errorResponse = new HashMap<>();
            errorResponse.put("error", "Missing required fields.");
            return ResponseEntity.badRequest().body(errorResponse);
        }

        // Przetwarzanie zgłoszenia
        String result = jiraService.createIssue(projectKey, summary, description);
        return ResponseEntity.ok(result);
    }

//    @PostMapping("/issues")
//    public ResponseEntity<?> createIssue(@RequestBody Map<String, Object> issueData) {
//        System.out.println("Received issue data: " + issueData); // Logowanie danych wejściowych
//
//        // Wydobycie danych
//        String projectKey = (String) issueData.get("projectKey");
//        String summary = (String) issueData.get("summary");
//        String description = (String) issueData.get("description");
//        String selectedStatus = (String) issueData.get("selectedStatus"); // Pobranie statusu
//
//        // Sprawdzanie poprawności danych
//        if (projectKey == null || summary == null || description == null) {
//            System.out.println("Missing required fields.");
//            Map<String, String> errorResponse = new HashMap<>();
//            errorResponse.put("error", "Missing required fields.");
//            return ResponseEntity.badRequest().body(errorResponse);
//        }
//
//        // Przetwarzanie zgłoszenia
//        String result = jiraService.createIssue(projectKey, summary, description, selectedStatus);
//        return ResponseEntity.ok(result);
//    }

//    @PostMapping("/issues/{issueId}/status")
//    public ResponseEntity<?> changeIssueStatus(@PathVariable String issueId, @RequestBody Map<String, Object> statusData) {
//        System.out.println("Received status data: " + statusData); // Logowanie danych wejściowych
//
//        String newStatus = (String) statusData.get("newStatus");
//
//        // Sprawdzanie poprawności danych
//        if (newStatus == null) {
//            System.out.println("Missing required status.");
//            Map<String, String> errorResponse = new HashMap<>();
//            errorResponse.put("error", "Missing required status.");
//            return ResponseEntity.badRequest().body(errorResponse);
//        }
//
//        // Przetwarzanie zmiany statusu
//        jiraService.changeIssueStatus(issueId, newStatus);
//        return ResponseEntity.ok("Status changed successfully.");
//    }
}

