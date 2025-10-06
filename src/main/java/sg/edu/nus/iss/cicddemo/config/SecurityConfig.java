package sg.edu.nus.iss.cicddemo.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;

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
            )
            .csrf(csrf -> csrf.disable()); // Disable CSRF for API endpoints
            
        return http.build();
    }
}
