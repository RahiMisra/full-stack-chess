package com.example.chess.controller;

import com.example.chess.dto.CreateNoteRequest;
import com.example.chess.dto.PositionNoteResponse;
import com.example.chess.service.PositionNoteService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/positions/notes")
public class PositionNoteController {

    private final PositionNoteService positionNoteService;

    public PositionNoteController(PositionNoteService positionNoteService) {
        this.positionNoteService = positionNoteService;
    }

    @GetMapping
    public ResponseEntity<List<PositionNoteResponse>> getNotes(@RequestParam String fen) {
    	if (fen == null || fen.isBlank()) {
    	    return ResponseEntity.badRequest().build();
    	}

        try {
            List<PositionNoteResponse> notes =
                    positionNoteService.getNotes(fen);

            return ResponseEntity.ok(notes);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @PostMapping
    public ResponseEntity<PositionNoteResponse> createNote(
            @RequestBody CreateNoteRequest request) {
    	
    	if (request.fen() == null || request.fen().isBlank() || request.note() == null || request.note().isBlank()) {
            return ResponseEntity.badRequest().build();
        }

        try {
            PositionNoteResponse createdNote =
                    positionNoteService.createNote(
                            request.fen(),
                            request.note()
                    );

            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(createdNote);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        }
    }
}