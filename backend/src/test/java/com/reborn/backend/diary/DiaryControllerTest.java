package com.reborn.backend.diary;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.OffsetDateTime;
import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

@ExtendWith(MockitoExtension.class)
class DiaryControllerTest {
    @Mock DiaryService service;

    private MockMvc mvc;

    @BeforeEach
    void setUp() {
        mvc = MockMvcBuilders.standaloneSetup(new DiaryController(service)).build();
    }

    @Test
    void listParsesAndPassesDateRange() throws Exception {
        when(service.list(any(), any(), any())).thenReturn(List.of());

        mvc.perform(get("/api/diaries")
                        .param("from", "2026-10-01T00:00:00Z")
                        .param("to", "2026-11-01T00:00:00Z"))
                .andExpect(status().isOk());

        verify(service).list(
                eq(OffsetDateTime.parse("2026-10-01T00:00:00Z")),
                eq(OffsetDateTime.parse("2026-11-01T00:00:00Z")), any());
    }

    @Test
    void listRejectsInvalidDate() throws Exception {
        mvc.perform(get("/api/diaries").param("from", "not-a-date"))
                .andExpect(status().isBadRequest());
        verifyNoInteractions(service);
    }

    @Test
    void listRejectsReversedOrEmptyRange() throws Exception {
        mvc.perform(get("/api/diaries")
                        .param("from", "2026-11-01T00:00:00Z")
                        .param("to", "2026-10-01T00:00:00Z"))
                .andExpect(status().isBadRequest());
        mvc.perform(get("/api/diaries")
                        .param("from", "2026-10-01T00:00:00Z")
                        .param("to", "2026-10-01T00:00:00Z"))
                .andExpect(status().isBadRequest());
        verifyNoInteractions(service);
    }
}
