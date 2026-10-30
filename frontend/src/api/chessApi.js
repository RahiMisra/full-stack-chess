const API_URL = import.meta.env.VITE_API_URL;

export async function playMove(fen, san) {
    const response = await fetch(`${API_URL}/api/chess/moves`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify({ fen, san }),
    });

    const result = await response.json();

    if (!response.ok) {
        throw new Error(result.error || `Request failed: ${response.status}`);
    }

    if (!result.success) {
        throw new Error(result.error || "The move was rejected.");
    }

    return result;
}
