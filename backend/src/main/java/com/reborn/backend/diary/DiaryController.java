package com.reborn.backend.diary;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.Size;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.OffsetDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/diaries")
@Tag(name = "Diary", description = "일기 작성 및 조회 API")
public class DiaryController {
    private final DiaryService service;

    public DiaryController(DiaryService service) { this.service = service; }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "일기 작성", description = "새 일기를 pending 상태로 저장합니다.")
    public DiaryResponse create(@Valid @RequestBody CreateDiaryRequest request,
                                Authentication authentication) {
        return service.create(request, authentication);
    }

    @PostMapping("/analyze")
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "일기 AI 분석 및 저장", description = "본문을 OpenAI로 전송해 감정을 분석한 뒤 public.diary에 저장합니다.")
    public DiaryService.AnalyzedDiaryResponse analyzeAndCreate(
            @Valid @RequestBody AnalyzeDiaryRequest request,
            Authentication authentication) {
        return service.analyzeAndCreate(
                new DiaryService.AnalyzeDiaryRequest(request.person_id(), request.body()), authentication);
    }

    @GetMapping
    @Operation(summary = "일기 목록 조회", description = "from, to 날짜 범위로 일기를 조회합니다.")
    public List<DiaryResponse> list(@RequestParam(required = false) String from,
                                    @RequestParam(required = false) String to,
                                    Authentication authentication) {
        return service.list(from, to, authentication);
    }

    public record CreateDiaryRequest(
        String person_id,
        @NotBlank @Size(max = 2000) String body,
        String emotion,
        @Min(-3) @Max(3) Integer score
        ) {}

    public record AnalyzeDiaryRequest(
            String person_id,
            @NotBlank @Size(max = 2000) String body,
            @NotNull @AssertTrue Boolean consentToExternalAnalysis) {}

    public record DiaryResponse(String id, String user_id, String person_id, String body,
                                String emotion, Integer score) {}
}
