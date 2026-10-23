package com.reborn.backend.api;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.reborn.backend.entry.EntryController;
import com.reborn.backend.entry.EntryService;
import com.reborn.backend.indexhistory.IndexHistoryController;
import com.reborn.backend.indexhistory.IndexHistoryService;
import com.reborn.backend.insight.InsightController;
import com.reborn.backend.insight.InsightService;
import com.reborn.backend.todo.TodoController;
import com.reborn.backend.todo.TodoService;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

@ExtendWith(MockitoExtension.class)
class CrudApiControllerTest {
    @Mock EntryService entries;
    @Mock TodoService todos;
    @Mock InsightService insights;
    @Mock IndexHistoryService indexHistory;

    @Test
    void entriesExposeFlutterFieldsAndRejectInvalidPayload() throws Exception {
        MockMvc mvc = MockMvcBuilders.standaloneSetup(new EntryController(entries)).build();
        when(entries.list("p-1", null)).thenReturn(List.of(entry()));
        mvc.perform(get("/api/entries").param("personId", "p-1"))
                .andExpect(status().isOk()).andExpect(jsonPath("$[0].emotion").value("joy"))
                .andExpect(jsonPath("$[0].intensity").value(2));
        mvc.perform(post("/api/entries").contentType("application/json")
                        .content("""
                                {"body":"","emotion":"joy","intensity":0,"score":9,"created_at":"2026-10-24T00:00:00Z","analysis_status":"pending"}
                                """))
                .andExpect(status().isBadRequest());
        verifyNoInteractions(todos, insights, indexHistory);
    }

    @Test
    void todosAcceptCreateAndExposeDoneFields() throws Exception {
        MockMvc mvc = MockMvcBuilders.standaloneSetup(new TodoController(todos)).build();
        when(todos.create(any(), any())).thenReturn(new TodoService.TodoResponse(
                "t-1", "전화하기", null, false, null, "manual", null,
                OffsetDateTime.parse("2026-10-24T00:00:00Z")));
        mvc.perform(post("/api/todos").contentType("application/json")
                        .content("""
                                {"title":"전화하기","done":false,"source":"manual","created_at":"2026-10-24T00:00:00Z"}
                                """))
                .andExpect(status().isCreated()).andExpect(jsonPath("$.done").value(false));
    }

    @Test
    void insightsCanBeSavedAndMarkedRead() throws Exception {
        MockMvc mvc = MockMvcBuilders.standaloneSetup(new InsightController(insights)).build();
        mvc.perform(put("/api/insights/i-1").contentType("application/json")
                        .content("""
                                {"type":"recovery","person_id":"p-1","message":"좋아졌어요","evidence_index_from":40,"evidence_index_to":55,"created_at":"2026-10-24T00:00:00Z","read":false}
                                """))
                .andExpect(status().isOk());
        mvc.perform(patch("/api/insights/i-1/read")).andExpect(status().isNoContent());
        verify(insights).markRead("i-1", null);
    }

    @Test
    void indexHistoryUsesDateAndScoreContract() throws Exception {
        MockMvc mvc = MockMvcBuilders.standaloneSetup(new IndexHistoryController(indexHistory)).build();
        when(indexHistory.list("p-1", LocalDate.parse("2026-10-01"), null)).thenReturn(List.of(
                new IndexHistoryService.IndexResponse("p-1", LocalDate.parse("2026-10-24"), 72, 3)));
        mvc.perform(get("/api/index-history").param("personId", "p-1").param("from", "2026-10-01"))
                .andExpect(status().isOk()).andExpect(jsonPath("$[0].index").value(72));
        mvc.perform(put("/api/index-history").contentType("application/json")
                        .content("""
                                {"person_id":"p-1","date":"2026-10-24","index":72,"entry_count":3}
                                """))
                .andExpect(status().isOk());
    }

    private EntryService.EntryResponse entry() {
        return new EntryService.EntryResponse("e-1", "기분이 좋았다", "p-1", "joy", 2, 2,
                OffsetDateTime.parse("2026-10-24T00:00:00Z"), "pending", List.of(), null);
    }
}
