package com.example.chess.prolog;

public record PositionInfoResponse(
		boolean success,
	    String positionKey,
	    String status,
	    Integer advantage,
	    String error
) {}
