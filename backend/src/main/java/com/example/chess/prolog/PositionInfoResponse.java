package com.example.chess.prolog;

import java.util.List;

public record PositionInfoResponse(
		boolean success,
	    String positionKey,
	    String status,
	    Integer advantage,
	    String sideToMove,
		List<String> castlingRights,
		String enPassantTarget,
	    String error
) {}
