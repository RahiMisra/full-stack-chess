package com.example.chess.service;

import com.example.chess.dto.PlayMoveRequest;
import com.example.chess.dto.PlayMoveResponse;
import com.example.chess.prolog.PrologChessService;
import com.example.chess.prolog.PrologResponse;

import org.springframework.stereotype.Service;

@Service
public class ChessStateService {

    private final PrologChessService prologChessService;

    public ChessStateService(PrologChessService prologChessService) {
        this.prologChessService = prologChessService;
    }

    public PlayMoveResponse playMove(PlayMoveRequest request) {

        PrologResponse result = prologChessService.playMove(
                request.fen(),
                request.san()
        );

        return new PlayMoveResponse(
                result.success(),
                result.newFen(),
                result.positionKey(),
                result.status(),
                result.advantage(),
                result.error()
        );
    }
}