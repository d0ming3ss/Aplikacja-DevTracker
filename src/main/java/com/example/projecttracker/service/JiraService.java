package com.example.projecttracker.service;

import org.json.JSONException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.web.client.RestTemplate;
import org.springframework.stereotype.Service;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

@Service
public class JiraService {

    @Value("${jira.base.url}")
    private String jiraBaseUrl;

    @Value("${jira.username}")
    private String jiraUsername;

    @Value("${jira.token}")
    private String jiraToken;

    private final RestTemplate restTemplate = new RestTemplate();

    // Tworzenie nagłówków z autoryzacją
    private HttpHeaders createHeaders() {
        HttpHeaders headers = new HttpHeaders();
        headers.setBasicAuth(jiraUsername, jiraToken);
        headers.set("Content-Type", "application/json");
        return headers;
    }

    // Pobieranie listy tablic JIRA
    public String getBoards() {
        String url = jiraBaseUrl + "/rest/agile/1.0/board";
        HttpEntity<String> entity = new HttpEntity<>(createHeaders());
        ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.GET, entity, String.class);

        // Dodajemy logowanie
        System.out.println("Request URL: " + url);
        System.out.println("Response Status Code: " + response.getStatusCode());
        System.out.println("Response Body: " + response.getBody());

        return response.getBody();
    }

    // Pobieranie zadań z danej tablicy JIRA
    public String getIssuesFromBoard(int boardId) {
        String url = jiraBaseUrl + "/rest/agile/1.0/board/" + boardId + "/issue";
        HttpEntity<String> entity = new HttpEntity<>(createHeaders());
        ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.GET, entity, String.class);
        return response.getBody();
    }

    // Tworzenie nowego zgłoszenia
    public String createIssue(String projectKey, String summary, String description) {
        String url = jiraBaseUrl + "/rest/api/2/issue";
        JSONObject json = new JSONObject();
        json.put("fields", new JSONObject()
                .put("project", new JSONObject().put("key", projectKey))
                .put("summary", summary)
                .put("description", description)
                .put("issuetype", new JSONObject().put("name", "Task"))
        );

        HttpEntity<String> entity = new HttpEntity<>(json.toString(), createHeaders());
        ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.POST, entity, String.class);

        // Dodaj logowanie odpowiedzi
        System.out.println("Response Status Code: " + response.getStatusCode());
        System.out.println("Response Body: " + response.getBody());

        return response.getBody();
    }

//    // Metoda do wydobycia ID zgłoszenia z odpowiedzi
//    private String extractIssueId(String responseBody) {
//        try {
//            JSONObject responseJson = new JSONObject(responseBody);
//            return responseJson.getString("id");  // Pobieramy ID zgłoszenia
//        } catch (JSONException e) {
//            e.printStackTrace();
//            throw new RuntimeException("Nie udało się wydobyć ID zgłoszenia z odpowiedzi JIRA");
//        }
//    }
//
//    public String createIssue(String projectKey, String summary, String description, String selectedStatus) {
//        String url = jiraBaseUrl + "/rest/api/2/issue";
//
//        // Tworzenie zgłoszenia
//        JSONObject json = new JSONObject();
//        json.put("fields", new JSONObject()
//                .put("project", new JSONObject().put("key", projectKey))
//                .put("summary", summary)
//                .put("description", description)
//                .put("issuetype", new JSONObject().put("name", "Task"))
//        );
//
//        HttpEntity<String> entity = new HttpEntity<>(json.toString(), createHeaders());
//        ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.POST, entity, String.class);
//
//        // Logowanie odpowiedzi
//        System.out.println("Response Status Code: " + response.getStatusCode());
//        System.out.println("Response Body: " + response.getBody());
//
//        // Wydobycie ID zgłoszenia z odpowiedzi
//        String issueId = extractIssueId(response.getBody());
//
//        // Jeśli status nie jest "TO DO", zrób przejście
//        if (!selectedStatus.equals("TO DO")) {
//            transitionIssue(issueId, selectedStatus);
//        }
//
//        return response.getBody();
//    }
//
//    // Metoda do zmiany statusu zgłoszenia
//    private void transitionIssue(String issueId, String status) {
//        String transitionUrl = jiraBaseUrl + "/rest/api/2/issue/" + issueId + "/transitions";
//
//        // Zmapowanie statusu na odpowiednie przejście w JIRA
//        String transitionId = mapStatusToTransitionId(status);
//
//        JSONObject transitionJson = new JSONObject();
//        transitionJson.put("transition", new JSONObject().put("id", transitionId));
//
//        HttpEntity<String> entity = new HttpEntity<>(transitionJson.toString(), createHeaders());
//        ResponseEntity<String> response = restTemplate.exchange(transitionUrl, HttpMethod.POST, entity, String.class);
//
//        // Logowanie odpowiedzi
//        System.out.println("Transition Response Status Code: " + response.getStatusCode());
//        System.out.println("Transition Response Body: " + response.getBody());
//    }
//
//    // Mapa statusów do przejść w workflow JIRA
//    private String mapStatusToTransitionId(String status) {
//        switch (status) {
//            case "IN PROGRESS":
//                return "11";  // Identyfikator przejścia dla "IN PROGRESS"
//            case "DONE":
//                return "21";  // Identyfikator przejścia dla "DONE"
//            default:
//                throw new IllegalArgumentException("Invalid status: " + status);
//        }
//    }

//    public void changeIssueStatus(String issueId, String newStatus) {
//        String transitionUrl = jiraBaseUrl + "/rest/api/2/issue/" + issueId + "/transitions";
//
//        // Zmapowanie statusu na odpowiednie przejście w JIRA
//        String transitionId = mapStatusToTransitionId(newStatus);
//
//        if (transitionId == null) {
//            throw new RuntimeException("Invalid status provided.");
//        }
//
//        JSONObject transitionJson = new JSONObject();
//        transitionJson.put("transition", new JSONObject().put("id", transitionId));
//
//        HttpEntity<String> entity = new HttpEntity<>(transitionJson.toString(), createHeaders());
//        ResponseEntity<String> response = restTemplate.exchange(transitionUrl, HttpMethod.POST, entity, String.class);
//
//        // Logowanie odpowiedzi
//        System.out.println("Transition Response Status Code: " + response.getStatusCode());
//        System.out.println("Transition Response Body: " + response.getBody());
//    }

}

