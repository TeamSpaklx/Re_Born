package com.reborn.backend.todo;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import jakarta.validation.constraints.Pattern;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.OffsetDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/todos")
public class TodoController {
    private final TodoService service;
    public TodoController(TodoService service) { this.service = service; }

    @GetMapping public List<TodoService.TodoResponse> list(Authentication auth) { return service.list(auth); }
    @PostMapping @ResponseStatus(HttpStatus.CREATED)
    public TodoService.TodoResponse create(@Valid @RequestBody TodoRequest request, Authentication auth) {
        return service.create(request, auth);
    }
    @PutMapping("/{id}")
    public TodoService.TodoResponse update(@PathVariable String id, @Valid @RequestBody TodoRequest request,
                                           Authentication auth) { return service.update(id, request, auth); }
    @DeleteMapping("/{id}") @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable String id, Authentication auth) { service.delete(id, auth); }
    @DeleteMapping @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteAll(Authentication auth) { service.deleteAll(auth); }

    public record TodoRequest(@NotBlank @Size(max = 100) String title, String person_id,
                              boolean done, OffsetDateTime done_at,
                              @NotBlank @Pattern(regexp = "manual|suggestion") String source,
                              String insight_id, @NotNull OffsetDateTime created_at) {}
}
