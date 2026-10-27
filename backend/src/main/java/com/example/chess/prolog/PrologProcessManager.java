package com.example.chess.prolog;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.nio.charset.StandardCharsets;
import java.nio.file.Path;

@Component
public class PrologProcessManager {

    @Value("${chess.prolog.script}")
    private String scriptPath;

    private Process process;
    private BufferedWriter writer;
    private BufferedReader reader;

    @PostConstruct
    public void start() {
        try {
            ProcessBuilder builder = new ProcessBuilder("swipl", "-q", "-s", Path.of(scriptPath).toAbsolutePath().toString());

            // Show Prolog errors in the Java application's console.
            builder.redirectError(ProcessBuilder.Redirect.INHERIT);

            process = builder.start();

            writer = new BufferedWriter(new OutputStreamWriter(process.getOutputStream(), StandardCharsets.UTF_8));

            reader = new BufferedReader(new InputStreamReader(process.getInputStream(), StandardCharsets.UTF_8));

        } catch (IOException e) {
            throw new IllegalStateException(
                    "Failed to start the SWI-Prolog process.", e
            );
        }
    }

    public synchronized String sendRequest(String request) {
        if (process == null || !process.isAlive()) {
            throw new IllegalStateException(
                    "The SWI-Prolog process is not running."
            );
        }

        try {
            // Send one JSON request.
            writer.write(request);
            writer.newLine();
            writer.flush();

            // Read the corresponding JSON response.
            String response = reader.readLine();

            if (response == null) {
                throw new IllegalStateException(
                        "The SWI-Prolog process closed its output stream."
                );
            }

            return response;

        } catch (IOException e) {
            throw new IllegalStateException(
                    "Failed to communicate with the SWI-Prolog process.", e
            );
        }
    }

    @PreDestroy
    public void stop() {
        try {
            if (writer != null) {
                writer.close();
            }
        } catch (IOException e) {
            // Continue shutting down even if closing the input stream fails.
        }

        if (process != null && process.isAlive()) {
            process.destroy();
        }
    }
}