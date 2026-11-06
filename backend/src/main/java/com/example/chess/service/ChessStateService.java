
package com.example.chess.service;

import java.util.List;

import com.example.chess.dto.PlaySanRequest;
import com.example.chess.dto.PlayCoordinatesRequest;
import com.example.chess.dto.PlayMoveResponse;
import com.example.chess.dto.LegalMovesRequest;
import com.example.chess.dto.LegalMovesResponse;
import com.example.chess.dto.LegalMoveResponse;
import com.example.chess.dto.PositionInfoRequest;
import com.example.chess.dto.PositionInfoResponse;

import com.example.chess.prolog.PrologChessService;
import com.example.chess.prolog.ChessPositionResponse;

import org.springframework.stereotype.Service;

@Service
public class ChessStateService {

    private final PrologChessService prologChessService;

    public ChessStateService(PrologChessService prologChessService) {
        this.prologChessService = prologChessService;
    }

    // Play a move using SAN notation.
    public PlayMoveResponse playSan(PlaySanRequest request) {

        ChessPositionResponse result = prologChessService.playSan(
                request.fen(),
                request.san()
        );

        return new PlayMoveResponse(
                result.success(),
                result.newFen(),
                result.positionKey(),
                result.status(),
                result.advantage(),
                result.san(),
                result.moveType(),
                result.sideToMove(),
                result.castlingRights(),
                result.enPassantTarget(),
                result.error()
        );
    }

    // Play a move using board coordinates.
    public PlayMoveResponse playCoordinates(
            PlayCoordinatesRequest request
    ) {

        ChessPositionResponse result =
                prologChessService.playCoordinates(
                        request.fen(),
                        request.from(),
                        request.to(),
                        request.promotion()
                );

        return new PlayMoveResponse(
                result.success(),
                result.newFen(),
                result.positionKey(),
                result.status(),
                result.advantage(),
                result.san(),
                result.moveType(),
                result.sideToMove(),
                result.castlingRights(),
                result.enPassantTarget(),
                result.error()
        );
    }

    // Retrieve information about a chess position.
    public PositionInfoResponse getPositionInfo(
            PositionInfoRequest request
    ) {

        com.example.chess.prolog.PositionInfoResponse result =
                prologChessService.getPositionInfo(request.fen());

        return new PositionInfoResponse(
                result.success(),
                result.positionKey(),
                result.status(),
                result.advantage(),
                result.sideToMove(),
                result.castlingRights(),
                result.enPassantTarget(),
                result.error()
        );
    }

    // Retrieve legal moves for a selected square.
    public LegalMovesResponse getLegalMoves(
            LegalMovesRequest request
    ) {

        com.example.chess.prolog.LegalMovesResponse result =
                prologChessService.getLegalMoves(
                        request.fen(),
                        request.square()
                );

        List<LegalMoveResponse> moves = result.moves().stream()
                .map(move -> new LegalMoveResponse(
                        move.from(),
                        move.to(),
                        move.moveType(),
                        move.promotion()
                ))
                .toList();

        return new LegalMovesResponse(
                true,
                moves,
                null
        );
    }
}
