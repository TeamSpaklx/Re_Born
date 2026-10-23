package com.reborn.backend.profile;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Size;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/me")
public class ProfileController {
    private final ProfileService service;

    public ProfileController(ProfileService service) { this.service = service; }

    @GetMapping
    public ProfileService.ProfileResponse get(Authentication authentication) {
        return service.get(authentication);
    }

    @PutMapping
    @ResponseStatus(HttpStatus.OK)
    public ProfileService.ProfileResponse update(@Valid @RequestBody UpdateProfileRequest request,
                                                 Authentication authentication) {
        return service.update(request, authentication);
    }

    public record UpdateProfileRequest(@Size(max = 30) String nickname,
                                       Boolean consentPrivacy,
                                       Boolean consentAiAnalysis,
                                       Boolean consentAnalytics) {}
}
