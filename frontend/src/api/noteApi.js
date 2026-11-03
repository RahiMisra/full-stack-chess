
const API_URL = import.meta.env.VITE_API_URL;

export async function getNotes(fen) {
    const params = new URLSearchParams({ fen });

    const response = await fetch(
        `${API_URL}/api/positions/notes?${params.toString()}`
    );

    const result = await response.json();

    if (!response.ok) {
        throw new Error(
            result.error || `Request failed: ${response.status}`
        );
    }

    return result;
}

export async function createNote(fen, note) {
    const response = await fetch(`${API_URL}/api/positions/notes`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({ fen, note })
    });

    const result = await response.json();

    if (!response.ok) {
        throw new Error(
            result.error || `Request failed: ${response.status}`
        );
    }

    return result;
}

export async function updateNote(id, note) {
    const response = await fetch(`${API_URL}/api/positions/notes/${id}`, {
        method: "PUT",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({ note })
    });

    const result = await response.json();

    if (!response.ok) {
        throw new Error(
            result.error || `Request failed: ${response.status}`
        );
    }

    return result;
}

export async function deleteNote(id) {
    const response = await fetch(`${API_URL}/api/positions/notes/${id}`, {
        method: "DELETE"
    });

    if (!response.ok) {
        throw new Error(`Request failed: ${response.status}`);
    }
}
