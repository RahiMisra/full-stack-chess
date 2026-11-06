const API_URL = import.meta.env.VITE_API_URL;

async function sendChessRequest(endpoint, body) {
    const response = await fetch(`${API_URL}${endpoint}`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify(body),
    });

    const result = await response.json();

    if (!response.ok) {
        throw new Error(result.error || `Request failed: ${response.status}`);
    }

    if (!result.success) {
        throw new Error(result.error || "The request was rejected.");
    }

    return result;
}

export async function playSan(fen, san) {
    return sendChessRequest("/api/chess/moves/san", {
        fen,
        san,
    });
}

export async function playCoordinates(fen, from, to, promotion = null) {
    return sendChessRequest("/api/chess/moves/coordinates", {
        fen,
        from,
        to,
        promotion,
    });
}

export async function getPositionInfo(fen) {
    return sendChessRequest("/api/chess/position-info", {
        fen,
    });
}

export async function getLegalMoves(fen, square) {
    return sendChessRequest("/api/chess/moves/legal", {
        fen,
        square,
    });
}