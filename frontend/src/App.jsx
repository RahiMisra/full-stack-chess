import './App.css';

import NotePanel from "./components/NotePanel";
import ChessPanel from "./components/ChessPanel";

import { useState } from 'react';
import { playMove } from "./api/chessApi";

const API_URL = import.meta.env.VITE_API_URL;
const INITIAL_POSITION = {
  fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
  positionKey: "",
  status: "Active",
  advantage: "Equal",
};

function App() {
  const [position, setPosition] = useState(INITIAL_POSITION);

  return (
    <div>
      <h1>Chess Notes</h1>
      <div className="main-layout">

        <div className="note-area">
          <NotePanel />
        </div>

        <div className="chess-area">
          <ChessPanel
            position={position}
            setPosition={setPosition}
          />
        </div>

      </div>
    </div>
  );
}

export default App;