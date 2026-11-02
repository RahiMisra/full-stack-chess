package com.example.chess.repository;

import com.example.chess.model.ChessPosition;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ChessPositionRepository extends JpaRepository<ChessPosition, Long> {

    Optional<ChessPosition> findByPositionKey(String positionKey);

}