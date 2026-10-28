package com.example.chess.dto;

public record PlayMoveRequest(
        String fen,
        String san
) {}
