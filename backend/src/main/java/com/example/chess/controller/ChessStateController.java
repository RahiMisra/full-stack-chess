package com.example.chess.controller;

import com.example.chess.dto.PlayMoveRequest;
import com.example.chess.dto.PlayMoveResponse;
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

    @PostMapping("/moves")
    public ResponseEntity<PlayMoveResponse> playMove(
            @RequestBody PlayMoveRequest request) {

        if (request.fen() == null || request.fen().isBlank() || request.san() == null || request.san().isBlank()) {
            return ResponseEntity.badRequest().build();
        }

        PlayMoveResponse response = chessStateService.playMove(request);

        if (!response.success()) {
            return ResponseEntity.status(HttpStatus.UNPROCESSABLE_CONTENT).body(response);
        }

        return ResponseEntity.ok(response);
    }
}