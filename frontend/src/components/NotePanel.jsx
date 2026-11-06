
import { useEffect, useState } from "react";
import {
    createNote,
    getNotes,
    updateNote,
    deleteNote
} from "../api/noteApi";
import "./NotePanel.css";

function NotePanel({ position }) {
    const [notes, setNotes] = useState([]);
    const [selectedNoteId, setSelectedNoteId] = useState(null);
    const [newNote, setNewNote] = useState("");
    const [editContent, setEditContent] = useState("");
    const [isEditing, setIsEditing] = useState(false);
    const [isLoading, setIsLoading] = useState(false);
    const [isSaving, setIsSaving] = useState(false);
    const [isUpdating, setIsUpdating] = useState(false);
    const [isDeleting, setIsDeleting] = useState(false);

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
            setIsEditing(false);

            try {
                const result = await getNotes(fen);

                if (!cancelled) {
                    setNotes(result);
                    setSelectedNoteId(
                        result.length > 0 ? result[0].id : null
                    );
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

    function handleSelectNote(id) {
        setSelectedNoteId(id);
        setIsEditing(false);
        setError("");
        setSuccess("");
    }

    function handleStartEdit() {
        if (!selectedNote) return;

        setEditContent(selectedNote.note);
        setIsEditing(true);
        setError("");
        setSuccess("");
    }

    function handleCancelEdit() {
        setIsEditing(false);
        setEditContent("");
        setError("");
    }

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
            setIsEditing(false);
            setSuccess("Note saved successfully.");
        } catch (err) {
            setError(err.message || "Failed to save note.");
        } finally {
            setIsSaving(false);
        }
    }

    async function handleUpdateNote(event) {
        event.preventDefault();

        if (!editContent.trim()) {
            setError("Note cannot be empty.");
            setSuccess("");
            return;
        }

        if (!selectedNote) return;

        setIsUpdating(true);
        setError("");
        setSuccess("");

        try {
            const updatedNote = await updateNote(
                selectedNote.id,
                editContent.trim()
            );

            setNotes((currentNotes) =>
                currentNotes.map((note) =>
                    note.id === updatedNote.id ? updatedNote : note
                )
            );

            setIsEditing(false);
            setSuccess("Note updated successfully.");
        } catch (err) {
            setError(err.message || "Failed to update note.");
        } finally {
            setIsUpdating(false);
        }
    }

    async function handleDeleteNote() {
        if (!selectedNote) return;

        const confirmed = window.confirm(
            "Are you sure you want to delete this note?"
        );

        if (!confirmed) return;

        setIsDeleting(true);
        setError("");
        setSuccess("");

        try {
            await deleteNote(selectedNote.id);

            const remainingNotes = notes.filter(
                (note) => note.id !== selectedNote.id
            );

            setNotes(remainingNotes);
            setSelectedNoteId(
                remainingNotes.length > 0 ? remainingNotes[0].id : null
            );

            setIsEditing(false);
            setEditContent("");
            setSuccess("Note deleted successfully.");
        } catch (err) {
            setError(err.message || "Failed to delete note.");
        } finally {
            setIsDeleting(false);
        }
    }

    const isBusy = isSaving || isUpdating || isDeleting;

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
                                onClick={() => handleSelectNote(note.id)}
                                disabled={isBusy}
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
                    isEditing ? (
                        <form onSubmit={handleUpdateNote}>
                            <textarea
                                value={editContent}
                                onChange={(event) =>
                                    setEditContent(event.target.value)
                                }
                                rows={4}
                                disabled={isUpdating}
                            />

                            <div className="note-actions">
                                <button type="submit" disabled={isUpdating}>
                                    {isUpdating ? "Updating..." : "Save Changes"}
                                </button>

                                <button
                                    type="button"
                                    onClick={handleCancelEdit}
                                    disabled={isUpdating}
                                >
                                    Cancel
                                </button>
                            </div>
                        </form>
                    ) : (
                        <>
                            <div className="selected-note">
                                <p>{selectedNote.note}</p>
                            </div>

                            <div className="note-actions">
                                <button
                                    type="button"
                                    onClick={handleStartEdit}
                                    disabled={isBusy}
                                >
                                    Edit
                                </button>

                                <button
                                    type="button"
                                    onClick={handleDeleteNote}
                                    disabled={isBusy}
                                >
                                    {isDeleting ? "Deleting..." : "Delete"}
                                </button>
                            </div>
                        </>
                    )
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
                        disabled={isSaving || isBusy}
                    />

                    <button type="submit" disabled={isSaving || !fen || isBusy}>
                        {isSaving ? "Saving..." : "Save Note"}
                    </button>
                </form>
            </section>

            {error && <p className="note-error">{error}</p>}
            {success && <p className="note-success">{success}</p>}
        </div>
    );
}

export default NotePanel;
