
package com.example.chess.prolog;

import tools.jackson.databind.json.JsonMapper;
import org.springframework.stereotype.Service;

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

    public PrologResponse playMove(String fen, String san) {
        Objects.requireNonNull(fen, "FEN cannot be null");
        Objects.requireNonNull(san, "SAN move cannot be null");

        Map<String, String> request = Map.of(
                "action", "play_move",
                "fen", fen,
                "san", san
        );

        // Convert the Java request into JSON.
        String requestJson = jsonMapper.writeValueAsString(request);

        // Send it to the running Prolog process.
        String responseJson =
                processManager.sendRequest(requestJson);

        // Convert Prolog's JSON response into a Java object.
        return jsonMapper.readValue(
                responseJson,
                PrologResponse.class
        );
    }
}
