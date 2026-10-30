import { Chessboard } from "react-chessboard";
import "./ChessboardArea.css";

function ChessboardArea({ fen }) {
  const chessboardOptions = {
    position: fen,
    id: "chess-notes-board",
  };

  return (
    <div className="chessboard-container">
      <Chessboard options={chessboardOptions} />
    </div>
  );
}

export default ChessboardArea;