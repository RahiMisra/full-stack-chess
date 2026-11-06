
import { useState, useEffect, useRef } from "react";
import { Chessboard, defaultPieces } from "react-chessboard";
import { getLegalMoves } from "../api/chessApi";
import "./ChessboardArea.css";

function ChessboardArea({
  fen,
  sideToMove,
  onMove,
  loading,
  onError,
}) {
  const [selectedSquare, setSelectedSquare] = useState(null);
  const [legalMoves, setLegalMoves] = useState([]);
  const [pendingPromotion, setPendingPromotion] = useState(null);
  const [checkingMoves, setCheckingMoves] = useState(false);
  const legalMovesRequest = useRef(null);

  useEffect(() => {
    setSelectedSquare(null);
    setLegalMoves([]);
    setPendingPromotion(null);
    setCheckingMoves(false);
    legalMovesRequest.current = null;
  }, [fen]);

  function isCurrentPlayerPiece(pieceType) {
    if (!pieceType) return false;
    return sideToMove === "white"
      ? pieceType.startsWith("w")
      : pieceType.startsWith("b");
  }

  async function fetchLegalMoves(square) {
    if (
      legalMovesRequest.current?.fen === fen &&
      legalMovesRequest.current?.square === square
    ) {
      return legalMovesRequest.current.promise;
    }
    setCheckingMoves(true);
    const request = {
      fen,
      square,
      promise: null,
    };
    const promise = getLegalMoves(fen, square)
      .then((data) => {
        if (legalMovesRequest.current === request) {
          setLegalMoves(data.moves);
        }
        return data.moves;
      })
      .catch((error) => {
        if (legalMovesRequest.current === request) {
          setLegalMoves([]);
          onError?.(error);
        }
        return [];
      })
      .finally(() => {
        if (legalMovesRequest.current === request) {
          setCheckingMoves(false);
          legalMovesRequest.current = null;
        }
      });
    request.promise = promise;
    legalMovesRequest.current = request;
    return promise;
  }

  async function selectPiece({ piece, square }) {
    if (!square || !piece || !isCurrentPlayerPiece(piece.pieceType)) {
      return;
    }
    setSelectedSquare(square);
    setLegalMoves([]);
    await fetchLegalMoves(square);
  }

  async function handleSquareClick({ square, piece }) {
    if (loading || checkingMoves || pendingPromotion) return;
    if (!selectedSquare) {
      if (piece) {
        await selectPiece({ piece, square });
      }
      return;
    }
    if (square === selectedSquare) {
      setSelectedSquare(null);
      setLegalMoves([]);
      return;
    }
    if (piece && isCurrentPlayerPiece(piece.pieceType)) {
      await selectPiece({ piece, square });
      return;
    }
    await handleMoveAttempt(selectedSquare, square);
  }

  function handlePieceDrag({ piece, square }) {
    if (loading || pendingPromotion) return;
    selectPiece({ piece, square });
  }

  async function handleMoveAttempt(from, to, pieceType = null) {
    if (loading || pendingPromotion) return;
    let availableMoves = legalMoves;
    if (!availableMoves.length || selectedSquare !== from) {
      availableMoves = await fetchLegalMoves(from);
    }
    const matchingMoves = availableMoves.filter(
      (move) => move.to === to
    );
    if (matchingMoves.length === 0) {
      setSelectedSquare(null);
      setLegalMoves([]);
      return;
    }
    const promotionMoves = matchingMoves.filter(
      (move) => move.promotion !== null
    );
    if (promotionMoves.length > 0) {
      setPendingPromotion({
        from,
        to,
        color: pieceType?.[0] === "b" ? "b" : "w",
        moves: promotionMoves,
      });

      setSelectedSquare(null);
      return;
    }
    setSelectedSquare(null);
    setLegalMoves([]);
    onMove(from, to);
  }

  function handlePieceDrop({ piece, sourceSquare, targetSquare }) {
    if (!targetSquare || loading || pendingPromotion) {
      return false;
    }
    if (!isCurrentPlayerPiece(piece.pieceType)) {
      return false;
    }
    handleMoveAttempt(
      sourceSquare,
      targetSquare,
      piece.pieceType
    );
    return false;
  }

  function handlePromotion(promotion) {
    if (!pendingPromotion || loading) return;
    const { from, to, moves } = pendingPromotion;
    const validPromotion = moves.some(
      (move) => move.promotion === promotion
    );
    if (!validPromotion) return;
    setPendingPromotion(null);
    setLegalMoves([]);
    onMove(from, to, promotion);
  }

  function clearSelection() {
    setSelectedSquare(null);
    setLegalMoves([]);
  }

  const promotionFileIndex = pendingPromotion
    ? pendingPromotion.to.charCodeAt(0) - "a".charCodeAt(0)
    : 0;

  const promotionAtTop = pendingPromotion?.to[1] === "8";

  const promotionPieces = [
    { value: "queen", symbol: "Q", label: "Queen" },
    { value: "rook", symbol: "R", label: "Rook" },
    { value: "knight", symbol: "N", label: "Knight" },
    { value: "bishop", symbol: "B", label: "Bishop" },
  ];

  const squareStyles = {};

  if (selectedSquare) {
    squareStyles[selectedSquare] = {
      backgroundColor: "rgba(255, 215, 0, 0.55)",
    };
  }

  for (const move of legalMoves) {
    squareStyles[move.to] = {
      background:
        move.moveType === "capture"
          ? "radial-gradient(transparent 55%, rgba(220, 50, 50, 0.45) 56%)"
          : "radial-gradient(rgba(40, 40, 40, 0.3) 18%, transparent 19%)",
    };
  }

  const chessboardOptions = {
    id: "chess-notes-board",
    position: fen,
    allowDragging: !loading && !pendingPromotion,
    canDragPiece: ({ piece }) =>
      !loading &&
      !pendingPromotion &&
      isCurrentPlayerPiece(piece.pieceType),
    onSquareClick: handleSquareClick,
    onPieceDrag: handlePieceDrag,
    onPieceDrop: handlePieceDrop,
    squareStyles,
  };

  return (
    <div className="chessboard-container">
      <Chessboard options={chessboardOptions} />

      {pendingPromotion && (
        <div
          className="promotion-overlay"
          onClick={() => setPendingPromotion(null)}
        >
          <div
            className={`promotion-menu ${
              promotionAtTop
                ? "promotion-menu-top"
                : "promotion-menu-bottom"
            }`}
            style={{
              "--promotion-file": promotionFileIndex,
            }}
            onClick={(event) => event.stopPropagation()}
          >
            {promotionPieces.map(({ value, symbol, label }) => {
              const pieceKey = `${pendingPromotion.color}${symbol}`;

              return (
                <button
                  key={value}
                  className="promotion-piece"
                  onClick={() => handlePromotion(value)}
                  disabled={loading}
                  aria-label={`Promote to ${label}`}
                  title={label}
                >
                  {defaultPieces[pieceKey]()}
                </button>
              );
            })}
          </div>
        </div>
      )}
    </div>
  );
}

export default ChessboardArea;
