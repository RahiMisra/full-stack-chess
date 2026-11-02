package com.example.chess.repository;

import com.example.chess.model.ChessPosition;
import com.example.chess.model.PositionNote;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PositionNoteRepository extends JpaRepository<PositionNote, Long> {

    List<PositionNote> findByPosition(ChessPosition position);

}