import "./Chessboard.css";

function Chessboard() {
  const squares = Array(64).fill(null);

  return (
    <div className="chessboard">
      {squares.map((_, index) => {
        const row = Math.floor(index / 8);
        const column = index % 8;

        const isLight = (row + column) % 2 === 0;

        return (
          <div
            key={index}
            className={`square ${isLight ? "light" : "dark"}`}
          >
          </div>
        );
      })}
    </div>
  );
}

export default Chessboard;