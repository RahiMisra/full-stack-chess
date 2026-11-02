package com.example.chess.prolog;

public record ChessPositionResponse(
        boolean success,
        String newFen,
        String positionKey,
        String status,
        Integer advantage,
        String error
) {}