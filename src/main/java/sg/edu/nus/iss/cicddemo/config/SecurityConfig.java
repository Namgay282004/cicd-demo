package sg.edu.nus.iss.cicddemo.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.header.writers.StaticHeadersWriter;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(authz -> authz
                .anyRequest().permitAll()
            )
            .headers(headers -> headers
                // Fix: X-Content-Type-Options Header Missing
                .contentTypeOptions(contentTypeOptions -> {})
                
                // Fix: Frame options
                .frameOptions(frameOptions -> frameOptions.deny())
                
                // Add custom security headers
                .addHeaderWriter(new StaticHeadersWriter("Cross-Origin-Embedder-Policy", "require-corp"))
                .addHeaderWriter(new StaticHeadersWriter("Cross-Origin-Opener-Policy", "same-origin"))
                .addHeaderWriter(new StaticHeadersWriter("Cache-Control", "no-cache, no-store, must-revalidate"))
                .addHeaderWriter(new StaticHeadersWriter("Pragma", "no-cache"))
                .addHeaderWriter(new StaticHeadersWriter("Expires", "0"))
                .addHeaderWriter(new StaticHeadersWriter("Referrer-Policy", "strict-origin-when-cross-origin"))
                .addHeaderWriter(new StaticHeadersWriter("X-XSS-Protection", "1; mode=block"))
            )
            .csrf(csrf -> csrf.disable()); // Disable CSRF for API endpoints
            
        return http.build();
    }
}
