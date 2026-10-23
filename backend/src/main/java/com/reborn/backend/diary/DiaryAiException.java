package com.reborn.backend.diary;

import org.springframework.http.HttpStatus;

public class DiaryAiException extends RuntimeException {
    private final HttpStatus status;
    private final String code;
    private final Integer upstreamStatus;
    private final String upstreamBody;

    public DiaryAiException(HttpStatus status, String code, String message) {
        this(status, code, message, null, null, null);
    }

    public DiaryAiException(HttpStatus status, String code, String message,
                            Integer upstreamStatus, String upstreamBody, Throwable cause) {
        super(message, cause);
        this.status = status;
        this.code = code;
        this.upstreamStatus = upstreamStatus;
        this.upstreamBody = upstreamBody;
    }

    public HttpStatus status() {
        return status;
    }

    public String code() {
        return code;
    }

    public Integer upstreamStatus() {
        return upstreamStatus;
    }

    public String upstreamBody() {
        return upstreamBody;
    }
}
