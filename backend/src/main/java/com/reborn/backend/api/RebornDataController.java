package com.reborn.backend.api;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.OffsetDateTime;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
public class RebornDataController {
    private final JdbcTemplate jdbc;
    public RebornDataController(JdbcTemplate jdbc) { this.jdbc = jdbc; }

    @GetMapping("/people")
    public List<Map<String,Object>> people(@AuthenticationPrincipal Jwt jwt) {
        return jdbc.queryForList("select id, name, relation_type as \"relationType\", memo, created_at as \"createdAt\" from public.people where user_id = ? order by created_at", uid(jwt));
    }

    @PostMapping("/people")
    @ResponseStatus(HttpStatus.CREATED)
    public Map<String,Object> createPerson(@AuthenticationPrincipal Jwt jwt, @Valid @RequestBody PersonRequest r) {
        UUID id = UUID.randomUUID();
        jdbc.update("insert into public.people(id,user_id,name,relation_type,memo) values(?,?,?,?,?)", id, uid(jwt), r.name().trim(), r.relationType(), r.memo());
        return jdbc.queryForMap("select id, name, relation_type as \"relationType\", memo, created_at as \"createdAt\" from public.people where id = ? and user_id = ?", id, uid(jwt));
    }

    @PatchMapping("/people/{id}")
    public void updatePerson(@AuthenticationPrincipal Jwt jwt, @PathVariable UUID id, @Valid @RequestBody PersonRequest r) {
        jdbc.update("update public.people set name=?, relation_type=?, memo=? where id=? and user_id=?", r.name().trim(), r.relationType(), r.memo(), id, uid(jwt));
    }

    @DeleteMapping("/people/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deletePerson(@AuthenticationPrincipal Jwt jwt, @PathVariable UUID id) {
        jdbc.update("delete from public.people where id=? and user_id=?", id, uid(jwt));
    }

    @GetMapping("/entries")
    public List<Map<String,Object>> entries(@AuthenticationPrincipal Jwt jwt, @RequestParam(required=false) UUID personId) {
        if (personId == null) return jdbc.queryForList("select id, body, person_id as \"personId\", emotion, intensity, score, created_at as \"createdAt\", analysis_status as \"analysisStatus\", analysis_keywords as keywords, analyzed_at as \"analyzedAt\" from public.entries where user_id=? order by created_at desc", uid(jwt));
        return jdbc.queryForList("select id, body, person_id as \"personId\", emotion, intensity, score, created_at as \"createdAt\", analysis_status as \"analysisStatus\", analysis_keywords as keywords, analyzed_at as \"analyzedAt\" from public.entries where user_id=? and person_id=? order by created_at desc", uid(jwt), personId);
    }

    @GetMapping("/entries/{id}")
    public Map<String,Object> entry(@AuthenticationPrincipal Jwt jwt, @PathVariable UUID id) {
        return jdbc.queryForMap("select id, body, person_id as \"personId\", emotion, intensity, score, created_at as \"createdAt\", analysis_status as \"analysisStatus\", analysis_keywords as keywords, analyzed_at as \"analyzedAt\" from public.entries where id=? and user_id=?", id, uid(jwt));
    }

    @PostMapping("/entries")
    @ResponseStatus(HttpStatus.CREATED)
    public Map<String,Object> createEntry(@AuthenticationPrincipal Jwt jwt, @Valid @RequestBody EntryRequest r) {
        validateScore(r.emotion(), r.intensity(), r.score());
        ensurePersonOwned(jwt, r.personId());
        UUID id=UUID.randomUUID(); OffsetDateTime at=r.createdAt()==null?OffsetDateTime.now():r.createdAt();
        if (at.isAfter(OffsetDateTime.now())) throw new IllegalArgumentException("createdAt cannot be in the future");
        jdbc.update("insert into public.entries(id,user_id,body,person_id,emotion,intensity,score,created_at) values(?,?,?,?,?,?,?,?)", id,uid(jwt),r.body().trim(),r.personId(),r.emotion(),r.intensity(),r.score(),at);
        return entry(jwt,id);
    }

    @PatchMapping("/entries/{id}")
    public void updateEntry(@AuthenticationPrincipal Jwt jwt,@PathVariable UUID id,@Valid @RequestBody EntryRequest r) {
        validateScore(r.emotion(), r.intensity(), r.score());
        ensurePersonOwned(jwt, r.personId());
        jdbc.update("update public.entries set body=?,person_id=?,emotion=?,intensity=?,score=?,created_at=?,analysis_status='pending',analysis_keywords=null,analyzed_at=null where id=? and user_id=?",r.body().trim(),r.personId(),r.emotion(),r.intensity(),r.score(),r.createdAt(),id,uid(jwt));
    }

    @DeleteMapping("/entries/{id}") @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteEntry(@AuthenticationPrincipal Jwt jwt,@PathVariable UUID id){jdbc.update("delete from public.entries where id=? and user_id=?",id,uid(jwt));}

    @GetMapping("/todos") public List<Map<String,Object>> todos(@AuthenticationPrincipal Jwt jwt){return jdbc.queryForList("select id,title,person_id as \"personId\",done,done_at as \"doneAt\",source,insight_id as \"insightId\",created_at as \"createdAt\" from public.todos where user_id=? order by created_at desc",uid(jwt));}
    @PostMapping("/todos") @ResponseStatus(HttpStatus.CREATED)
    public Map<String,Object> createTodo(@AuthenticationPrincipal Jwt jwt,@Valid @RequestBody TodoRequest r){ensurePersonOwned(jwt,r.personId());ensureInsightOwned(jwt,r.insightId());UUID id=UUID.randomUUID();String source=r.source()==null?"manual":r.source();jdbc.update("insert into public.todos(id,user_id,title,person_id,done,source,insight_id) values(?,?,?,?,false,?,?)",id,uid(jwt),r.title().trim(),r.personId(),source,r.insightId());return jdbc.queryForMap("select * from public.todos where id=? and user_id=?",id,uid(jwt));}
    @PatchMapping("/todos/{id}") public void updateTodo(@AuthenticationPrincipal Jwt jwt,@PathVariable UUID id,@RequestBody TodoUpdate r){jdbc.update("update public.todos set title=coalesce(?,title),done=coalesce(?,done),done_at=case when coalesce(?,done)=true then coalesce(done_at,now()) else null end where id=? and user_id=?",r.title(),r.done(),r.done(),id,uid(jwt));}
    @DeleteMapping("/todos/{id}") @ResponseStatus(HttpStatus.NO_CONTENT) public void deleteTodo(@AuthenticationPrincipal Jwt jwt,@PathVariable UUID id){jdbc.update("delete from public.todos where id=? and user_id=?",id,uid(jwt));}

    @GetMapping("/people/{personId}/index-history") public List<Map<String,Object>> history(@AuthenticationPrincipal Jwt jwt,@PathVariable UUID personId,@RequestParam(required=false) LocalDate from){if(from==null)return jdbc.queryForList("select person_id as \"personId\",date,index,entry_count as \"entryCount\" from public.index_history where person_id=? and user_id=? order by date",personId,uid(jwt));return jdbc.queryForList("select person_id as \"personId\",date,index,entry_count as \"entryCount\" from public.index_history where person_id=? and user_id=? and date>=? order by date",personId,uid(jwt),from);}
    @PutMapping("/people/{personId}/index-history/{date}") public void upsertHistory(@AuthenticationPrincipal Jwt jwt,@PathVariable UUID personId,@PathVariable LocalDate date,@RequestBody HistoryRequest r){jdbc.update("insert into public.index_history(person_id,user_id,date,index,entry_count) values(?,?,?,?,?) on conflict(person_id,date) do update set index=excluded.index,entry_count=excluded.entry_count,user_id=excluded.user_id",personId,uid(jwt),date,r.index(),r.entryCount());}
    @DeleteMapping("/people/{personId}/index-history/{date}") @ResponseStatus(HttpStatus.NO_CONTENT) public void deleteHistory(@AuthenticationPrincipal Jwt jwt,@PathVariable UUID personId,@PathVariable LocalDate date){jdbc.update("delete from public.index_history where person_id=? and date=? and user_id=?",personId,date,uid(jwt));}

    @GetMapping("/insights") public List<Map<String,Object>> insights(@AuthenticationPrincipal Jwt jwt,@RequestParam(required=false) UUID personId){if(personId==null)return jdbc.queryForList("select * from public.insights where user_id=? order by created_at desc",uid(jwt));return jdbc.queryForList("select * from public.insights where user_id=? and person_id=? order by created_at desc",uid(jwt),personId);}
    @PostMapping("/insights") @ResponseStatus(HttpStatus.CREATED)
    public Map<String,Object> createInsight(@AuthenticationPrincipal Jwt jwt,@Valid @RequestBody InsightRequest r){ensurePersonOwned(jwt,r.personId());UUID id=UUID.randomUUID();jdbc.update("insert into public.insights(id,user_id,type,person_id,message,evidence_index_from,evidence_index_to,evidence_neg_count) values(?,?,?,?,?,?,?,?)",id,uid(jwt),r.type(),r.personId(),r.message(),r.indexFrom(),r.indexTo(),r.negCount());return jdbc.queryForMap("select * from public.insights where id=? and user_id=?",id,uid(jwt));}
    @PatchMapping("/insights/{id}/read") @ResponseStatus(HttpStatus.NO_CONTENT) public void readInsight(@AuthenticationPrincipal Jwt jwt,@PathVariable UUID id){jdbc.update("update public.insights set read=true where id=? and user_id=?",id,uid(jwt));}
    @GetMapping("/insights/{id}") public Map<String,Object> insight(@AuthenticationPrincipal Jwt jwt,@PathVariable UUID id){return jdbc.queryForMap("select * from public.insights where id=? and user_id=?",id,uid(jwt));}

    @PostMapping("/entries/{id}/analysis/retry")
    public Map<String,Object> retryAnalysis(@AuthenticationPrincipal Jwt jwt,@PathVariable UUID id){
        Map<String,Object> e=entry(jwt,id);
        String body=String.valueOf(e.get("body"));
        List<String> keywords=List.of("감정기록");
        jdbc.update("update public.entries set analysis_status='done',analysis_keywords=?,analyzed_at=now() where id=? and user_id=?",keywords.toArray(String[]::new),id,uid(jwt));
        return entry(jwt,id);
    }

    @GetMapping("/profile")
    public Map<String,Object> profile(@AuthenticationPrincipal Jwt jwt){
        ensureProfile(jwt);
        return jdbc.queryForMap("select user_id as \"userId\",nickname,consent_privacy as \"consentPrivacy\",consent_ai_analysis as \"consentAiAnalysis\",consent_analytics as \"consentAnalytics\",notification_insight as \"notificationInsight\",notification_reminder as \"notificationReminder\",notification_reminder_time as \"reminderTime\",created_at as \"createdAt\" from public.profiles where user_id=?",uid(jwt));
    }

    @PutMapping("/profile")
    public Map<String,Object> updateProfile(@AuthenticationPrincipal Jwt jwt,@RequestBody ProfileRequest r){
        ensureProfile(jwt);
        jdbc.update("update public.profiles set nickname=coalesce(?,nickname),consent_privacy=coalesce(?,consent_privacy),consent_ai_analysis=coalesce(?,consent_ai_analysis),consent_analytics=coalesce(?,consent_analytics),notification_insight=coalesce(?,notification_insight),notification_reminder=coalesce(?,notification_reminder),notification_reminder_time=coalesce(?,notification_reminder_time) where user_id=?",r.nickname(),r.consentPrivacy(),r.consentAiAnalysis(),r.consentAnalytics(),r.notificationInsight(),r.notificationReminder(),r.reminderTime(),uid(jwt));
        return profile(jwt);
    }

    @DeleteMapping("/account")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteAccountData(@AuthenticationPrincipal Jwt jwt){
        requireRecentReauthentication(jwt);
        String user=uid(jwt);
        jdbc.update("delete from public.profiles where user_id=?",user);
        jdbc.update("delete from public.todos where user_id=?",user);
        jdbc.update("delete from public.insights where user_id=?",user);
        jdbc.update("delete from public.index_history where user_id=?",user);
        jdbc.update("delete from public.entries where user_id=?",user);
        jdbc.update("delete from public.people where user_id=?",user);
    }

    @PostMapping("/account/reauthenticate")
    public Map<String,Object> reauthenticate(@AuthenticationPrincipal Jwt jwt){
        requireRecentReauthentication(jwt);
        return Map.of("reauthenticated",true,"expiresInSeconds",300);
    }

    private String uid(Jwt jwt){return jwt.getSubject();}
    private void ensureProfile(Jwt jwt){jdbc.update("insert into public.profiles(user_id) values(?) on conflict(user_id) do nothing",uid(jwt));}
    private void requireRecentReauthentication(Jwt jwt){Instant authTime=jwt.getClaimAsInstant("auth_time");if(authTime==null||authTime.isBefore(Instant.now().minusSeconds(300)))throw new IllegalArgumentException("recent reauthentication is required");}
    private void ensurePersonOwned(Jwt jwt,UUID id){if(id!=null && jdbc.queryForObject("select count(*) from public.people where id=? and user_id=?",Integer.class,id,uid(jwt))==0)throw new IllegalArgumentException("personId does not belong to the current user");}
    private void ensureInsightOwned(Jwt jwt,UUID id){if(id!=null && jdbc.queryForObject("select count(*) from public.insights where id=? and user_id=?",Integer.class,id,uid(jwt))==0)throw new IllegalArgumentException("insightId does not belong to the current user");}
    private void validateScore(String emotion,int intensity,int score){int polarity=switch(emotion){case "joy","love","excited" -> 1;case "neutral" -> 0;case "sadness","anger","anxiety" -> -1;default -> throw new IllegalArgumentException("unsupported emotion");};if(score != polarity*intensity)throw new IllegalArgumentException("score does not match emotion and intensity");}
    public record PersonRequest(@NotBlank @Size(max=20) String name,@NotBlank String relationType,String memo){}
    public record EntryRequest(@NotBlank @Size(max=2000) String body,UUID personId,@NotBlank String emotion,@Min(1) @Max(3) int intensity,@Min(-3) @Max(3) int score,OffsetDateTime createdAt){}
    public record TodoRequest(@NotBlank @Size(max=100) String title,UUID personId,String source,UUID insightId){}
    public record TodoUpdate(String title,Boolean done){}
    public record HistoryRequest(@Min(0) @Max(100) int index,@Min(0) int entryCount){}
    public record InsightRequest(@NotBlank String type,@NotNull UUID personId,@NotBlank String message,@Min(0) @Max(100) int indexFrom,@Min(0) @Max(100) int indexTo,@Min(0) Integer negCount){}
    public record ProfileRequest(String nickname,Boolean consentPrivacy,Boolean consentAiAnalysis,Boolean consentAnalytics,Boolean notificationInsight,Boolean notificationReminder,String reminderTime){}
}
