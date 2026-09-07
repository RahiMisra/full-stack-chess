package com.example.chess.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.chess.model.MoveNote;

public interface MoveNoteRepository extends JpaRepository<MoveNote, Long> {

}
