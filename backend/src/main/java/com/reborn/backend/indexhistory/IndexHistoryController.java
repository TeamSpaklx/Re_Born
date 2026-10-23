package com.reborn.backend.indexhistory;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/index-history")
public class IndexHistoryController {
    private final IndexHistoryService service;
    public IndexHistoryController(IndexHistoryService service) { this.service = service; }

    @GetMapping public List<IndexHistoryService.IndexResponse> list(@RequestParam String personId,
            @RequestParam(required = false) LocalDate from, Authentication auth) {
        return service.list(personId, from, auth);
    }
    @PutMapping public void upsert(@Valid @RequestBody IndexRequest request, Authentication auth) {
        service.upsert(request, auth);
    }
    @DeleteMapping("/{personId}/{date}") @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable String personId, @PathVariable LocalDate date, Authentication auth) {
        service.delete(personId, date, auth);
    }
    @DeleteMapping @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@RequestParam(required = false) String personId, Authentication auth) {
        if (personId == null) service.deleteAll(auth); else service.deleteForPerson(personId, auth);
    }

    public record IndexRequest(@NotNull String person_id, @NotNull LocalDate date,
                               @Min(0) @Max(100) int index, @Min(0) int entry_count) {}
}
