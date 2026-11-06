
package com.example.chess.prolog;

import tools.jackson.databind.json.JsonMapper;
import org.springframework.stereotype.Service;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Objects;

@Service
public class PrologChessService {

    private final PrologProcessManager processManager;
    private final JsonMapper jsonMapper;

    public PrologChessService(
            PrologProcessManager processManager,
            JsonMapper jsonMapper
    ) {
        this.processManager = processManager;
        this.jsonMapper = jsonMapper;
    }

    // Play a move using SAN notation.
    public ChessPositionResponse playSan(String fen, String san) {
        Objects.requireNonNull(fen, "FEN cannot be null");
        Objects.requireNonNull(san, "SAN move cannot be null");

        Map<String, Object> request = Map.of(
                "action", "play_san",
                "fen", fen,
                "san", san
        );

        return sendMoveRequest(request);
    }

    // Play a move using board coordinates.
    public ChessPositionResponse playCoordinates(String fen, String from, String to, String promotion) {
        Objects.requireNonNull(fen, "FEN cannot be null");
        Objects.requireNonNull(from, "Source square cannot be null");
        Objects.requireNonNull(to, "Destination square cannot be null");

        Map<String, Object> request = new LinkedHashMap<>();
        request.put("action", "play_coordinates");
        request.put("fen", fen);
        request.put("from", from);
        request.put("to", to);
        request.put("promotion", promotion);

        return sendMoveRequest(request);
    }

    // Shared JSON communication with Prolog.
    private ChessPositionResponse sendMoveRequest(Map<String, ?> request) {
        // Convert the Java request into JSON.
        String requestJson = jsonMapper.writeValueAsString(request);

        // Send it to the running Prolog process.
        String responseJson =
                processManager.sendRequest(requestJson);

        // Convert Prolog's JSON response into a Java object.
        return jsonMapper.readValue(
                responseJson,
                ChessPositionResponse.class
        );
    }

    public PositionInfoResponse getPositionInfo(String fen) {
        Objects.requireNonNull(fen, "FEN cannot be null");

        Map<String, String> request = Map.of(
                "action", "get_position_info",
                "fen", fen
        );

        String requestJson = jsonMapper.writeValueAsString(request);

        String responseJson =
                processManager.sendRequest(requestJson);

        return jsonMapper.readValue(
                responseJson,
                PositionInfoResponse.class
        );
    }
    
    public LegalMovesResponse getLegalMoves(String fen, String square) {
        Objects.requireNonNull(fen, "FEN cannot be null");
        Objects.requireNonNull(square, "Square cannot be null");

        Map<String, String> request = Map.of(
                "action", "get_legal_moves",
                "fen", fen,
                "square", square
        );

        String requestJson = jsonMapper.writeValueAsString(request);
        String responseJson =
                processManager.sendRequest(requestJson);
        return jsonMapper.readValue(
                responseJson,
                LegalMovesResponse.class
        );
    }
}
