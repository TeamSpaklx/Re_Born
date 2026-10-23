package com.reborn.backend.person;

import com.reborn.backend.config.AuthenticatedUser;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
public class PersonService {
    private final JdbcTemplate jdbc;

    public PersonService(JdbcTemplate jdbc) { this.jdbc = jdbc; }

    public List<PersonResponse> list(Authentication authentication) {
        UUID userId = AuthenticatedUser.id(authentication);
        return jdbc.query("""
                select id, user_id, name, relation_type, memo
                from public.people where user_id = ? order by created_at desc
                """, (rs, rowNum) -> response(rs), userId);
    }

    public PersonResponse create(PersonController.PersonRequest request, Authentication authentication) {
        UUID userId = AuthenticatedUser.id(authentication);
        UUID id = jdbc.queryForObject("""
                insert into public.people (user_id, name, relation_type, memo)
                values (?, ?, ?, ?) returning id
                """, UUID.class, userId, request.name().trim(), request.relation_type(), request.memo());
        return find(id, userId);
    }

    public PersonResponse update(String rawId, PersonController.PersonRequest request, Authentication authentication) {
        UUID userId = AuthenticatedUser.id(authentication);
        UUID id = UUID.fromString(rawId);
        jdbc.update("""
                update public.people set name = ?, relation_type = ?, memo = ?
                where id = ? and user_id = ?
                """, request.name().trim(), request.relation_type(), request.memo(), id, userId);
        return find(id, userId);
    }

    public void delete(String rawId, Authentication authentication) {
        jdbc.update("delete from public.people where id = ? and user_id = ?",
                UUID.fromString(rawId), AuthenticatedUser.id(authentication));
    }

    private PersonResponse find(UUID id, UUID userId) {
        return jdbc.queryForObject("select id, user_id, name, relation_type, memo from public.people where id = ? and user_id = ?",
                (rs, rowNum) -> response(rs), id, userId);
    }

    private PersonResponse response(java.sql.ResultSet rs) throws java.sql.SQLException {
        return new PersonResponse(rs.getString("id"), rs.getString("user_id"), rs.getString("name"),
                rs.getString("relation_type"), rs.getString("memo"));
    }

    public record PersonResponse(String id, String user_id, String name, String relation_type, String memo) {}
}
