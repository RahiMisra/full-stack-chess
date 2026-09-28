import "./Browse.css";

function Browse() {
  const notes = [
    { id: 1, move: "e4", preview: "Controls the center..." },
    { id: 2, move: "Nf3", preview: "Develops the knight..." },
    { id: 3, move: "d4", preview: "Challenges the center..." }
  ];

  return (
    <div className="browse-notes">
      <h2>Browse Notes</h2>

      <div className="notes-list">
        {notes.map(note => (
          <div key={note.id} className="note-preview">
            <strong>{note.move}</strong>
            <p>{note.preview}</p>
          </div>
        ))}
      </div>
    </div>
  );
}

export default Browse;