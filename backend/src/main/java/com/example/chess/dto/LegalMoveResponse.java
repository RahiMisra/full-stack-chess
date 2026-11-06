package com.example.chess.dto;

public record LegalMoveResponse(
	    String from,
	    String to,
	    String moveType,
	    String promotion
) {}