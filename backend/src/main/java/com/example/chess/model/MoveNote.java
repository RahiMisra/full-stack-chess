package com.example.chess.model;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Column;

// tells jpa to map to database table
@Entity
public class MoveNote {
	
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;
	
	private String move;
	
	@Column(columnDefinition = "TEXT")
	private String note;
	
	private Long getId() {
		return id;
	}

	private void setId(Long id) {
		this.id = id;
	}

	private String getMove() {
		return move;
	}

	private void setMove(String move) {
		this.move = move;
	}

	private String getNote() {
		return note;
	}

	private void setNote(String note) {
		this.note = note;
	}
	
}
