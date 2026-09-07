package com.example.chess.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

import com.example.chess.model.MoveNote;
import com.example.chess.service.MoveNoteService;

@RestController
@RequestMapping("/api/notes")
public class MoveNoteController {
	
	private final MoveNoteService service;
	
	public MoveNoteController(MoveNoteService service) {
        this.service = service;
    }
	
	@GetMapping
	public List<MoveNote> getAllNotes() {
	    return service.getAllNotes();
	}
	
	@GetMapping("/{id}")
	public ResponseEntity<MoveNote> getNoteById(@PathVariable Long id) {
	    return service.getNoteById(id)
	            .map(ResponseEntity::ok)
	            .orElseGet(() -> ResponseEntity.notFound().build());
	}
	
	@PostMapping
	public MoveNote createNote(@RequestBody MoveNote note) {
	    return service.createNote(note);
	}
	
	@PutMapping("/{id}")
	public ResponseEntity<MoveNote> updateNote(
	        @PathVariable Long id,
	        @RequestBody MoveNote note) {

	    try {
	        return ResponseEntity.ok(service.updateNote(id, note));
	    } catch (Exception e) {
	        return ResponseEntity.notFound().build();
	    }
	}
	
	@DeleteMapping("/{id}")
	public ResponseEntity<Void> deleteNote(@PathVariable Long id) {
	    service.deleteNote(id);
	    return ResponseEntity.noContent().build();
	}
}
