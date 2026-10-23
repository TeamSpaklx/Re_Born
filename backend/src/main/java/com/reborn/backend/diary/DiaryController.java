package com.reborn.backend.diary;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.time.OffsetDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/diaries")
public class DiaryController {
    private final DiaryService service;

    public DiaryController(DiaryService service) { this.service = service; }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public DiaryResponse create(@Valid @RequestBody CreateDiaryRequest request) {
        return service.create(request);
    }

    @GetMapping
    public List<DiaryResponse> list(@RequestParam(required = false) String from,
                                    @RequestParam(required = false) String to) {
        return service.list(from, to);
    }

    public record CreateDiaryRequest(
            @NotBlank @Size(max = 2000) String body,
            @Min(-3) @Max(3) Integer score,
            OffsetDateTime createdAt) {}

    public record DiaryResponse(String id, String body, Integer score,
                                String emotion, OffsetDateTime createdAt,
                                String analysisStatus) {}
}
