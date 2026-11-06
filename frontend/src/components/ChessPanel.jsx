import { useState } from "react";
import {
  playSan,
  playCoordinates,
  getPositionInfo,
} from "../api/chessApi";

import ChessboardArea from "./ChessboardArea";
import MoveHistory from "./MoveHistory";
import "./ChessPanel.css";

function ChessPanel({ position, onSelectPosition }) {
  const [fenInput, setFenInput] = useState(position.fen);
  const [sanInput, setSanInput] = useState("");
  const [message, setMessage] = useState("");
  const [loading, setLoading] = useState(false);

  const [history, setHistory] = useState([position]);
  const [currentIndex, setCurrentIndex] = useState(0);

  function handleSelectPosition(index) {
    const selectedPosition = history[index];
    setCurrentIndex(index);
    onSelectPosition(selectedPosition);
    setFenInput(selectedPosition.fen);
    setMessage("");
  }

  function createPosition(data, fen, move, moveType) {
    return {
      fen,
      positionKey: data.positionKey,
      status: data.status,
      advantage: data.advantage,
      sideToMove: data.sideToMove,
      castlingRights: data.castlingRights,
      enPassantTarget: data.enPassantTarget,
      move,
      moveType,
    };
  }

  async function handleSetFen() {
    const fen = fenInput.trim();
    if (!fen) {
      setMessage("Enter a FEN position.");
      return;
    }
    setLoading(true);
    setMessage("");
    try {
      const data = await getPositionInfo(fen);
      const newPosition = createPosition(
        data,
        fen,
        "Custom Position",
        null
      );
      setHistory([newPosition]);
      setCurrentIndex(0);
      onSelectPosition(newPosition);
      setFenInput(fen);
      setMessage("Position updated.");
    } catch (error) {
      setMessage(error.message);
    } finally {
      setLoading(false);
    }
  }

  async function handleSanMove() {
    if (!sanInput.trim()) {
      setMessage("Enter a SAN move.");
      return;
    }
    if (loading) return;
    setLoading(true);
    setMessage("");
    try {
      const data = await playSan(position.fen, sanInput.trim());
      recordMove(data);
      setSanInput("");
      setMessage("Move applied successfully.");
    } catch (error) {
      setMessage(error.message);
    } finally {
      setLoading(false);
    }
  }

  async function handleCoordinateMove(from, to, promotion = null) {
    if (loading) return;
    setLoading(true);
    setMessage("");
    try {
      const data = await playCoordinates(
        position.fen,
        from,
        to,
        promotion
      );
      recordMove(data);
      setMessage("Move applied successfully.");
    } catch (error) {
      setMessage(error.message);
    } finally {
      setLoading(false);
    }
  }

  function recordMove(data) {
    const nextPosition = createPosition(
      data,
      data.newFen,
      data.san,
      data.moveType
    );
    const updatedHistory = [
      ...history.slice(0, currentIndex + 1),
      nextPosition,
    ];
    setHistory(updatedHistory);
    setCurrentIndex(updatedHistory.length - 1);
    onSelectPosition(nextPosition);
    setFenInput(nextPosition.fen);
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

          <button onClick={handleSetFen} disabled={loading}>
            {loading ? "Loading..." : "Set FEN"}
          </button>

          <h3>Make Move</h3>

          <input
            value={sanInput}
            onChange={(e) => setSanInput(e.target.value)}
            placeholder="Enter SAN (e.g. e4)"
          />

          <button onClick={handleSanMove} disabled={loading}>
            {loading ? "Submitting..." : "Submit Move"}
          </button>

          <p>{message}</p>
        </div>

        <div className="chessboard-area">
          <ChessboardArea
            fen={position.fen}
            sideToMove={position.sideToMove}
            onMove={handleCoordinateMove}
            loading={loading}
            onError={(error) => setMessage(error.message)}
          />
        </div>

        <div className="position-info">
          <p>Status: {position.status}</p>
          <p>Advantage: {position.advantage}</p>
          <p>Side to move: {position.sideToMove}</p>
          <p>
            Castling rights:{" "}
            {position.castlingRights?.length
              ? position.castlingRights.join(", ")
              : "None"}
          </p>
          <p>
            En passant target: {position.enPassantTarget ?? "None"}
          </p>
        </div>
      </div>
    </div>
  );
}

export default ChessPanel;