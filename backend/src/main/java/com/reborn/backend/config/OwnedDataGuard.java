package com.reborn.backend.config;

import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ResponseStatusException;

import java.util.UUID;

@Component
public class OwnedDataGuard {
    private final JdbcTemplate jdbc;

    public OwnedDataGuard(JdbcTemplate jdbc) { this.jdbc = jdbc; }

    public void requirePerson(String rawId, UUID userId) {
        if (rawId == null || rawId.isBlank()) return;
        UUID personId = parseId(rawId);
        Boolean owned = jdbc.queryForObject(
                "select exists(select 1 from public.people where id = ? and user_id = ?)",
                Boolean.class, personId, userId);
        if (!Boolean.TRUE.equals(owned)) throw new ResponseStatusException(HttpStatus.NOT_FOUND);
    }

    public void requireInsight(String rawId, UUID userId) {
        if (rawId == null || rawId.isBlank()) return;
        UUID insightId = parseId(rawId);
        Boolean owned = jdbc.queryForObject(
                "select exists(select 1 from public.insights where id = ? and user_id = ?)",
                Boolean.class, insightId, userId);
        if (!Boolean.TRUE.equals(owned)) throw new ResponseStatusException(HttpStatus.NOT_FOUND);
    }

    private UUID parseId(String rawId) {
        try {
            return UUID.fromString(rawId);
        } catch (IllegalArgumentException exception) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid resource id");
        }
    }
}
