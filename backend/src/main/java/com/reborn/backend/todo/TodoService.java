package com.reborn.backend.todo;

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
public class TodoService {
    private final JdbcTemplate jdbc;
    private final OwnedDataGuard ownedData;
    public TodoService(JdbcTemplate jdbc, OwnedDataGuard ownedData) {
        this.jdbc = jdbc;
        this.ownedData = ownedData;
    }

    public List<TodoResponse> list(Authentication auth) {
        return jdbc.query("select * from public.todos where user_id = ? order by created_at desc",
                this::map, AuthenticatedUser.id(auth));
    }
    public TodoResponse create(TodoController.TodoRequest r, Authentication auth) {
        UUID userId = AuthenticatedUser.id(auth);
        ownedData.requirePerson(r.person_id(), userId);
        ownedData.requireInsight(r.insight_id(), userId);
        UUID id = jdbc.queryForObject("""
                insert into public.todos (user_id, title, person_id, done, done_at, source, insight_id, created_at)
                values (?, ?, cast(? as uuid), ?, ?, ?, cast(? as uuid), ?) returning id
                """, UUID.class, userId, r.title(), r.person_id(), r.done(), r.done_at(), r.source(),
                r.insight_id(), r.created_at());
        return get(id.toString(), userId);
    }
    public TodoResponse update(String id, TodoController.TodoRequest r, Authentication auth) {
        UUID userId = AuthenticatedUser.id(auth);
        ownedData.requirePerson(r.person_id(), userId);
        ownedData.requireInsight(r.insight_id(), userId);
        int count = jdbc.update("""
                update public.todos set title = ?, person_id = cast(? as uuid), done = ?, done_at = ?, source = ?,
                    insight_id = cast(? as uuid), created_at = ? where id = cast(? as uuid) and user_id = ?
                """, r.title(), r.person_id(), r.done(), r.done_at(), r.source(), r.insight_id(), r.created_at(), id, userId);
        if (count == 0) throw new ResponseStatusException(HttpStatus.NOT_FOUND);
        return get(id, userId);
    }
    public void delete(String id, Authentication auth) {
        jdbc.update("delete from public.todos where id = cast(? as uuid) and user_id = ?", id,
                AuthenticatedUser.id(auth));
    }
    public void deleteAll(Authentication auth) {
        jdbc.update("delete from public.todos where user_id = ?", AuthenticatedUser.id(auth));
    }
    private TodoResponse get(String id, UUID userId) {
        List<TodoResponse> rows = jdbc.query("select * from public.todos where id = cast(? as uuid) and user_id = ?",
                this::map, id, userId);
        if (rows.isEmpty()) throw new ResponseStatusException(HttpStatus.NOT_FOUND);
        return rows.getFirst();
    }
    private TodoResponse map(ResultSet rs, int rowNum) throws SQLException {
        return new TodoResponse(rs.getString("id"), rs.getString("title"), rs.getString("person_id"),
                rs.getBoolean("done"), rs.getObject("done_at", OffsetDateTime.class), rs.getString("source"),
                rs.getString("insight_id"), rs.getObject("created_at", OffsetDateTime.class));
    }
    public record TodoResponse(String id, String title, String person_id, boolean done, OffsetDateTime done_at,
                               String source, String insight_id, OffsetDateTime created_at) {}
}
