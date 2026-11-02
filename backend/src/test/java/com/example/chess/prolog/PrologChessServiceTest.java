package com.example.chess.prolog;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
class PrologChessServiceTest {

    @Autowired
    private PrologChessService prologChessService;

    @Test
    void getPositionInfoReturnsPositionKey() {

        String fen =
                "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";

        PositionInfoResponse result =
                prologChessService.getPositionInfo(fen);

        assertTrue(result.success());
        assertNotNull(result.positionKey());
        assertFalse(result.positionKey().isBlank());

        System.out.println(result);
    }
} 