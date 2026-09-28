import './App.css';
import Search from "./components/Search.jsx";
import Browse from "./components/Browse.jsx";
import Note from "./components/Note.jsx"
import Line from "./components/Line.jsx"
import Chessboard from "./components/Chessboard.jsx";

import { useState } from 'react';

const API_URL = import.meta.env.VITE_API_URL;

function App() {

  return (
    <div>
      <h1>Chess Notes</h1>
      <div className="main-layout">

        <div className="search-area">
          <Search />
        </div>

        <div className="browse-area">
          <Browse />
        </div>

        <div className="note-area">
          <Note />
        </div>

        <div className="line-area">
          <Line />
        </div>

        <div className="board-area">
          <Chessboard />
        </div>

      </div>
    </div>
  );
}

export default App;