import './App.css';

import { useState } from "react";

import NotePanel from "./components/NotePanel";
import ChessPanel from "./components/ChessPanel";

const INITIAL_POSITION = {
  fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
  positionKey: "",
  status: "Not evaluated",
  advantage: "Not evaluated",
  move: "Starting Position",
};

function App() {
  const [position, setPosition] = useState(INITIAL_POSITION);

  return (
    <div>
      <h1>Chess Notes</h1>
      <div className="main-layout">

        <div className="note-area">
          <NotePanel position = {position}/>
        </div>

        <div className="chess-area">
          <ChessPanel
            position = {position}
            onSelectPosition = {setPosition}
          />
        </div>

      </div>
    </div>
  );
}

export default App;