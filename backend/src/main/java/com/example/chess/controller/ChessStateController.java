
package com.example.chess.controller;

import com.example.chess.dto.PlaySanRequest;
import com.example.chess.dto.PlayCoordinatesRequest;
import com.example.chess.dto.PlayMoveResponse;
import com.example.chess.dto.LegalMovesRequest;
import com.example.chess.dto.LegalMovesResponse;
import com.example.chess.dto.PositionInfoRequest;
import com.example.chess.dto.PositionInfoResponse;

import com.example.chess.service.ChessStateService;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/chess")
public class ChessStateController {

    private final ChessStateService chessStateService;

    public ChessStateController(ChessStateService chessStateService) {
        this.chessStateService = chessStateService;
    }

    // Play a move using SAN notation.
    @PostMapping("/moves/san")
    public ResponseEntity<PlayMoveResponse> playSan(
            @RequestBody PlaySanRequest request) {

        if (request.fen() == null || request.fen().isBlank()
                || request.san() == null || request.san().isBlank()) {
            return ResponseEntity.badRequest().build();
        }

        PlayMoveResponse response = chessStateService.playSan(request);

        if (!response.success()) {
            return ResponseEntity
                    .status(HttpStatus.UNPROCESSABLE_CONTENT)
                    .body(response);
        }

        return ResponseEntity.ok(response);
    }

    // Play a move using board coordinates.
    @PostMapping("/moves/coordinates")
    public ResponseEntity<PlayMoveResponse> playCoordinates(
            @RequestBody PlayCoordinatesRequest request) {

        if (request.fen() == null || request.fen().isBlank()
                || request.from() == null || request.from().isBlank()
                || request.to() == null || request.to().isBlank()) {
            return ResponseEntity.badRequest().build();
        }

        PlayMoveResponse response = chessStateService.playCoordinates(request);

        if (!response.success()) {
            return ResponseEntity
                    .status(HttpStatus.UNPROCESSABLE_CONTENT)
                    .body(response);
        }

        return ResponseEntity.ok(response);
    }

    // Find all legal moves for a selected square.
    @PostMapping("/moves/legal")
    public ResponseEntity<LegalMovesResponse> getLegalMoves(
            @RequestBody LegalMovesRequest request) {

        if (request.fen() == null || request.fen().isBlank()
                || request.square() == null || request.square().isBlank()) {
            return ResponseEntity.badRequest().build();
        }

        LegalMovesResponse response = chessStateService.getLegalMoves(request);

        if (!response.success()) {
            return ResponseEntity
                    .status(HttpStatus.UNPROCESSABLE_CONTENT)
                    .body(response);
        }

        return ResponseEntity.ok(response);
    }

    // Get information about a chess position.
    @PostMapping("/position-info")
    public ResponseEntity<PositionInfoResponse> getPositionInfo(
            @RequestBody PositionInfoRequest request) {

        if (request.fen() == null || request.fen().isBlank()) {
            return ResponseEntity.badRequest().build();
        }

        PositionInfoResponse response = chessStateService.getPositionInfo(request);

        if (!response.success()) {
            return ResponseEntity
                    .status(HttpStatus.UNPROCESSABLE_CONTENT)
                    .body(response);
        }

        return ResponseEntity.ok(response);
    }
}
