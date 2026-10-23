package com.reborn.backend.config;

import com.reborn.backend.diary.DiaryAiException;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.OffsetDateTime;

@RestControllerAdvice
public class ApiExceptionHandler {
    @ExceptionHandler(DiaryAiException.class)
    public ResponseEntity<ErrorResponse> handleDiaryAiException(DiaryAiException exception) {
        ErrorResponse response = new ErrorResponse(
                OffsetDateTime.now().toString(),
                exception.status().value(),
                exception.code(),
                exception.getMessage(),
                exception.upstreamStatus(),
                exception.upstreamBody());
        return ResponseEntity.status(exception.status()).body(response);
    }

    public record ErrorResponse(
            String timestamp,
            int status,
            String code,
            String message,
            Integer upstreamStatus,
            String upstreamBody) {}
}
