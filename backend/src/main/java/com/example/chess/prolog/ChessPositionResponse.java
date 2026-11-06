package com.example.chess.prolog;

import java.util.List;

public record ChessPositionResponse(
        boolean success,
        String newFen,
        String positionKey,
        String status,
        Integer advantage,
        String san,
		String moveType,
		String sideToMove,
		List<String> castlingRights,
		String enPassantTarget,
        String error
) {}