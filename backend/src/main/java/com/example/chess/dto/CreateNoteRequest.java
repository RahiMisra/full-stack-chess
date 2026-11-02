package com.example.chess.dto;

public record CreateNoteRequest(
    String fen,
    String note
) {}