package sg.edu.nus.iss.cicddemo.config;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;

import java.io.IOException;

@Component
public class SecurityHeadersFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        
        // Fix: X-Content-Type-Options Header Missing
        httpResponse.setHeader("X-Content-Type-Options", "nosniff");
        
        // Fix: Insufficient Site Isolation Against Spectre Vulnerability
        httpResponse.setHeader("Cross-Origin-Embedder-Policy", "require-corp");
        httpResponse.setHeader("Cross-Origin-Opener-Policy", "same-origin");
        
        // Fix: Storable and Cacheable Content (prevent caching of dynamic content)
        httpResponse.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        httpResponse.setHeader("Pragma", "no-cache");
        httpResponse.setHeader("Expires", "0");
        
        // Additional security headers
        httpResponse.setHeader("X-Frame-Options", "DENY");
        httpResponse.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");
        httpResponse.setHeader("X-XSS-Protection", "1; mode=block");
        
        chain.doFilter(request, response);
    }
}
