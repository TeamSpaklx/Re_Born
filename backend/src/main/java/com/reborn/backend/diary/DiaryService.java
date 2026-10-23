package com.reborn.backend.diary;

import java.util.List;
import java.util.UUID;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.security.core.Authentication;

import com.reborn.backend.config.AuthenticatedUser;

@Service
public class DiaryService {
    private final JdbcTemplate jdbc;
    private final DiaryAiService diaryAiService;

    public DiaryService(JdbcTemplate jdbc, DiaryAiService diaryAiService) {
        this.jdbc = jdbc;
        this.diaryAiService = diaryAiService;
    }

    public AnalyzedDiaryResponse analyzeAndCreate(AnalyzeDiaryRequest request, Authentication authentication) {
        UUID userId = AuthenticatedUser.id(authentication);
        DiaryAiService.AnalysisResult analysis = diaryAiService.analyze(request.body());
        UUID personId = request.person_id() == null || request.person_id().isBlank()
                ? null : UUID.fromString(request.person_id());
        UUID id = jdbc.queryForObject("""
                insert into public.diary (user_id, person_id, body, emotion, score)
                values (?, cast(? as uuid), ?, ?, ?)
                returning id
                """, UUID.class, userId, personId, request.body(), analysis.emotion(), analysis.score());
        return new AnalyzedDiaryResponse(id.toString(), request.person_id(), request.body(), analysis);
    }

    public DiaryController.DiaryResponse create(DiaryController.CreateDiaryRequest request,
                                                Authentication authentication) {
        UUID userId = AuthenticatedUser.id(authentication);
        UUID id = jdbc.queryForObject("""
                insert into public.diary
                    (user_id, person_id, body, emotion, score)
                values (?, cast(? as uuid), ?, ?, ?)
                returning id
                """, UUID.class,
                userId,
                request.person_id() == null || request.person_id().isBlank()
                        ? null : UUID.fromString(request.person_id()),
                request.body(),
                request.emotion() == null ? "calm" : request.emotion(),
                request.score() == null ? 0 : request.score());
        return new DiaryController.DiaryResponse(id.toString(), userId.toString(), request.person_id(), request.body(),
                request.emotion() == null ? "calm" : request.emotion(), request.score() == null ? 0 : request.score());
    }

    public List<DiaryController.DiaryResponse> list(String from, String to, Authentication authentication) {
        UUID userId = AuthenticatedUser.id(authentication);
        return jdbc.query("""
                select id, user_id, person_id, body, emotion, score
                from public.diary
                where user_id = ?
                order by id desc
                """, (rs, rowNum) -> new DiaryController.DiaryResponse(
                rs.getString("id"), rs.getString("user_id"), rs.getString("person_id"), rs.getString("body"),
                rs.getString("emotion"), rs.getInt("score")), userId);
    }

    public record AnalyzeDiaryRequest(String person_id, String body) {}

    public record AnalyzedDiaryResponse(String id, String person_id, String body,
                                        DiaryAiService.AnalysisResult analysis) {}
}
