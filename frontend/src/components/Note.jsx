import "./Note.css"
import { useState } from "react";

function Note() {
  const [note, setNote] = useState("");

  function handlePublish() {
    console.log("Publishing note:", note);
  }

  return (
    <div className="note">
      <h2>Notes / Analysis</h2>

      <textarea
        placeholder="Write your analysis..."
        value={note}
        onChange={event => setNote(event.target.value)}
      />

      <button onClick={handlePublish}>
        Publish Note
      </button>
    </div>
  );
}

export default Note;