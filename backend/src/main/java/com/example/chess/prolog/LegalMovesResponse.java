package com.example.chess.prolog;

import java.util.List;

public record LegalMovesResponse(
	    List<LegalMoveResponse> moves
) {}