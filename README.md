# GitHub Actions Workflows

## Pipeline Workflow

The `pipeline.yml` workflow runs the complete watershed mapping pipeline on every pull request.

### What it does:

1. **Environment Setup**: Installs Nix and sets up the complete GIS environment defined in `shell.nix`
2. **Script Preparation**: Makes all shell scripts executable and creates required directories
3. **Pipeline Execution**: Runs the `scripts/complete_pipeline.sh` script which includes:
   - Environment setup with GRASS GIS
   - Data acquisition (DEM and OSM data)
   - DEM processing
   - Watershed statistics calculation
   - Map creation with GMT
   - Metadata generation

### Configuration:

- **Triggers**: Pull requests to `main` or `master` branches
- **Runner**: Ubuntu Latest
- **Timeout**: 60 minutes
- **Artifacts**: Pipeline outputs are uploaded and retained for 7 days

### Dependencies:

All dependencies are managed through the Nix environment specified in `shell.nix`, including:
- GRASS GIS
- GDAL
- GMT (Generic Mapping Tools)
- Python with geospatial packages
- Various other GIS tools

### Notes:

- The pipeline continues on error to ensure artifacts are uploaded even if some steps fail
- Disk space is freed up at the start to accommodate large GIS datasets
- Environment variables are set for headless operation of GUI applications

## Code Quality

### SonarCloud Analysis

The repository is configured with [SonarCloud](https://sonarcloud.io) for automated static code analysis. The analysis runs on every pull request to ensure code quality, detect bugs, and maintain consistent coding standards.

**Features:**
- Automated analysis of Python and Shell scripts
- Quality gates for code coverage, complexity, and duplications
- Security vulnerability detection
- Pull request decoration with inline comments

**Setup Required:**
To activate SonarCloud analysis, follow the setup instructions in [docs/SONARCLOUD_SETUP.md](docs/SONARCLOUD_SETUP.md).

**Configuration:**
- Project configuration: `sonar-project.properties`
- Workflow integration: `.github/workflows/pipeline.yml`
- Analyzed directories: `scripts/`, `lib/`, `config/`