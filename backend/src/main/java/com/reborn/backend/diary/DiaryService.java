package com.reborn.backend.diary;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

@Service
public class DiaryService {
    private final JdbcTemplate jdbc;

    public DiaryService(JdbcTemplate jdbc) { this.jdbc = jdbc; }

    public DiaryController.DiaryResponse create(DiaryController.CreateDiaryRequest request) {
        String id = UUID.randomUUID().toString();
        OffsetDateTime createdAt = request.createdAt() == null ? OffsetDateTime.now() : request.createdAt();
        jdbc.update("""
                insert into public.entries
                    (id, user_id, body, emotion, intensity, score, created_at, analysis_status)
                values (?, auth.uid(), ?, 'calm', 1, ?, ?, 'pending')
                """, id, request.body(), request.score() == null ? 0 : request.score(), createdAt);
        return new DiaryController.DiaryResponse(id, request.body(), request.score(), "calm", createdAt, "pending");
    }

    public List<DiaryController.DiaryResponse> list(String from, String to) {
        return jdbc.query("""
                select id, body, score, emotion, created_at, analysis_status
                from public.entries
                where created_at >= coalesce(?::timestamptz, '-infinity'::timestamptz)
                  and created_at < coalesce(?::timestamptz, 'infinity'::timestamptz)
                order by created_at desc
                """, (rs, rowNum) -> new DiaryController.DiaryResponse(
                rs.getString("id"), rs.getString("body"), rs.getInt("score"),
                rs.getString("emotion"), rs.getObject("created_at", OffsetDateTime.class),
                rs.getString("analysis_status")), from, to);
    }
}
