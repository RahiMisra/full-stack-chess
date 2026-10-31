import "./MoveHistory.css";

function MoveHistory({ history, currentIndex, onSelectPosition }) {
  return (
    <div className="move-history">
      <div className="move-list">
        {history.map((entry, index) => (
          <button
            key={index}
            className={`history-move ${
              currentIndex === index ? "selected" : ""
            }`}
            onClick={() => onSelectPosition(index)}
          >
            {entry.move}
          </button>
        ))}
      </div>
    </div>
  );
}

export default MoveHistory;