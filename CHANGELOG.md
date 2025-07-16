# Changelog

All notable changes to the Enterprise AI Agents Specification will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [5.0.0] - 2025-07-16

### Added
- **MAJOR RELEASE**: Complete Enterprise AI Agents Transformation
- **12 Enhanced Enterprise Mode Templates**: Comprehensive instruction templates for all enterprise modes
  - `orchestrator.md` - Expanded from 89 to 733 lines with advanced workflow orchestration
  - `architect.md` - Enterprise system architecture with automated quality validation
  - `code.md` - Senior development with automated testing and security integration
  - `debug.md` - QA specialist with comprehensive automated testing
  - `devops.md` - Infrastructure and deployment automation specialist
  - `security.md` - Cybersecurity specialist with automated scanning and compliance
  - `performance.md` - Performance engineering with automated monitoring
  - `product.md` - Product management with stakeholder coordination
  - `compliance.md` - Regulatory compliance specialist with automated auditing
  - `research.md` - Market and technical research specialist
  - `docs.md` - Technical documentation with automated generation
  - `data.md` - Data engineering specialist with automated analytics

### Enhanced
- **Quality Gates Integration**: Comprehensive stakeholder approval processes
- **Compliance Framework Support**: Multi-regulatory compliance (GDPR, CCPA, SOX, PCI-DSS, HIPAA, ISO 27001, NIST, SOC 2, FedRAMP)
- **Boundary Definitions**: Clear mode responsibilities and coordination protocols
- **Enterprise Workflow Orchestration**: Automatic mode switching and task delegation
- **Security Framework**: Integrated security scanning and validation across all modes
- **Performance Monitoring**: Automated performance analysis and optimization
- **Documentation Generation**: Automated technical documentation and knowledge management

### Breaking Changes
- **Mode Structure**: Enhanced mode instruction templates with enterprise-grade capabilities
- **Workflow Integration**: New coordination protocols between modes requiring updated workflows
- **Quality Standards**: Elevated quality gates and approval processes
- **Compliance Requirements**: Mandatory compliance validation for enterprise deployments

### Technical Improvements
- Enhanced orchestrator mode with 8x expansion in capabilities (89 → 733 lines)
- Comprehensive security integration across all development phases
- Automated testing and validation pipelines
- Multi-framework compliance support
- Performance optimization and monitoring integration
- Complete audit trail and documentation systems

## [4.1.1] - 2025-07-16

### Fixed
- **CRITICAL**: Fixed `.roomodes.yaml` filename to `.roomodes` (without extension)
  - Roo Code expects configuration file to be named `.roomodes` without any extension
  - This was the root cause of custom modes not loading in Roo Code
  - Updated all script references and renamed template file accordingly
  - Custom modes now load correctly in Roo Code extension

### Changed
- Updated template filename from `roomodes.yaml` to `roomodes`
- Updated all script references to use correct filename
- Fixed validation and error messages to reflect correct filename

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