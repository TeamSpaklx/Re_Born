package com.reborn.backend.config;

import java.util.UUID;

import org.springframework.security.core.Authentication;

public final class AuthenticatedUser {
    private AuthenticatedUser() {}

    public static UUID id(Authentication authentication) {
        return UUID.fromString(authentication.getName());
    }
}
