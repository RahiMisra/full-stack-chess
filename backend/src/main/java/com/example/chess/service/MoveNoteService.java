package com.example.chess.service;

import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

import com.example.chess.model.MoveNote;
import com.example.chess.repository.MoveNoteRepository;

@Service
public class MoveNoteService {

	private final MoveNoteRepository repository;
	
	public MoveNoteService(MoveNoteRepository repository) {
	    this.repository = repository;
	}
	
	public List<MoveNote> getAllNotes() {
	    return repository.findAll();
	}
	
	public Optional<MoveNote> getNoteById(Long id) {
	    return repository.findById(id);
	}
	
	public MoveNote createNote(MoveNote note) {
	    return repository.save(note);
	}
	
	public MoveNote updateNote(Long id, MoveNote updatedNote) {
	    MoveNote existingNote = repository.findById(id)
	            .orElseThrow();

	    if (updatedNote.getMove() != null && !updatedNote.getMove().isEmpty()) {
	        existingNote.setMove(updatedNote.getMove());
	    }

	    if (updatedNote.getNote() != null && !updatedNote.getNote().isEmpty()) {
	        existingNote.setNote(updatedNote.getNote());
	    }

	    return repository.save(existingNote);
	}
	
	public void deleteNote(Long id) {
	    repository.deleteById(id);
	}
	
}
