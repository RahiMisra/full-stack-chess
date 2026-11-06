package com.example.chess.dto;

public record PlayCoordinatesRequest(
		String fen,
        String from,
        String to,
        String promotion
){}
