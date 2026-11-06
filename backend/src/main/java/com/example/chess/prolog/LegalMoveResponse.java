package com.example.chess.prolog;

public record LegalMoveResponse(
	    String from,
	    String to,
	    String moveType,
	    String promotion
) {}
