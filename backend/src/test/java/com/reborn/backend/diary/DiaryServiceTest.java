package com.reborn.backend.diary;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.sql.ResultSet;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;

@ExtendWith(MockitoExtension.class)
class DiaryServiceTest {
    @Mock JdbcTemplate jdbc;
    @Mock DiaryAiService aiService;

    private DiaryService service;
    private final UUID userId = UUID.fromString("57f07421-2056-4c62-85a5-28d9d453b534");
    private final UsernamePasswordAuthenticationToken authentication =
            new UsernamePasswordAuthenticationToken(userId.toString(), "token", List.of());

    @BeforeEach
    void setUp() {
        service = new DiaryService(jdbc, aiService);
    }

    @Test
    void listAppliesInclusiveFromAndExclusiveToAndOrdersByCreationTime() {
        OffsetDateTime from = OffsetDateTime.parse("2026-10-01T00:00:00Z");
        OffsetDateTime to = OffsetDateTime.parse("2026-11-01T00:00:00Z");
        when(jdbc.query(anyString(), any(RowMapper.class), any(Object[].class))).thenReturn(List.of());

        assertThat(service.list(from, to, authentication)).isEmpty();

        ArgumentCaptor<String> sql = ArgumentCaptor.forClass(String.class);
        ArgumentCaptor<Object[]> args = ArgumentCaptor.forClass(Object[].class);
        verify(jdbc).query(sql.capture(), any(RowMapper.class), args.capture());
        assertThat(sql.getValue()).contains("created_at >= ?", "created_at < ?", "order by created_at desc");
        assertThat(args.getValue()).containsExactly(userId, from, to);
    }

    @Test
    void listWithoutDatesDoesNotConstrainTime() {
        when(jdbc.query(anyString(), any(RowMapper.class), any(Object[].class))).thenReturn(List.of());

        assertThat(service.list(null, null, authentication)).isEmpty();

        ArgumentCaptor<String> sql = ArgumentCaptor.forClass(String.class);
        verify(jdbc).query(sql.capture(), any(RowMapper.class), any(Object[].class));
        assertThat(sql.getValue()).doesNotContain("created_at >=", "created_at <");
    }
}
