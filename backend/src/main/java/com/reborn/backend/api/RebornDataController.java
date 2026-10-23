package com.reborn.backend.api;

import java.time.Instant;
import java.time.LocalDate;
import java.util.Map;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class RebornDataController {
    private final JdbcTemplate jdbc;

    public RebornDataController(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @PutMapping("/people/{personId}/index-history/{date}")
    public void upsertHistory(@AuthenticationPrincipal Jwt jwt, @PathVariable UUID personId,
                              @PathVariable LocalDate date, @RequestBody HistoryRequest request) {
        jdbc.update("""
                insert into public.index_history(person_id, user_id, date, index, entry_count)
                values (?, ?, ?, ?, ?)
                on conflict (person_id, date) do update
                set index = excluded.index, entry_count = excluded.entry_count, user_id = excluded.user_id
                """, personId, uid(jwt), date, request.index(), request.entryCount());
    }

    @DeleteMapping("/people/{personId}/index-history/{date}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteHistory(@AuthenticationPrincipal Jwt jwt, @PathVariable UUID personId,
                              @PathVariable LocalDate date) {
        jdbc.update("delete from public.index_history where person_id = ? and date = ? and user_id = ?",
                personId, date, uid(jwt));
    }

    @PostMapping("/entries/{id}/analysis/retry")
    public Map<String, Object> retryAnalysis(@AuthenticationPrincipal Jwt jwt, @PathVariable UUID id) {
        jdbc.queryForMap("select body from public.entries where id = ? and user_id = ?", id, uid(jwt));
        jdbc.update("""
                update public.entries set analysis_status = 'done', analysis_keywords = ?, analyzed_at = now()
                where id = ? and user_id = ?
                """, new String[] {"감정기록"}, id, uid(jwt));
        return jdbc.queryForMap("select * from public.entries where id = ? and user_id = ?", id, uid(jwt));
    }

    @GetMapping("/profile")
    public Map<String, Object> profile(@AuthenticationPrincipal Jwt jwt) {
        ensureProfile(jwt);
        return jdbc.queryForMap("""
                select user_id as "userId", nickname, consent_privacy as "consentPrivacy",
                       consent_ai_analysis as "consentAiAnalysis", consent_analytics as "consentAnalytics",
                       notification_insight as "notificationInsight", notification_reminder as "notificationReminder",
                       notification_reminder_time as "reminderTime", created_at as "createdAt"
                from public.profiles where user_id = ?
                """, uid(jwt));
    }

    @PutMapping("/profile")
    public Map<String, Object> updateProfile(@AuthenticationPrincipal Jwt jwt, @RequestBody ProfileRequest request) {
        ensureProfile(jwt);
        jdbc.update("""
                update public.profiles set nickname = coalesce(?, nickname),
                  consent_privacy = coalesce(?, consent_privacy),
                  consent_ai_analysis = coalesce(?, consent_ai_analysis),
                  consent_analytics = coalesce(?, consent_analytics),
                  notification_insight = coalesce(?, notification_insight),
                  notification_reminder = coalesce(?, notification_reminder),
                  notification_reminder_time = coalesce(?, notification_reminder_time)
                where user_id = ?
                """, request.nickname(), request.consentPrivacy(), request.consentAiAnalysis(),
                request.consentAnalytics(), request.notificationInsight(), request.notificationReminder(),
                request.reminderTime(), uid(jwt));
        return profile(jwt);
    }

    @DeleteMapping("/account")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteAccountData(@AuthenticationPrincipal Jwt jwt) {
        requireRecentReauthentication(jwt);
        String user = uid(jwt);
        jdbc.update("delete from public.profiles where user_id = ?", user);
        jdbc.update("delete from public.todos where user_id = ?", user);
        jdbc.update("delete from public.insights where user_id = ?", user);
        jdbc.update("delete from public.index_history where user_id = ?", user);
        jdbc.update("delete from public.entries where user_id = ?", user);
        jdbc.update("delete from public.people where user_id = ?", user);
    }

    @PostMapping("/account/reauthenticate")
    public Map<String, Object> reauthenticate(@AuthenticationPrincipal Jwt jwt) {
        requireRecentReauthentication(jwt);
        return Map.of("reauthenticated", true, "expiresInSeconds", 300);
    }

    private String uid(Jwt jwt) {
        return jwt.getSubject();
    }

    private void ensureProfile(Jwt jwt) {
        jdbc.update("insert into public.profiles(user_id) values(?) on conflict(user_id) do nothing", uid(jwt));
    }

    private void requireRecentReauthentication(Jwt jwt) {
        Instant authTime = jwt.getClaimAsInstant("auth_time");
        if (authTime == null || authTime.isBefore(Instant.now().minusSeconds(300))) {
            throw new IllegalArgumentException("recent reauthentication is required");
        }
    }

    public record HistoryRequest(int index, int entryCount) {}

    public record ProfileRequest(String nickname, Boolean consentPrivacy, Boolean consentAiAnalysis,
                                 Boolean consentAnalytics, Boolean notificationInsight,
                                 Boolean notificationReminder, String reminderTime) {}
}
