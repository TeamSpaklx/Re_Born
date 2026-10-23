package com.reborn.backend.indexhistory;

import com.reborn.backend.config.AuthenticatedUser;
import com.reborn.backend.config.OwnedDataGuard;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.security.core.Authentication;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Service
public class IndexHistoryService {
    private final JdbcTemplate jdbc;
    private final OwnedDataGuard ownedData;
    public IndexHistoryService(JdbcTemplate jdbc, OwnedDataGuard ownedData) {
        this.jdbc = jdbc;
        this.ownedData = ownedData;
    }

    public List<IndexResponse> list(String personId, LocalDate from, Authentication auth) {
        UUID userId = AuthenticatedUser.id(auth);
        if (from == null) return jdbc.query("select person_id, date, index, entry_count from public.index_history where user_id = ? and person_id = cast(? as uuid) order by date",
                this::map, userId, personId);
        return jdbc.query("select person_id, date, index, entry_count from public.index_history where user_id = ? and person_id = cast(? as uuid) and date >= ? order by date",
                this::map, userId, personId, from);
    }
    public void upsert(IndexHistoryController.IndexRequest r, Authentication auth) {
        ownedData.requirePerson(r.person_id(), AuthenticatedUser.id(auth));
        jdbc.update("""
                insert into public.index_history (person_id, date, user_id, index, entry_count)
                values (cast(? as uuid), ?, ?, ?, ?)
                on conflict (person_id, date) do update set user_id = excluded.user_id,
                    index = excluded.index, entry_count = excluded.entry_count
                where public.index_history.user_id = excluded.user_id
                """, r.person_id(), r.date(), AuthenticatedUser.id(auth), r.index(), r.entry_count());
    }
    public void delete(String personId, LocalDate date, Authentication auth) {
        jdbc.update("delete from public.index_history where person_id = cast(? as uuid) and date = ? and user_id = ?",
                personId, date, AuthenticatedUser.id(auth));
    }
    public void deleteForPerson(String personId, Authentication auth) {
        jdbc.update("delete from public.index_history where person_id = cast(? as uuid) and user_id = ?",
                personId, AuthenticatedUser.id(auth));
    }
    public void deleteAll(Authentication auth) {
        jdbc.update("delete from public.index_history where user_id = ?", AuthenticatedUser.id(auth));
    }
    private IndexResponse map(java.sql.ResultSet rs, int row) throws java.sql.SQLException {
        return new IndexResponse(rs.getString("person_id"), rs.getObject("date", LocalDate.class),
                rs.getInt("index"), rs.getInt("entry_count"));
    }
    public record IndexResponse(String person_id, LocalDate date, int index, int entry_count) {}
}
