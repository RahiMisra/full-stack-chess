import { useState } from "react";
import "./NotePanel.css";

const SAMPLE_NOTES = [
  {
    id: 1,
    title: "Opening idea",
    content:
      "Control the center early. Develop knights before moving the same piece multiple times.",
  },
  {
    id: 2,
    title: "King's safety",
    content:
      "Remember to castle before launching an attack. An exposed king can become a major weakness.",
  },
  {
    id: 3,
    title: "Tactical pattern",
    content:
      "Look for pins and discovered attacks when the opponent's pieces are aligned.",
  },
  {
    id: 4,
    title: "Endgame reminder",
    content:
      "Activate the king in the endgame. The king becomes an important attacking piece when fewer pieces remain.",
  },
];

function NotePanel({ position }) {
  const [notes] = useState(SAMPLE_NOTES);
  const [selectedNoteId, setSelectedNoteId] = useState(SAMPLE_NOTES[0].id);

  const selectedNote = notes.find(
    (note) => note.id === selectedNoteId
  );

  return (
    <div className="note-panel">
      <section className="notes-list-section">
        <h2>Notes</h2>

        <div className="notes-list">
          {notes.map((note) => (
            <button
              key={note.id}
              className={`note-list-item ${
                selectedNoteId === note.id ? "selected" : ""
              }`}
              onClick={() => setSelectedNoteId(note.id)}
            >
              {note.title}
            </button>
          ))}
        </div>
      </section>

      <section className="selected-note-section">
        <h2>Selected Note</h2>

        {selectedNote ? (
          <div className="selected-note">
            <h3>{selectedNote.title}</h3>
            <p>{selectedNote.content}</p>
          </div>
        ) : (
          <p className="empty-note-message">
            Select a note to view its contents.
          </p>
        )}
      </section>
    </div>
  );
}

export default NotePanel;