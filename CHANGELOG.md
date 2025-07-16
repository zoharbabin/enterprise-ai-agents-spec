# Changelog

All notable changes to the Enterprise AI Agents Specification will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.1.0] - 2025-07-16

### Fixed
- **BREAKING**: Removed inappropriate project directory creation from enterprise_roo_setup.sh
  - No longer creates `docs/`, `src/`, `tests/`, `infrastructure/`, `security/`, `compliance/`, `performance/`, `data/` directories
  - These directories are project-specific and not part of Roo Code's specification
  - Script now only creates required Roo Code structure: `.roo/`, `.roomodes.yaml`, `.rooignore`

### Changed  
- **BREAKING**: Significantly reduced `.rooignore` restrictions for enterprise AI agent effectiveness
  - Removed exclusions for build artifacts (dist/, build/, target/, *.exe, *.dll, etc.)
  - Removed exclusions for logs and monitoring data (logs/, *.log, monitoring/, metrics/)
  - Removed exclusions for test data and coverage (test-data/, coverage/, .pytest_cache/)
  - Removed exclusions for databases and caches (*.db, *.sqlite, cache/)
  - Removed exclusions for dependencies (node_modules/, vendor/)
  - Now only excludes actual secrets and credentials (.env, *.key, secrets/, etc.)
  - Enterprise AI agents can now access all operational data needed for effective analysis

### Improved
- Updated script messaging to reflect Roo Code focus rather than generic enterprise structure
- Enhanced documentation to clarify that only Roo Code configuration is created
- Maintained all existing functionality for mode selection and template management

## [4.0.0] - 2025-07-15

### Added
- Initial release of Enterprise Roo Code Setup
- 12 specialized enterprise modes (orchestrator, architect, code, debug, devops, security, performance, product, compliance, research, docs, data)
- Automatic workflow orchestration capabilities
- Quality gates and stakeholder approval processes
- Comprehensive security framework
- Local and remote template support
- Interactive mode selection
- Comprehensive validation and error handling