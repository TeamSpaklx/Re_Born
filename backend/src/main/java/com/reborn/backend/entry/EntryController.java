package com.reborn.backend.entry;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.OffsetDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/entries")
public class EntryController {
    private final EntryService service;

    public EntryController(EntryService service) { this.service = service; }

    @GetMapping
    public List<EntryService.EntryResponse> list(@RequestParam(required = false) String personId,
                                                  Authentication auth) {
        return service.list(personId, auth);
    }

    @GetMapping("/{id}")
    public EntryService.EntryResponse get(@PathVariable String id, Authentication auth) {
        return service.get(id, auth);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public EntryService.EntryResponse create(@Valid @RequestBody EntryRequest request, Authentication auth) {
        return service.create(request, auth);
    }

    @PutMapping("/{id}")
    public EntryService.EntryResponse update(@PathVariable String id, @Valid @RequestBody EntryRequest request,
                                              Authentication auth) {
        return service.update(id, request, auth);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable String id, Authentication auth) { service.delete(id, auth); }

    @DeleteMapping
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteAll(Authentication auth) { service.deleteAll(auth); }

    public record EntryRequest(@NotBlank @Size(max = 2000) String body, String person_id,
                               @NotBlank @Pattern(regexp = "joy|gratitude|excitement|calm|hurt|anxiety|anger|sadness")
                               String emotion, @Min(1) @Max(3) int intensity,
                               @Min(-3) @Max(3) int score, @NotNull OffsetDateTime created_at,
                               @NotBlank @Pattern(regexp = "pending|done|failed") String analysis_status,
                               List<String> analysis_keywords,
                               OffsetDateTime analyzed_at) {}
}
