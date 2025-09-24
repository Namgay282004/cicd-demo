# Snyk Integration Troubleshooting Guide

This guide provides solutions for common Snyk integration issues in GitHub Actions workflows.

## Common Issues and Solutions

### Issue 1: "Build fails due to vulnerabilities"

**Problem**: Snyk fails the build due to detected vulnerabilities

**Solutions**:

1. **Review vulnerability details**:
   ```bash
   # Run locally to see detailed output
   snyk test --maven --severity-threshold=high --json
   ```

2. **Update dependencies to secure versions**:
   ```bash
   # Check for outdated dependencies
   mvn versions:display-dependency-updates
   
   # Update specific dependency in pom.xml
   # Replace vulnerable versions with secure ones
   ```

3. **Adjust severity threshold if appropriate**:
   ```yaml
   # In your workflow, adjust the severity threshold
   with:
     args: --severity-threshold=critical  # Only fail on critical issues
   ```

4. **Use repository variables for flexible configuration**:
   ```yaml
   # Set repository variables:
   # SNYK_SEVERITY_THRESHOLD = "high" or "critical"
   # SNYK_CODE_SEVERITY_THRESHOLD = "high"
   # SNYK_CONTAINER_SEVERITY_THRESHOLD = "critical"
   ```

### Issue 2: "Scan takes too long"

**Problem**: Snyk scan timeout or slow performance

**Solutions**:

1. **Use dependency caching** (already implemented):
   ```yaml
   - name: Cache Snyk dependencies
     uses: actions/cache@v4
     with:
       path: |
         ~/.cache/snyk
         ~/.snyk
       key: snyk-cache-${{ runner.os }}-${{ hashFiles('**/pom.xml') }}
   ```

2. **Scan only changed files for PRs**:
   ```yaml
   # For code scans, only scan changed files in PRs
   if: github.event_name == 'pull_request'
   run: |
     CHANGED_FILES=$(git diff --name-only origin/${{ github.base_ref }}...HEAD -- '*.java')
     snyk code test --include=$CHANGED_FILES
   ```

3. **Split scans across multiple jobs** (already implemented):
   ```yaml
   strategy:
     matrix:
       scan-type: [dependencies, code]
   ```

4. **Add timeouts to prevent hanging**:
   ```yaml
   timeout-minutes: 15  # Adjust based on your project size
   ```

### Issue 3: "Authentication failures"

**Problem**: Snyk token authentication issues

**Solutions**:

1. **Verify token in repository secrets**:
   - Go to Settings → Secrets and variables → Actions
   - Ensure `SNYK_TOKEN` is set correctly
   - Token should have appropriate permissions

2. **Test authentication locally**:
   ```bash
   snyk auth YOUR_TOKEN_HERE
   snyk test --maven  # Test if authentication works
   ```

### Issue 4: "No SARIF file generated"

**Problem**: SARIF output not created for GitHub Security tab

**Solutions**:

1. **Ensure SARIF generation is forced**:
   ```bash
   # Always generate SARIF, even if vulnerabilities found
   snyk test --maven --sarif-file-output=results.sarif || true
   ```

2. **Check file existence before upload**:
   ```yaml
   - name: Check SARIF file
     run: |
       if [ -f "snyk-results.sarif" ]; then
         echo "SARIF file found"
       else
         echo "SARIF file missing"
         ls -la *.sarif || echo "No SARIF files found"
       fi
   ```

### Issue 5: "Maven build failures"

**Problem**: Maven compilation issues affecting Snyk scans

**Solutions**:

1. **Ensure clean build before scanning**:
   ```yaml
   - name: Clean build for scanning
     run: mvn clean compile -DskipTests
   ```

2. **Check Java version compatibility**:
   ```yaml
   # Ensure Java version matches project requirements
   - name: Set up JDK
     uses: actions/setup-java@v4
     with:
       java-version: '17'  # Match your project's Java version
       distribution: 'temurin'
   ```

## Debug Mode

### Manual Workflow Trigger

You can now manually trigger the workflow with debug mode:

1. Go to Actions tab in your repository
2. Select "Enhanced CI/CD with Comprehensive Security"
3. Click "Run workflow"
4. Enable debug mode and select severity threshold
5. Check the debug-snyk job output for detailed information

### Debug Commands

Run these commands locally for troubleshooting:

```bash
# Basic Snyk test with debug output
snyk test --maven --debug

# Check dependencies
snyk test --maven --print-deps

# Test specific severity
snyk test --maven --severity-threshold=high --json

# Code scan with debug
snyk code test --debug

# Container scan with debug
docker build -t myapp .
snyk container test myapp --debug
```

### Environment Variables for Debugging

Set these in your workflow for enhanced debugging:

```yaml
env:
  DEBUG: "snyk"                    # Enable Snyk debug output
  SNYK_LOG_LEVEL: "debug"         # Detailed logging
  SNYK_CFG_DISABLE_ANALYTICS: "1" # Disable analytics for faster runs
```

## Performance Optimization

### Repository Variables

Set these repository variables for better control:

| Variable | Purpose | Recommended Value |
|----------|---------|-------------------|
| `SNYK_SEVERITY_THRESHOLD` | Dependency scan threshold | `high` |
| `SNYK_CODE_SEVERITY_THRESHOLD` | Code scan threshold | `high` |
| `SNYK_CONTAINER_SEVERITY_THRESHOLD` | Container scan threshold | `critical` |

### Conditional Scanning

The workflow now includes smart conditional scanning:

- **PRs**: Only scan changed files for code analysis
- **Scheduled runs**: Full comprehensive scans
- **Manual triggers**: Configurable debug mode

### Caching Strategy

The enhanced workflow includes:

- Maven dependency caching
- Snyk cache for faster subsequent runs
- Smart cache keys based on pom.xml changes

## Monitoring and Alerts

### GitHub Security Integration

- SARIF files are uploaded to GitHub Security tab
- Issues appear in the Security → Code scanning alerts
- Pull request checks show security status

### Custom Notifications

The workflow includes:

- Slack notifications for critical issues (configure `SLACK_WEBHOOK_URL`)
- Automatic GitHub issue creation for security vulnerabilities
- Artifact retention for security scan results

## Best Practices

1. **Regular Updates**: Keep Snyk CLI and actions updated
2. **Threshold Management**: Use appropriate severity thresholds for different environments
3. **Performance Monitoring**: Monitor scan duration and optimize as needed
4. **Security Policies**: Implement organization-wide security policies
5. **Developer Training**: Ensure team understands security scan results

## Getting Help

If issues persist:

1. Check the debug-snyk job output
2. Review Snyk documentation: https://docs.snyk.io/
3. Contact your security team or DevOps engineers
4. Consider Snyk support if you have a paid plan

## Version Information

- Snyk CLI: Latest (automatically updated)
- GitHub Actions: Using latest stable versions
- Java: Version 17 (configurable)
- Maven: Version managed by GitHub Actions
