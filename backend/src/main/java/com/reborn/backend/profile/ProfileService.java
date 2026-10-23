package com.reborn.backend.profile;

import com.reborn.backend.config.AuthenticatedUser;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class ProfileService {
    private final JdbcTemplate jdbc;

    public ProfileService(JdbcTemplate jdbc) { this.jdbc = jdbc; }

    public ProfileResponse get(Authentication authentication) {
        UUID userId = AuthenticatedUser.id(authentication);
        jdbc.update("insert into public.profiles (user_id) values (?) on conflict (user_id) do nothing", userId);
        return jdbc.queryForObject("""
                select user_id, nickname, consent_privacy, consent_ai_analysis, consent_analytics
                from public.profiles where user_id = ?
                """, (rs, rowNum) -> new ProfileResponse(
                rs.getObject("user_id", UUID.class).toString(), rs.getString("nickname"),
                rs.getBoolean("consent_privacy"), rs.getBoolean("consent_ai_analysis"),
                rs.getBoolean("consent_analytics")), userId);
    }

    public ProfileResponse update(ProfileController.UpdateProfileRequest request,
                                  Authentication authentication) {
        UUID userId = AuthenticatedUser.id(authentication);
        jdbc.update("""
                insert into public.profiles (user_id, nickname, consent_privacy, consent_ai_analysis, consent_analytics)
                values (?, ?, coalesce(?, false), coalesce(?, false), coalesce(?, false))
                on conflict (user_id) do update set nickname = excluded.nickname,
                    consent_privacy = excluded.consent_privacy,
                    consent_ai_analysis = excluded.consent_ai_analysis,
                    consent_analytics = excluded.consent_analytics
                """, userId, request.nickname(), request.consentPrivacy(), request.consentAiAnalysis(),
                request.consentAnalytics());
        return get(authentication);
    }

    public record ProfileResponse(String user_id, String nickname, boolean consent_privacy,
                                  boolean consent_ai_analysis, boolean consent_analytics) {}
}
