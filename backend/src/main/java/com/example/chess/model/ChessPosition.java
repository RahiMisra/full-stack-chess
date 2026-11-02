package com.example.chess.model;

import jakarta.persistence.*;

@Entity
@Table(name = "chess_positions")
public class ChessPosition {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "position_key", nullable = false, unique = true)
    private String positionKey;

    public ChessPosition() {
    }

    public ChessPosition(String positionKey) {
        this.positionKey = positionKey;
    }

    public Long getId() {
        return id;
    }

    public String getPositionKey() {
        return positionKey;
    }

    public void setPositionKey(String positionKey) {
        this.positionKey = positionKey;
    }
}