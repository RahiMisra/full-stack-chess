package com.example.chess.dto;

import java.util.List;

public record LegalMovesResponse(
    boolean success,
    List<LegalMoveResponse> moves,
    String error
) {}