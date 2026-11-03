package com.example.chess.service;

import com.example.chess.dto.PositionNoteResponse;
import com.example.chess.model.ChessPosition;
import com.example.chess.model.PositionNote;
import com.example.chess.prolog.PositionInfoResponse;
import com.example.chess.repository.ChessPositionRepository;
import com.example.chess.repository.PositionNoteRepository;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.NoSuchElementException;

@Service
public class PositionNoteService {

    private final ChessStateService chessStateService;
    private final ChessPositionRepository chessPositionRepository;
    private final PositionNoteRepository positionNoteRepository;

    public PositionNoteService(
            ChessStateService chessStateService,
            ChessPositionRepository chessPositionRepository,
            PositionNoteRepository positionNoteRepository
    ) {
        this.chessStateService = chessStateService;
        this.chessPositionRepository = chessPositionRepository;
        this.positionNoteRepository = positionNoteRepository;
    }

    // Retrieve all notes associated with a chess position.
    @Transactional(readOnly = true)
    public List<PositionNoteResponse> getNotes(String fen) {

        PositionInfoResponse positionInfo =
                chessStateService.getPositionInfo(fen);

        if (!positionInfo.success()) {
            throw new IllegalArgumentException(positionInfo.error());
        }

        return chessPositionRepository
                .findByPositionKey(positionInfo.positionKey())
                .map(position -> positionNoteRepository
                        .findByPosition(position)
                        .stream()
                        .map(this::toResponse)
                        .toList())
                .orElse(List.of());
    }

    // Create a note associated with a chess position.
    @Transactional
    public PositionNoteResponse createNote(String fen, String note) {

        if (note == null || note.isBlank()) {
            throw new IllegalArgumentException("Note cannot be empty.");
        }

        PositionInfoResponse positionInfo =
                chessStateService.getPositionInfo(fen);

        if (!positionInfo.success()) {
            throw new IllegalArgumentException(positionInfo.error());
        }

        ChessPosition position = chessPositionRepository
                .findByPositionKey(positionInfo.positionKey())
                .orElseGet(() -> chessPositionRepository.save(
                        new ChessPosition(positionInfo.positionKey())
                ));

        PositionNote newNote = new PositionNote(position, note);
        PositionNote savedNote = positionNoteRepository.save(newNote);

        return toResponse(savedNote);
    }

    // Update the content of an existing note.
    @Transactional
    public PositionNoteResponse updateNote(Long id, String note) {

        if (note == null || note.isBlank()) {
            throw new IllegalArgumentException("Note cannot be empty.");
        }

        PositionNote existingNote = positionNoteRepository
                .findById(id)
                .orElseThrow(() -> new NoSuchElementException("Note not found."));

        existingNote.setNote(note);

        PositionNote updatedNote = positionNoteRepository.save(existingNote);

        return toResponse(updatedNote);
    }

    // Delete a note and remove its position if it has no remaining notes.
    @Transactional
    public void deleteNote(Long id) {

        PositionNote existingNote = positionNoteRepository
                .findById(id)
                .orElseThrow(() -> new NoSuchElementException("Note not found."));

        ChessPosition position = existingNote.getPosition();

        positionNoteRepository.delete(existingNote);

        // Delete the position only if this was its last note.
        if (positionNoteRepository.findByPosition(position).isEmpty()) {
            chessPositionRepository.delete(position);
        }
    }

    // Convert a database entity into a response DTO.
    private PositionNoteResponse toResponse(PositionNote note) {
        return new PositionNoteResponse(
                note.getId(),
                note.getNote()
        );
    }
}