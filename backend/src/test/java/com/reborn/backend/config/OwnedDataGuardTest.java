package com.reborn.backend.config;

import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.server.ResponseStatusException;

import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class OwnedDataGuardTest {
    private final JdbcTemplate jdbc = mock(JdbcTemplate.class);
    private final OwnedDataGuard guard = new OwnedDataGuard(jdbc);
    private final UUID userId = UUID.randomUUID();
    private final UUID recordId = UUID.randomUUID();

    @Test
    void permitsPersonOwnedByAuthenticatedUser() {
        when(jdbc.queryForObject(
                "select exists(select 1 from public.people where id = ? and user_id = ?)",
                Boolean.class, recordId, userId)).thenReturn(true);

        guard.requirePerson(recordId.toString(), userId);

        verify(jdbc).queryForObject(
                "select exists(select 1 from public.people where id = ? and user_id = ?)",
                Boolean.class, recordId, userId);
    }

    @Test
    void hidesPersonOwnedByAnotherUser() {
        when(jdbc.queryForObject(
                "select exists(select 1 from public.people where id = ? and user_id = ?)",
                Boolean.class, recordId, userId)).thenReturn(false);

        ResponseStatusException exception = assertThrows(ResponseStatusException.class,
                () -> guard.requirePerson(recordId.toString(), userId));

        assertEquals(HttpStatus.NOT_FOUND, exception.getStatusCode());
    }

    @Test
    void rejectsMalformedResourceIdsAsBadRequest() {
        ResponseStatusException exception = assertThrows(ResponseStatusException.class,
                () -> guard.requireInsight("not-a-uuid", userId));

        assertEquals(HttpStatus.BAD_REQUEST, exception.getStatusCode());
    }
}
