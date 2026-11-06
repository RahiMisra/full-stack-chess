package com.example.chess.dto;

public record PlaySanRequest(
        String fen,
        String san
) {}
