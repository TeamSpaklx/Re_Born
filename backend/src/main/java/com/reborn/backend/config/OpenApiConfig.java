package com.reborn.backend.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {
    @Bean
    public OpenAPI rebornOpenAPI() {
        return new OpenAPI().info(new Info()
                .title("Re:Born Backend API")
                .version("v1")
                .description("Re:Born 일기 저장, 감정 분석, 캘린더 조회 API"));
    }
}
