import { useEffect, useState } from 'react';

function App() {
  const [notes, setNotes] = useState([]);
  const [move, setMove] = useState('');
  const [note, setNote] = useState('');
  const [selectedNote, setSelectedNote] = useState(null);
  const [searchId, setSearchId] = useState('');

  // GET all notes
  function getNotes() {
    if (notes.length > 0) {
        setNotes([]);
        return;
    }

    fetch('http://localhost:8080/api/notes')
        .then(response => response.json())
        .then(data => setNotes(data));
}

  // GET note by id
  function getNote(id) {
  fetch(`http://localhost:8080/api/notes/${id}`)
    .then(response => {
      if (!response.ok) {
        setSelectedNote(null);
        return null;
      }

      return response.json();
    })
    .then(data => {
      if (data) {
        setSelectedNote(data);
      }
    });
}

  // POST - create a note
  function createNote() {
    fetch('http://localhost:8080/api/notes', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        move: move,
        note: note
      })
    })
      .then(response => response.json())
      .then(data => {
        console.log('Created:', data);
        setMove('');
        setNote('');
      });
  }

  // PUT - update a note
  function updateNote(id) {
    fetch(`http://localhost:8080/api/notes/${id}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        move: 'Nf3',
        note: 'Updated note.'
      })
    })
      .then(response => response.json())
      .then(data => {
        console.log('Updated:', data);
      });
  }

  // DELETE - delete a note
  function deleteNote(id) {
    fetch(`http://localhost:8080/api/notes/${id}`, {
      method: 'DELETE'
    })
      .then(() => {
        console.log('Deleted:', id);
      });
  }

  useEffect(() => {
    getNotes();
  }, []);

  return (
    <div>
      <h1>Chess Notes</h1>

      <input
        type="text"
        placeholder="Move"
        value={move}
        onChange={event => setMove(event.target.value)}
      />

      <input
        type="text"
        placeholder="Note"
        value={note}
        onChange={event => setNote(event.target.value)}
      />

      <button onClick={createNote}>
        Add Note
      </button>

      <input
        type="text"
        placeholder="Note ID"
        value={searchId}
        onChange={event => setSearchId(event.target.value)}
      />

      <button onClick={() => getNote(searchId)}>
        Get Note
      </button>

      {selectedNote && (
        <div>
          <h2>{selectedNote.move}</h2>
          <p>{selectedNote.note}</p>
          <p>{selectedNote.id}</p>
        </div>
      )}

      <button onClick={getNotes}>
        {notes.length > 0 ? 'Hide All Notes' : 'Get All Notes'}
      </button>

      {notes.map(note => (
        <div key={note.id}>
          <h2>{note.move}</h2>
          <p>{note.note}</p>
          <p>{note.id}</p>

          <button onClick={() => getNote(note.id)}>
            Get
          </button>

          <button onClick={() => updateNote(note.id)}>
            Update
          </button>

          <button onClick={() => deleteNote(note.id)}>
            Delete
          </button>
        </div>
      ))}
    </div>
  );
}

export default App;