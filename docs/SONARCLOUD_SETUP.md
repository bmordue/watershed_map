# SonarCloud Setup Instructions

This document provides step-by-step instructions to complete the SonarCloud integration for the watershed_map project.

## Overview

The repository has been configured with:
- `sonar-project.properties` - SonarCloud configuration file
- GitHub Actions workflow updated to run SonarCloud analysis on every pull request

## Prerequisites Completed ✓

- [x] SonarCloud configuration file created (`sonar-project.properties`)
- [x] GitHub Actions workflow updated (`.github/workflows/pipeline.yml`)
- [x] Source directories configured (scripts, lib, config)
- [x] Exclusions configured (data, output, grassdb, cache files)

## Setup Steps Required

### 1. Create SonarCloud Account

1. Go to [https://sonarcloud.io](https://sonarcloud.io)
2. Click **"Log in"** and choose **"With GitHub"**
3. Authorize SonarCloud to access your GitHub account

### 2. Create SonarCloud Token

1. In SonarCloud, click on your profile icon (top right)
2. Go to **My Account** → **Security**
3. Under **"Generate Tokens"**, enter a name (e.g., "watershed_map_github_actions")
4. Click **"Generate"**
5. **Copy the token** - you won't be able to see it again!

### 3. Add SonarCloud Token to GitHub Secrets

1. Go to your GitHub repository: [https://github.com/bmordue/watershed_map](https://github.com/bmordue/watershed_map)
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **"New repository secret"**
4. Name: `SONAR_TOKEN`
5. Value: Paste the token from Step 2
6. Click **"Add secret"**

### 4. Import Project in SonarCloud

1. In SonarCloud, click the **"+"** icon in the top right
2. Select **"Analyze new project"**
3. Choose **GitHub** as the source
4. Find and select **"bmordue/watershed_map"**
5. Click **"Set Up"**

### 5. Configure Project in SonarCloud

1. When asked **"How do you want to analyze your repository?"**, select:
   - **"With GitHub Actions"** (already configured)
2. SonarCloud will detect the `sonar-project.properties` file
3. Verify the configuration:
   - **Organization**: bmordue
   - **Project Key**: bmordue_watershed_map
   - **Project Name**: Watershed Mapping with FOSS GIS Stack

### 6. Test the Integration

1. Create a test branch or use an existing branch
2. Make a small change (e.g., add a comment to a script)
3. Create a Pull Request to `main` or `master`
4. The GitHub Actions workflow will run automatically
5. Check the workflow run to verify SonarCloud scan completes successfully
6. Go to [https://sonarcloud.io/dashboard?id=bmordue_watershed_map](https://sonarcloud.io/dashboard?id=bmordue_watershed_map) to view results

## Configuration Details

### Project Structure

The SonarCloud analysis is configured to scan:
- **Shell scripts**: `scripts/*.sh`
- **Python scripts**: `scripts/*.py`, `lib/*.py`
- **Configuration**: `config/*.yaml`

### Exclusions

The following directories are excluded from analysis:
- `grassdb/` - GRASS GIS database (auto-generated)
- `data/` - Data files (not code)
- `output/` - Output files (not code)
- `__pycache__/`, `*.pyc` - Python bytecode
- `.venv/`, `venv/` - Virtual environments

### Quality Gates

SonarCloud will provide analysis for:
- **Code Quality**: Bugs, code smells, technical debt
- **Security**: Security hotspots and vulnerabilities
- **Maintainability**: Code complexity, duplications
- **Reliability**: Bug detection and error handling

Note: Test coverage is not currently configured as this project does not have existing test infrastructure.

## Optional: Configure Quality Gates

1. In SonarCloud, go to your project dashboard
2. Click **"Administration"** → **"Quality Gates"**
3. Choose or create a quality gate that fits your needs
4. Common settings:
   - Coverage: (disabled for now - no tests)
   - Duplications: < 3%
   - Maintainability Rating: A
   - Reliability Rating: A
   - Security Rating: A

## Optional: Enable PR Decoration

Pull Request decoration is enabled by default when using the SonarCloud GitHub Action. This will:
- Add analysis comments to your Pull Requests
- Show quality gate status in PR checks
- Highlight new issues introduced in the PR

## Troubleshooting

### "SONAR_TOKEN not found" Error

**Solution**: Make sure you've added the `SONAR_TOKEN` secret to your GitHub repository (Step 3).

### "Project not found" Error

**Solution**: Verify the project key in `sonar-project.properties` matches the one in SonarCloud (should be `bmordue_watershed_map`).

### "Organization not found" Error

**Solution**: Verify you have access to the organization `bmordue` in SonarCloud. If you're using a personal account, you may need to create an organization first.

### Analysis Fails with "No sources to analyze"

**Solution**: This shouldn't happen with the current configuration, but if it does, verify that the `scripts/`, `lib/`, and `config/` directories exist and contain files.

## Support Resources

- [SonarCloud Documentation](https://docs.sonarcloud.io/)
- [GitHub Actions for SonarCloud](https://github.com/SonarSource/sonarcloud-github-action)
- [SonarCloud Community](https://community.sonarsource.com/c/help/sc/9)

## Next Steps

After completing the setup:
1. Monitor the first few SonarCloud reports
2. Address any critical issues found
3. Consider adding test coverage infrastructure in the future
4. Configure custom quality profiles if needed
5. Set up notifications for quality gate failures

---

**Note**: The GitHub Actions workflow (`if: always()`) ensures SonarCloud analysis runs even if the watershed mapping pipeline has errors, providing continuous code quality feedback.
