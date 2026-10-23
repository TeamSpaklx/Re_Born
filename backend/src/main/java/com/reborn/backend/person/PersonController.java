package com.reborn.backend.person;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import jakarta.validation.constraints.Pattern;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/people")
public class PersonController {
    private final PersonService service;

    public PersonController(PersonService service) { this.service = service; }

    @GetMapping
    public List<PersonService.PersonResponse> list(Authentication authentication) { return service.list(authentication); }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public PersonService.PersonResponse create(@Valid @RequestBody PersonRequest request,
                                               Authentication authentication) {
        return service.create(request, authentication);
    }

    @PatchMapping("/{id}")
    public PersonService.PersonResponse update(@PathVariable String id, @Valid @RequestBody PersonRequest request,
                                               Authentication authentication) {
        return service.update(id, request, authentication);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable String id, Authentication authentication) { service.delete(id, authentication); }

    @DeleteMapping
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteAll(Authentication authentication) { service.deleteAll(authentication); }

    public record PersonRequest(@NotBlank @Size(max = 20) String name,
                                @NotBlank @Pattern(regexp = "friend|family|teacher|coworker|other") String relation_type,
                                @Size(max = 500) String memo) {}
}
