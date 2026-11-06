package com.example.chess.dto;

import java.util.List;

public record PlayMoveResponse(
		boolean success,
		String newFen,
		String positionKey,
		String status,
		int advantage,
		String san,
		String moveType,
		String sideToMove,
		List<String> castlingRights,
		String enPassantTarget,
		String error
) {}