package com.example.chess.dto;

public record PlayMoveResponse(
        boolean success,
        String newFen,
        String positionKey,
        String status,
        Integer advantage,
        String error
) {}