package com.example.chess.model;

import jakarta.persistence.*;

@Entity
@Table(name = "position_notes")
public class PositionNote {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "position_id", nullable = false)
    private ChessPosition position;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String note;

    public PositionNote() {
    }

    public PositionNote(ChessPosition position, String note) {
        this.position = position;
        this.note = note;
    }

    public Long getId() {
        return id;
    }

    public ChessPosition getPosition() {
        return position;
    }

    public void setPosition(ChessPosition position) {
        this.position = position;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }
}