package com.reborn.backend.entry;

import com.reborn.backend.config.AuthenticatedUser;
import com.reborn.backend.config.OwnedDataGuard;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Array;
import java.sql.PreparedStatement;
import java.sql.Types;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Arrays;
import java.util.UUID;

@Service
public class EntryService {
    private final JdbcTemplate jdbc;
    private final OwnedDataGuard ownedData;
    public EntryService(JdbcTemplate jdbc, OwnedDataGuard ownedData) {
        this.jdbc = jdbc;
        this.ownedData = ownedData;
    }

    private final RowMapper<EntryResponse> mapper = this::map;

    public List<EntryResponse> list(String personId, Authentication auth) {
        UUID userId = AuthenticatedUser.id(auth);
        ownedData.requirePerson(personId, userId);
        if (personId == null || personId.isBlank()) {
            return jdbc.query("select * from public.entries where user_id = ? order by created_at desc", mapper, userId);
        }
        return jdbc.query("select * from public.entries where user_id = ? and person_id = cast(? as uuid) order by created_at desc",
                mapper, userId, personId);
    }

    public EntryResponse get(String id, Authentication auth) {
        List<EntryResponse> rows = jdbc.query("select * from public.entries where id = cast(? as uuid) and user_id = ?",
                mapper, id, AuthenticatedUser.id(auth));
        if (rows.isEmpty()) throw new ResponseStatusException(HttpStatus.NOT_FOUND);
        return rows.getFirst();
    }

    public EntryResponse create(EntryController.EntryRequest r, Authentication auth) {
        UUID userId = AuthenticatedUser.id(auth);
        ownedData.requirePerson(r.person_id(), userId);
        List<UUID> ids = jdbc.query(connection -> {
            PreparedStatement ps = connection.prepareStatement("""
                insert into public.entries (user_id, body, person_id, emotion, intensity, score, created_at,
                                            analysis_status, analysis_keywords, analyzed_at)
                values (?, ?, cast(? as uuid), ?, ?, ?, ?, ?, ?, ?)
                returning id
                """);
            ps.setObject(1, userId); ps.setString(2, r.body()); ps.setString(3, r.person_id());
            ps.setString(4, r.emotion()); ps.setInt(5, r.intensity()); ps.setInt(6, r.score());
            ps.setObject(7, r.created_at()); ps.setString(8, r.analysis_status());
            setKeywords(connection, ps, 9, r.analysis_keywords()); ps.setObject(10, r.analyzed_at());
            return ps;
        }, (rs, row) -> rs.getObject("id", UUID.class));
        UUID id = ids.getFirst();
        return get(id.toString(), auth);
    }

    public EntryResponse update(String id, EntryController.EntryRequest r, Authentication auth) {
        UUID userId = AuthenticatedUser.id(auth);
        ownedData.requirePerson(r.person_id(), userId);
        int count = jdbc.update(connection -> {
            PreparedStatement ps = connection.prepareStatement("""
                update public.entries set body = ?, person_id = cast(? as uuid), emotion = ?, intensity = ?, score = ?,
                    created_at = ?, analysis_status = ?, analysis_keywords = ?, analyzed_at = ?
                where id = cast(? as uuid) and user_id = ?
                """);
            ps.setString(1, r.body()); ps.setString(2, r.person_id()); ps.setString(3, r.emotion());
            ps.setInt(4, r.intensity()); ps.setInt(5, r.score()); ps.setObject(6, r.created_at());
            ps.setString(7, r.analysis_status()); setKeywords(connection, ps, 8, r.analysis_keywords());
            ps.setObject(9, r.analyzed_at()); ps.setString(10, id); ps.setObject(11, userId);
            return ps;
        });
        if (count == 0) throw new ResponseStatusException(HttpStatus.NOT_FOUND);
        return get(id, auth);
    }

    public void delete(String id, Authentication auth) {
        jdbc.update("delete from public.entries where id = cast(? as uuid) and user_id = ?", id,
                AuthenticatedUser.id(auth));
    }

    public void deleteAll(Authentication auth) {
        jdbc.update("delete from public.entries where user_id = ?", AuthenticatedUser.id(auth));
    }

    private EntryResponse map(ResultSet rs, int rowNum) throws SQLException {
        Array array = rs.getArray("analysis_keywords");
        List<String> keywords = array == null ? List.of() : Arrays.asList((String[]) array.getArray());
        return new EntryResponse(rs.getString("id"), rs.getString("body"), rs.getString("person_id"),
                rs.getString("emotion"), rs.getInt("intensity"), rs.getInt("score"),
                rs.getObject("created_at", OffsetDateTime.class), rs.getString("analysis_status"),
                keywords,
                rs.getObject("analyzed_at", OffsetDateTime.class));
    }

    private void setKeywords(java.sql.Connection connection, PreparedStatement ps, int position,
                             List<String> keywords) throws SQLException {
        if (keywords == null) ps.setNull(position, Types.ARRAY);
        else ps.setArray(position, connection.createArrayOf("text", keywords.toArray()));
    }

    public record EntryResponse(String id, String body, String person_id, String emotion, int intensity, int score,
                                OffsetDateTime created_at, String analysis_status,
                                List<String> analysis_keywords, OffsetDateTime analyzed_at) {}
}
