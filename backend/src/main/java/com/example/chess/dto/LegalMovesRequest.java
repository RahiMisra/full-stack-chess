package com.example.chess.dto;

public record LegalMovesRequest(
		String fen,
		String square
) {}

