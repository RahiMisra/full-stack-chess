import { useState } from "react";
import { playMove } from "../api/chessApi";
import ChessboardArea from "./ChessboardArea";
import MoveHistory from "./MoveHistory";
import "./ChessPanel.css";

function ChessPanel( {position, onSelectPosition} ) {
  const [fenInput, setFenInput] = useState(position.fen);
  const [sanInput, setSanInput] = useState("");
  const [message, setMessage] = useState("");
  const [loading, setLoading] = useState(false);

  const [history, setHistory] = useState([position]);
  const [currentIndex, setCurrentIndex] = useState(0);

  function handleSelectPosition(index) {
    const position = history[index];
    setCurrentIndex(index);
    onSelectPosition(position);
    setFenInput(position.fen);
    setMessage("");
  }

  function handleSetFen() {
    if (!fenInput.trim()) {
      setMessage("Enter a FEN position.");
      return;
    }

    const newPosition = {
      fen: fenInput.trim(),
      positionKey: "",
      status: "Not evaluated",
      advantage: "Not evaluated",
      move: "Starting Position",
    };

    setHistory([newPosition]);
    setCurrentIndex(0);
    onSelectPosition(newPosition);
    setFenInput(newPosition.fen);
    setMessage("Position updated.");
  }

  async function handleSubmitMove() {
    if (!sanInput.trim()) {
      setMessage("Enter a SAN move.");
      return;
    }

    setLoading(true);
    setMessage("");

    try {
      const data = await playMove(position.fen, sanInput.trim());

      const nextPosition = {
        fen: data.newFen,
        positionKey: data.positionKey,
        status: data.status,
        advantage: data.advantage,
        move: sanInput.trim(),
      };

      const updatedHistory = [
        ...history.slice(0, currentIndex + 1),
        nextPosition,
      ];

      setHistory(updatedHistory);
      setCurrentIndex(updatedHistory.length - 1);
      onSelectPosition(nextPosition);
      setFenInput(data.newFen);
      setSanInput("");
      setMessage("Move applied successfully.");
    } catch (error) {
      setMessage(error.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="chess-panel">
      <MoveHistory
        history={history}
        currentIndex={currentIndex}
        onSelectPosition={handleSelectPosition}
      />

      <div className="chess-display">
        <div className="chess-input">

          <h3>Set Position</h3>
          <textarea
            value={fenInput}
            onChange={(e) => setFenInput(e.target.value)}
            placeholder="Enter FEN..."
          />
          <button onClick={handleSetFen}>
            Set FEN
          </button>

          <h3>Make Move</h3>
          <input
            value={sanInput}
            onChange={(e) => setSanInput(e.target.value)}
            placeholder="Enter SAN (e.g. e4)"
          />
          <button onClick={handleSubmitMove} disabled={loading}>
            {loading ? "Submitting..." : "Submit Move"}
          </button>

          <p>{message}</p>
        </div>

        <div className="chessboard-area">
          <ChessboardArea fen={position.fen} />
        </div>

        <div className="position-info">
          <p>Status: {position.status}</p>
          <p>Advantage: {position.advantage}</p>
        </div>
      </div>
    </div>
  );
}

export default ChessPanel;