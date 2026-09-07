package com.example.chess.controller;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import com.jayway.jsonpath.JsonPath;

@SpringBootTest
@AutoConfigureMockMvc
public class MoveNoteControllerTest {
	@Autowired
    private MockMvc mockMvc;

	@Test
    void createNote() throws Exception {

        mockMvc.perform(post("/api/notes")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "move": "e4",
                        "note": "Controls the center."
                    }
                    """))
                .andExpect(status().isOk());
    }

    @Test
    void getAllNotes() throws Exception {

        mockMvc.perform(get("/api/notes"))
                .andExpect(status().isOk());
    }

    @Test
    void getNoteById() throws Exception {

        // Create a note first
        String response = mockMvc.perform(post("/api/notes")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "move": "d4",
                        "note": "Controls the center."
                    }
                    """))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();

        // Get the ID that PostgreSQL generated
        String id = JsonPath.read(response, "$.id").toString();

        // Get the note by ID
        mockMvc.perform(get("/api/notes/" + id))
                .andExpect(status().isOk());
    }

    @Test
    void updateNote() throws Exception {

        // Create a note first
        String response = mockMvc.perform(post("/api/notes")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "move": "e4",
                        "note": "Initial note."
                    }
                    """))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();

        // Get the generated ID
        String id = JsonPath.read(response, "$.id").toString();

        // Update the note
        mockMvc.perform(put("/api/notes/" + id)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "move": "e4",
                        "note": "Updated note about controlling the center."
                    }
                    """))
                .andExpect(status().isOk());
    }

    @Test
    void deleteNote() throws Exception {

        // Create a note first
        String response = mockMvc.perform(post("/api/notes")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "move": "c4",
                        "note": "A flexible opening move."
                    }
                    """))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();

        // Get the generated ID
        String id = JsonPath.read(response, "$.id").toString();

        // Delete the note
        mockMvc.perform(delete("/api/notes/" + id))
                .andExpect(status().isNoContent());

        // Confirm the note no longer exists
        mockMvc.perform(get("/api/notes/" + id))
                .andExpect(status().isNotFound());
    }
}
