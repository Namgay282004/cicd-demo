# CI/CD Workshop SAST/DAST 

## Practical 4: Integrating Snyk with GitHub Actions

This project demonstrates comprehensive Snyk integration with GitHub Actions for automated security testing including dependency scanning, static application security testing (SAST), and container security scanning.

## 🚀 Quick Start

1. **Clone the repository**
2. **Set up Snyk token**: Add `SNYK_TOKEN` to your repository secrets
3. **Run locally**: Use `./scripts/test-snyk-local.sh` to test before pushing
4. **Push changes**: The enhanced workflow will automatically run security scans

## 🛡️ Security Features

- **Dependency Scanning**: Identifies vulnerabilities in Maven dependencies
- **Code Security (SAST)**: Static analysis of Java source code
- **Container Security**: Scans Docker images for vulnerabilities
- **Smart Caching**: Optimized performance with dependency caching
- **Conditional Scanning**: Only scans changed files in pull requests
- **Debug Mode**: Manual workflow trigger with detailed debugging

## 🔧 Configuration

### Repository Variables (Optional)

Set these in Settings → Secrets and variables → Actions → Variables:

- `SNYK_SEVERITY_THRESHOLD`: Dependency scan threshold (default: `high`)
- `SNYK_CODE_SEVERITY_THRESHOLD`: Code scan threshold (default: `high`)  
- `SNYK_CONTAINER_SEVERITY_THRESHOLD`: Container scan threshold (default: `critical`)

### Snyk Configuration

The project includes a `.snyk` file with optimized settings for performance and accuracy.

## 🐛 Troubleshooting

### Common Issues

1. **Build fails due to vulnerabilities**: See `SNYK_TROUBLESHOOTING.md` for solutions
2. **Scan timeouts**: Check performance optimization settings
3. **Authentication issues**: Verify `SNYK_TOKEN` in repository secrets
4. **Missing SARIF files**: Enable debug mode to investigate

### Local Testing

Test Snyk integration locally before pushing:

```bash
# Test all scan types with high severity threshold
./scripts/test-snyk-local.sh

# Test only dependencies with critical threshold
./scripts/test-snyk-local.sh --type deps --severity critical

# Enable debug mode
./scripts/test-snyk-local.sh --debug
```

### Debug Mode

Manually trigger the workflow with debug enabled:

1. Go to Actions tab
2. Select "Enhanced CI/CD with Comprehensive Security"
3. Click "Run workflow"
4. Enable debug mode and select severity threshold

## 📁 Project Structure

```
├── .github/workflows/
│   └── enhanced-security.yml     # Main CI/CD workflow
├── .snyk                         # Snyk configuration
├── scripts/
│   ├── test-snyk-local.sh       # Local testing script
│   └── ...                      # Other deployment scripts
├── src/                         # Java source code
├── SNYK_TROUBLESHOOTING.md      # Detailed troubleshooting guide
└── README.md                    # This file
```

## 🔍 Workflow Features

### Matrix Strategy
- Parallel execution of dependency and code scans
- Fail-fast disabled for comprehensive results

### Performance Optimizations
- Dependency caching for faster subsequent runs
- Changed-file-only scanning for pull requests
- Configurable timeouts to prevent hanging

### Security Integration
- SARIF upload to GitHub Security tab
- Automatic issue creation for critical vulnerabilities
- Slack notifications (configure `SLACK_WEBHOOK_URL`)

## 📊 Monitoring

- **GitHub Security Tab**: View detailed vulnerability reports
- **Pull Request Checks**: Security status in PR reviews  
- **Workflow Artifacts**: Downloadable scan results
- **Dashboard Integration**: Results appear in Snyk dashboard

## 🆘 Getting Help

1. Check `SNYK_TROUBLESHOOTING.md` for common issues
2. Use debug mode for detailed logging
3. Test locally with the provided script
4. Review workflow run logs for specific errors

## 📝 License

This project is for educational purposes as part of the CI/CD workshop.