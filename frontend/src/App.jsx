import { useEffect, useState } from 'react';

function App() {
  const [notes, setNotes] = useState([]);

  // GET all notes
  function getNotes() {
    fetch('http://localhost:8080/api/notes')
      .then(response => response.json())
      .then(data => setNotes(data));
  }

  // GET note by id
  function getNote(id) {
    fetch(`http://localhost:8080/api/notes/${id}`)
      .then(response => response.json())
      .then(data => console.log('Single note:', data));
  }

  // POST - create a note
  function createNote() {
    fetch('http://localhost:8080/api/notes', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        move: 'Nf3',
        note: 'Develops the knight.'
      })
    })
      .then(response => response.json())
      .then(data => {
        console.log('Created:', data);
        getNotes();
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
        getNotes();
      });
  }

  // DELETE - delete a note
  function deleteNote(id) {
    fetch(`http://localhost:8080/api/notes/${id}`, {
      method: 'DELETE'
    })
      .then(() => {
        console.log('Deleted:', id);
        getNotes();
      });
  }

  useEffect(() => {
    getNotes();
  }, []);

  return (
    <div>
      <h1>Chess Notes</h1>

      <button onClick={createNote}>
        Create Test Note
      </button>

      {notes.map(note => (
        <div key={note.id}>
          <h2>{note.move}</h2>
          <p>{note.note}</p>

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