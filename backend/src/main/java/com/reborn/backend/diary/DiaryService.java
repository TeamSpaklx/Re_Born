package com.reborn.backend.diary;

import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.security.core.Authentication;

import com.reborn.backend.config.AuthenticatedUser;
import com.reborn.backend.config.OwnedDataGuard;
import org.springframework.beans.factory.annotation.Autowired;

@Service
public class DiaryService {
    private final JdbcTemplate jdbc;
    private final DiaryAiService diaryAiService;
    private final OwnedDataGuard ownedData;

    public DiaryService(JdbcTemplate jdbc, DiaryAiService diaryAiService) {
        this(jdbc, diaryAiService, new OwnedDataGuard(jdbc));
    }

    @Autowired
    public DiaryService(JdbcTemplate jdbc, DiaryAiService diaryAiService, OwnedDataGuard ownedData) {
        this.jdbc = jdbc;
        this.diaryAiService = diaryAiService;
        this.ownedData = ownedData;
    }

    public AnalyzedDiaryResponse analyzeAndCreate(AnalyzeDiaryRequest request, Authentication authentication) {
        UUID userId = AuthenticatedUser.id(authentication);
        ownedData.requirePerson(request.person_id(), userId);
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
        ownedData.requirePerson(request.person_id(), userId);
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

    public List<DiaryController.DiaryResponse> list(OffsetDateTime from, OffsetDateTime to,
                                                    Authentication authentication) {
        UUID userId = AuthenticatedUser.id(authentication);
        StringBuilder sql = new StringBuilder("""
                select id, user_id, person_id, body, emotion, score
                from public.diary
                where user_id = ?
                """);
        List<Object> parameters = new ArrayList<>();
        parameters.add(userId);
        if (from != null) {
            sql.append(" and created_at >= ?");
            parameters.add(from);
        }
        if (to != null) {
            sql.append(" and created_at < ?");
            parameters.add(to);
        }
        sql.append(" order by created_at desc");
        return jdbc.query(sql.toString(), (rs, rowNum) -> new DiaryController.DiaryResponse(
                rs.getString("id"), rs.getString("user_id"), rs.getString("person_id"), rs.getString("body"),
                rs.getString("emotion"), rs.getInt("score")),
                parameters.toArray());
    }

    public record AnalyzeDiaryRequest(String person_id, String body) {}

    public record AnalyzedDiaryResponse(String id, String person_id, String body,
                                        DiaryAiService.AnalysisResult analysis) {}
}
