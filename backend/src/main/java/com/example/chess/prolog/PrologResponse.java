package com.example.chess.prolog;

public record PrologResponse(
        boolean success,
        String newFen,
        String positionKey,
        String status,
        Integer advantage,
        String error
) {}