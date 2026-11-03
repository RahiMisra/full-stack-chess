import { useEffect, useState } from "react";
import { createNote, getNotes } from "../api/noteApi";
import "./NotePanel.css";

function NotePanel({ position }) {
    const [notes, setNotes] = useState([]);
    const [selectedNoteId, setSelectedNoteId] = useState(null);
    const [newNote, setNewNote] = useState("");
    const [isLoading, setIsLoading] = useState(false);
    const [isSaving, setIsSaving] = useState(false);
    const [error, setError] = useState("");
    const [success, setSuccess] = useState("");

    const fen = position?.fen;

    useEffect(() => {
        if (!fen) {
            setNotes([]);
            setSelectedNoteId(null);
            return;
        }

        let cancelled = false;

        async function loadNotes() {
            setIsLoading(true);
            setError("");
            setSuccess("");
            setNotes([]);
            setSelectedNoteId(null);

            try {
                const result = await getNotes(fen);

                if (!cancelled) {
                    setNotes(result);
                    setSelectedNoteId(result.length > 0 ? result[0].id : null);
                }
            } catch (err) {
                if (!cancelled) {
                    setError(err.message || "Failed to load notes.");
                }
            } finally {
                if (!cancelled) {
                    setIsLoading(false);
                }
            }
        }

        loadNotes();

        return () => {
            cancelled = true;
        };
    }, [fen]);

    const selectedNote = notes.find(
        (note) => note.id === selectedNoteId
    );

    async function handleSaveNote(event) {
        event.preventDefault();

        if (!newNote.trim()) {
            setError("Please enter a note.");
            setSuccess("");
            return;
        }

        if (!fen) {
            setError("No chess position is selected.");
            setSuccess("");
            return;
        }

        setIsSaving(true);
        setError("");
        setSuccess("");

        try {
            const savedNote = await createNote(fen, newNote.trim());

            setNotes((currentNotes) => [...currentNotes, savedNote]);
            setSelectedNoteId(savedNote.id);
            setNewNote("");
            setSuccess("Note saved successfully.");
        } catch (err) {
            setError(err.message || "Failed to save note.");
        } finally {
            setIsSaving(false);
        }
    }

    return (
        <div className="note-panel">
            <section className="notes-list-section">
                <h2>Notes for This Position</h2>

                {isLoading ? (
                    <p>Loading notes...</p>
                ) : notes.length > 0 ? (
                    <div className="notes-list">
                        {notes.map((note) => (
                            <button
                                key={note.id}
                                type="button"
                                className={`note-list-item ${
                                    selectedNoteId === note.id ? "selected" : ""
                                }`}
                                onClick={() => setSelectedNoteId(note.id)}
                            >
                                {note.note}
                            </button>
                        ))}
                    </div>
                ) : (
                    !error && (
                        <p className="empty-note-message">
                            No notes for this position yet.
                        </p>
                    )
                )}
            </section>

            <section className="selected-note-section">
                <h2>Selected Note</h2>

                {selectedNote ? (
                    <div className="selected-note">
                        <p>{selectedNote.note}</p>
                    </div>
                ) : (
                    <p className="empty-note-message">
                        Select a note to view its contents.
                    </p>
                )}
            </section>

            <section className="create-note-section">
                <h2>New Note</h2>

                <form onSubmit={handleSaveNote}>
                    <textarea
                        value={newNote}
                        onChange={(event) => setNewNote(event.target.value)}
                        placeholder="Write a note about this position..."
                        rows={4}
                        disabled={isSaving}
                    />

                    <button type="submit" disabled={isSaving || !fen}>
                        {isSaving ? "Saving..." : "Save Note"}
                    </button>
                </form>

                {error && <p className="note-error">{error}</p>}
                {success && <p className="note-success">{success}</p>}
            </section>
        </div>
    );
}

export default NotePanel;