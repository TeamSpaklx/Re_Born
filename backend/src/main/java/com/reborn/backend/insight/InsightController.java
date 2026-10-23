package com.reborn.backend.insight;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import jakarta.validation.constraints.Pattern;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.OffsetDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/insights")
public class InsightController {
    private final InsightService service;
    public InsightController(InsightService service) { this.service = service; }

    @GetMapping public List<InsightService.InsightResponse> list(@RequestParam(required = false) String personId,
                                                                  Authentication auth) {
        return service.list(personId, auth);
    }
    @GetMapping("/{id}") public InsightService.InsightResponse get(@PathVariable String id, Authentication auth) {
        return service.get(id, auth);
    }
    @PutMapping("/{id}") public void save(@PathVariable String id, @Valid @RequestBody InsightRequest request,
                                           Authentication auth) { service.save(id, request, auth); }
    @PatchMapping("/{id}/read") @ResponseStatus(HttpStatus.NO_CONTENT)
    public void markRead(@PathVariable String id, Authentication auth) { service.markRead(id, auth); }
    @DeleteMapping @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@RequestParam(required = false) String personId, Authentication auth) {
        if (personId == null) service.deleteAll(auth); else service.deleteForPerson(personId, auth);
    }

    public record InsightRequest(@NotBlank @Pattern(regexp = "negative_trend|recovery") String type,
                                 @NotBlank String person_id,
                                 @NotBlank @Size(max = 500) String message,
                                 @Min(0) @Max(100) int evidence_index_from,
                                 @Min(0) @Max(100) int evidence_index_to,
                                 @Min(0) Integer evidence_neg_count,
                                 @NotNull OffsetDateTime created_at, boolean read) {}
}
