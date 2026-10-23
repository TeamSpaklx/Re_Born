package com.reborn.backend.api;

import java.time.OffsetDateTime;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class ApiExceptionHandler {
    @ExceptionHandler(IllegalArgumentException.class)
    public ApiError badRequest(IllegalArgumentException e) {
        return new ApiError(OffsetDateTime.now(), 400, "VALIDATION_ERROR", e.getMessage(), Map.of());
    }

    public record ApiError(OffsetDateTime timestamp, int status, String code, String message, Map<String,Object> details) {}
}
