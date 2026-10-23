package com.reborn.backend.insight;

import com.reborn.backend.config.AuthenticatedUser;
import com.reborn.backend.config.OwnedDataGuard;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.security.core.Authentication;
import org.springframework.web.server.ResponseStatusException;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

@Service
public class InsightService {
    private final JdbcTemplate jdbc;
    private final OwnedDataGuard ownedData;
    public InsightService(JdbcTemplate jdbc, OwnedDataGuard ownedData) {
        this.jdbc = jdbc;
        this.ownedData = ownedData;
    }

    public List<InsightResponse> list(String personId, Authentication auth) {
        UUID userId = AuthenticatedUser.id(auth);
        if (personId == null || personId.isBlank())
            return jdbc.query("select * from public.insights where user_id = ? order by created_at desc", this::map, userId);
        return jdbc.query("select * from public.insights where user_id = ? and person_id = cast(? as uuid) order by created_at desc",
                this::map, userId, personId);
    }
    public InsightResponse get(String id, Authentication auth) {
        return find(id, AuthenticatedUser.id(auth));
    }
    public void save(String id, InsightController.InsightRequest r, Authentication auth) {
        UUID userId = AuthenticatedUser.id(auth);
        ownedData.requirePerson(r.person_id(), userId);
        jdbc.update("""
                insert into public.insights (id, user_id, type, person_id, message, evidence_index_from,
                    evidence_index_to, evidence_neg_count, created_at, read)
                values (cast(? as uuid), ?, ?, cast(? as uuid), ?, ?, ?, ?, ?, ?)
                on conflict (id) do update set type = excluded.type, person_id = excluded.person_id,
                    message = excluded.message, evidence_index_from = excluded.evidence_index_from,
                    evidence_index_to = excluded.evidence_index_to, evidence_neg_count = excluded.evidence_neg_count,
                    created_at = excluded.created_at, read = excluded.read
                where public.insights.user_id = excluded.user_id
                """, id, userId, r.type(), r.person_id(), r.message(), r.evidence_index_from(),
                r.evidence_index_to(), r.evidence_neg_count(), r.created_at(), r.read());
    }
    public void markRead(String id, Authentication auth) {
        int count = jdbc.update("update public.insights set read = true where id = cast(? as uuid) and user_id = ?",
                id, AuthenticatedUser.id(auth));
        if (count == 0) throw new ResponseStatusException(HttpStatus.NOT_FOUND);
    }
    public void deleteForPerson(String personId, Authentication auth) {
        jdbc.update("delete from public.insights where person_id = cast(? as uuid) and user_id = ?",
                personId, AuthenticatedUser.id(auth));
    }
    public void deleteAll(Authentication auth) {
        jdbc.update("delete from public.insights where user_id = ?", AuthenticatedUser.id(auth));
    }
    private InsightResponse find(String id, UUID userId) {
        List<InsightResponse> rows = jdbc.query("select * from public.insights where id = cast(? as uuid) and user_id = ?",
                this::map, id, userId);
        if (rows.isEmpty()) throw new ResponseStatusException(HttpStatus.NOT_FOUND);
        return rows.getFirst();
    }
    private InsightResponse map(ResultSet rs, int rowNum) throws SQLException {
        Integer negativeCount = (Integer) rs.getObject("evidence_neg_count");
        return new InsightResponse(rs.getString("id"), rs.getString("type"), rs.getString("person_id"),
                rs.getString("message"), rs.getInt("evidence_index_from"), rs.getInt("evidence_index_to"),
                negativeCount, rs.getObject("created_at", OffsetDateTime.class), rs.getBoolean("read"));
    }
    public record InsightResponse(String id, String type, String person_id, String message,
                                  int evidence_index_from, int evidence_index_to, Integer evidence_neg_count,
                                  OffsetDateTime created_at, boolean read) {}
}
