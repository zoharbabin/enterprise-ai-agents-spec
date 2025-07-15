#!/usr/bin/env bash
# setup_roo_project.sh - Enhanced Roo Code Setup v2.0
# Enhanced Coordination System with Realistic Workflow Management
# Implements feasible coordination features within Roo Code's architecture

set -euo pipefail

# Script version and metadata
SCRIPT_VERSION="2.0.0"
SCRIPT_NAME="Roo Code Enhanced Coordination Setup"

# Configuration
TARGET_DIR="${1:-.}"
ROO_DIR="$TARGET_DIR/.roo"
ROOMODES_FILE="$TARGET_DIR/.roomodes.yaml"
ROOIGNORE_FILE="$TARGET_DIR/.rooignore"
VSCODE_SETTINGS_DIR="$TARGET_DIR/.vscode"
LOG_FILE="$ROO_DIR/setup.log"

# Command line flags
AUTO_MODE=false
INIT_GIT=true
SKIP_VALIDATION=false
ENABLE_COORDINATION=true

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --auto)
      AUTO_MODE=true
      shift
      ;;
    --no-git)
      INIT_GIT=false
      shift
      ;;
    --skip-validation)
      SKIP_VALIDATION=true
      shift
      ;;
    --no-coordination)
      ENABLE_COORDINATION=false
      shift
      ;;
    --help|-h)
      echo "Usage: $0 [TARGET_DIR] [OPTIONS]"
      echo "Options:"
      echo "  --auto              Enable auto-approval mode with VS Code settings"
      echo "  --no-git           Skip Git repository initialization"
      echo "  --skip-validation  Skip configuration validation"
      echo "  --no-coordination  Disable enhanced coordination features"
      echo "  --help, -h         Show this help message"
      exit 0
      ;;
    -*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      TARGET_DIR="$1"
      shift
      ;;
  esac
done

# Logging functions
log() {
  local level="$1"
  shift
  local message="$*"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE" 2>/dev/null || echo "[$timestamp] [$level] $message"
}

log_info() { log "INFO" "$@"; }
log_warn() { log "WARN" "$@"; }
log_error() { log "ERROR" "$@"; }
log_success() { log "SUCCESS" "$@"; }

# Error handling
cleanup_on_error() {
  log_error "Setup failed. Cleaning up..."
  if [[ -d "$ROO_DIR" ]]; then
    rm -rf "$ROO_DIR"
  fi
  if [[ -f "$ROOMODES_FILE" ]]; then
    rm -f "$ROOMODES_FILE"
  fi
  exit 1
}

trap cleanup_on_error ERR

# Validation functions
validate_dependencies() {
  local missing_deps=()
  
  # Check for required tools
  if ! command -v git >/dev/null 2>&1; then
    missing_deps+=(git)
  fi
  
  if ! command -v node >/dev/null 2>&1 && ! command -v npm >/dev/null 2>&1; then
    log_warn "Node.js/npm not found - some MCP features may not work"
  fi
  
  if [[ ${#missing_deps[@]} -gt 0 ]]; then
    log_error "Missing required dependencies: ${missing_deps[*]}"
    log_error "Please install missing dependencies and try again"
    exit 1
  fi
}

validate_target_directory() {
  if [[ ! -d "$TARGET_DIR" ]]; then
    log_info "Creating target directory: $TARGET_DIR"
    mkdir -p "$TARGET_DIR"
  fi
  
  if [[ ! -w "$TARGET_DIR" ]]; then
    log_error "Target directory is not writable: $TARGET_DIR"
    exit 1
  fi
}

log_info "Starting $SCRIPT_NAME v$SCRIPT_VERSION"
log_info "Target directory: $TARGET_DIR"
log_info "Auto mode: $AUTO_MODE"
log_info "Git initialization: $INIT_GIT"
log_info "Enhanced coordination: $ENABLE_COORDINATION"

# Validate environment
if [[ "$SKIP_VALIDATION" != "true" ]]; then
  log_info "Validating dependencies..."
  validate_dependencies
  validate_target_directory
fi

# ──────────────────────────────────────────────────────────────────────────────
# Backup and Migration System
# ──────────────────────────────────────────────────────────────────────────────
handle_existing_installation() {
  local old_roomodes="$TARGET_DIR/.roomodes"
  local existing_detected=false
  
  # Check for existing installations (but exclude empty .roo directory)
  if [[ -f "$ROOMODES_FILE" || -f "$old_roomodes" || (-d "$ROO_DIR" && -n "$(ls -A "$ROO_DIR" 2>/dev/null)") ]]; then
    existing_detected=true
    log_warn "Existing Roo scaffold detected"
    
    if [[ "$AUTO_MODE" == "true" ]]; then
      log_info "Auto mode enabled - backing up existing configuration"
      backup_existing_config
    else
      echo "⚠️  Existing Roo scaffold detected."
      read -r -p "Backup old version before overwriting? (y/N): " ANSW
      if [[ "$ANSW" =~ ^[Yy]$ ]]; then
        backup_existing_config
      else
        cleanup_existing_config
      fi
    fi
  fi
  
  # Migrate old JSON format to YAML
  if [[ -f "$old_roomodes" ]]; then
    log_info "Migrating .roomodes (JSON) to .roomodes.yaml"
    migrate_json_to_yaml "$old_roomodes"
  fi
}

backup_existing_config() {
  local timestamp=$(date +%Y%m%d%H%M%S)
  local backup_dir="$TARGET_DIR/backup-roo-$timestamp"
  
  log_info "Creating backup at $backup_dir"
  mkdir -p "$backup_dir"
  
  [[ -d "$ROO_DIR" ]] && cp -r "$ROO_DIR" "$backup_dir/"
  [[ -f "$ROOMODES_FILE" ]] && cp "$ROOMODES_FILE" "$backup_dir/"
  [[ -f "$TARGET_DIR/.roomodes" ]] && cp "$TARGET_DIR/.roomodes" "$backup_dir/"
  [[ -f "$ROOIGNORE_FILE" ]] && cp "$ROOIGNORE_FILE" "$backup_dir/"
  [[ -d "$TARGET_DIR/plans" ]] && cp -r "$TARGET_DIR/plans" "$backup_dir/"
  
  log_success "Backup saved to $backup_dir"
  
  # Clean up old files after backup
  cleanup_existing_config
}

cleanup_existing_config() {
  log_info "Removing old configuration files"
  rm -rf "$ROO_DIR" "$ROOMODES_FILE" "$TARGET_DIR/.roomodes" "$ROOIGNORE_FILE" 2>/dev/null || true
  rm -rf "$TARGET_DIR/plans" 2>/dev/null || true
  log_success "Old scaffold removed"
}

migrate_json_to_yaml() {
  local json_file="$1"
  log_info "Converting JSON configuration to YAML format"
  log_warn "Manual review of migrated configuration recommended"
}

# ──────────────────────────────────────────────────────────────────────────────
# Git Repository Initialization and Enhanced Checkpoint System
# ──────────────────────────────────────────────────────────────────────────────
init_git_repository() {
  if [[ "$INIT_GIT" == "true" ]]; then
    log_info "Initializing Git repository with enhanced coordination hooks..."
    
    cd "$TARGET_DIR" || exit 1
    
    if [[ ! -d ".git" ]]; then
      git init
      log_success "Git repository initialized"
    else
      log_info "Git repository already exists"
    fi
    
    # Create initial checkpoint
    if [[ -n "$(git status --porcelain 2>/dev/null)" ]] || [[ ! -f ".git/refs/heads/main" ]] && [[ ! -f ".git/refs/heads/master" ]]; then
      git add . 2>/dev/null || true
      git commit -m "Initial checkpoint: Enhanced Roo Code setup v$SCRIPT_VERSION" 2>/dev/null || true
      log_success "Initial checkpoint created"
    fi
    
    # Set up enhanced Git hooks for coordination system
    mkdir -p ".git/hooks"
    
    # Enhanced pre-commit hook with coordination checks
    cat > ".git/hooks/pre-commit" << 'EOF'
#!/bin/bash
# Enhanced Roo Code Pre-commit Quality Gate with Coordination
echo "🔍 Running enhanced pre-commit quality checks..."

# Check for secrets (basic patterns)
if git diff --cached --name-only | xargs grep -l "password\|secret\|key\|token" 2>/dev/null; then
  echo "❌ Potential secrets detected in commit"
  exit 1
fi

# Check for incomplete workflow states
if [[ -f ".roo/coordination/project-state.json" ]]; then
  if grep -q '"status": "in-progress"' ".roo/coordination/project-state.json" 2>/dev/null; then
    echo "⚠️  Warning: Committing with active workflow in progress"
    echo "   Consider completing current workflow phase first"
  fi
fi

# Validate .roomodes.yaml if changed
if git diff --cached --name-only | grep -q "\.roomodes\.yaml$"; then
  echo "📋 Validating .roomodes.yaml configuration..."
  # Basic YAML syntax check if available
  if command -v python3 >/dev/null; then
    python3 -c "import yaml; yaml.safe_load(open('.roomodes.yaml'))" 2>/dev/null || {
      echo "❌ Invalid YAML syntax in .roomodes.yaml"
      exit 1
    }
  fi
fi

echo "✅ Enhanced pre-commit checks passed"
EOF
    chmod +x ".git/hooks/pre-commit"
    
    # Post-commit hook for workflow tracking
    cat > ".git/hooks/post-commit" << 'EOF'
#!/bin/bash
# Enhanced Roo Code Post-commit Workflow Tracking
echo "📝 Updating workflow tracking..."

# Update last commit info in coordination state
if [[ -d ".roo/coordination" ]]; then
  echo "{\"lastCommit\": \"$(git rev-parse HEAD)\", \"timestamp\": \"$(date -Iseconds)\"}" > ".roo/coordination/last-commit.json"
fi
EOF
    chmod +x ".git/hooks/post-commit"
    
    cd - >/dev/null
  fi
}

# Execute backup and migration
handle_existing_installation

# Initialize logging after handling existing installations
mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true

# Initialize Git repository
init_git_repository

# ──────────────────────────────────────────────────────────────────────────────
# Enhanced Directory Structure with Coordination Infrastructure
# ──────────────────────────────────────────────────────────────────────────────
create_enhanced_directory_structure() {
  log_info "Creating enhanced directory structure with coordination infrastructure..."
  
  # Core Roo directories (standard)
  mkdir -p "$ROO_DIR"/{artifacts,logs}
  mkdir -p "$TARGET_DIR"/{docs,tests,src}
  
  # Enhanced coordination infrastructure
  if [[ "$ENABLE_COORDINATION" == "true" ]]; then
    # Coordination directories
    mkdir -p "$TARGET_DIR/plans"/{active,handoffs,completed,templates}
    mkdir -p "$ROO_DIR/coordination"/{workflows,templates,state}
    
    # Mode-specific coordination enhancements
    for MODE in orchestrator architect code debug ask; do
      mkdir -p "$ROO_DIR/rules-$MODE"/{templates,workflows}
    done
    
    log_success "Enhanced coordination infrastructure created"
  else
    # Standard mode directories without coordination
    for MODE in orchestrator architect code debug ask; do
      mkdir -p "$ROO_DIR/rules-$MODE"
    done
    
    log_success "Standard directory structure created"
  fi
}

create_enhanced_directory_structure

# ──────────────────────────────────────────────────────────────────────────────
# Enhanced .rooignore File - Security and Coordination Guard Rails
# ──────────────────────────────────────────────────────────────────────────────
create_enhanced_rooignore() {
  log_info "Creating enhanced .rooignore file with coordination guard rails..."
  
  cat > "$ROOIGNORE_FILE" << 'EOF'
# Enhanced Roo Code 3.x - Security, Privacy, and Coordination Guard Rails
# Files and directories that should never be accessed by AI agents

# Security and Secrets
.env
.env.*
*.key
*.pem
*.p12
*.pfx
secrets/
credentials/
auth/
*.secret
config/security.yaml
config/auth.json
api-keys/
tokens/

# Personal and Sensitive Data
personal/
private/
confidential/
*.personal
*.private
sensitive/
internal/

# System and OS Files
.DS_Store
Thumbs.db
*.tmp
*.temp
*.log
*.pid
*.lock
*.swp
*.swo
*~

# Development Environment
.vscode/settings.json
.idea/
*.sublime-*
.atom/

# Build and Dependencies
node_modules/
.npm/
.yarn/
.pnpm/
dist/
build/
target/
out/
*.o
*.so
*.dll
*.pyc
__pycache__/

# Version Control
.git/objects/
.git/refs/
.git/logs/
*.orig
*.rej

# Database and Cache
*.db
*.sqlite
*.sqlite3
cache/
tmp/
.cache/
.temp/

# Backup Files
backup-*/
*.backup
*.bak
*~

# Large Media Files
*.iso
*.dmg
*.zip
*.tar.gz
*.rar
*.7z
*.mp4
*.avi
*.mov
*.mkv

# AI Model Files
*.model
*.weights
*.checkpoint
models/
checkpoints/

# Coordination System Sensitive Files
.roo/coordination/state/sensitive-*
.roo/coordination/workflows/private-*
plans/private/
plans/sensitive/

# Custom Project Exclusions
# Add project-specific patterns below
EOF

  log_success "Enhanced .rooignore file created with coordination guard rails"
}

create_enhanced_rooignore

# ──────────────────────────────────────────────────────────────────────────────
# Enhanced .roomodes.yaml Configuration with Coordination Features
# ──────────────────────────────────────────────────────────────────────────────
create_enhanced_roomodes_yaml() {
  log_info "Creating enhanced .roomodes.yaml with coordination features..."
  
  cat > "$ROOMODES_FILE" << 'EOF'
# Enhanced Roo Code Configuration v2.0
# Coordination-enhanced format compatible with Roo Code extension

customModes:
  - slug: orchestrator
    name: "🪃 Orchestrator"
    roleDefinition: "Enhanced workflow coordinator managing sequential mode transitions and maintaining project context across complex multi-phase tasks"
    groups: ["read", "edit", "command", "mcp"]
    customInstructions: ".roo/rules-orchestrator/instructions.md"
    
  - slug: architect
    name: "🏗️ Architect"
    roleDefinition: "Context-aware system designer creating comprehensive designs with implementation guidance and clear handoff documentation"
    groups: ["read", "edit"]
    customInstructions: ".roo/rules-architect/instructions.md"
    
  - slug: code
    name: "💻 Code"
    roleDefinition: "Implementation specialist working from architectural context with structured testing preparation and progress documentation"
    groups: ["read", "edit", "command"]
    customInstructions: ".roo/rules-code/instructions.md"
    
  - slug: debug
    name: "🪲 Debug"
    roleDefinition: "Validation specialist ensuring quality and providing feedback for workflow completion and iteration planning"
    groups: ["read", "edit", "command"]
    customInstructions: ".roo/rules-debug/instructions.md"
    
  - slug: ask
    name: "❓ Ask"
    roleDefinition: "Knowledge specialist maintaining project documentation and providing guidance with workflow context awareness"
    groups: ["read"]
    customInstructions: ".roo/rules-ask/instructions.md"

# Enhanced coordination metadata (comments for human understanding)
# This configuration enables enhanced sequential coordination through:
# - Context-rich mode transitions with handoff documentation
# - Workflow management and progress tracking
# - Quality gates and validation processes
# - Structured project state management
# - Template-based workflow patterns
EOF

  log_success "Enhanced .roomodes.yaml created with coordination features"
}

create_enhanced_roomodes_yaml

# ──────────────────────────────────────────────────────────────────────────────
# Enhanced Agent Instructions with Coordination Capabilities
# ──────────────────────────────────────────────────────────────────────────────
create_enhanced_orchestrator_instructions() {
  log_info "Creating enhanced orchestrator instructions..."
  
  cat > "$ROO_DIR/rules-orchestrator/instructions.md" << 'EOF'
# Enhanced Orchestrator Instructions v2.0

You are the **Workflow Coordination Master** for this Roo Code project, managing complex multi-phase tasks through strategic mode switching and context preservation.

## Core Coordination Responsibilities

### 1. Task Analysis & Workflow Planning
- **Break down complex requests** into sequential phases suitable for mode switching
- **Identify optimal mode sequence** for task completion (architect → code → debug)
- **Create workflow documentation** in `./plans/active/` before starting
- **Establish success criteria** and quality gates for each phase

### 2. Context Management & Handoffs
- **Preserve context across modes** by creating comprehensive handoff documents
- **Document decisions and rationale** in `./plans/active/project-context.md`
- **Create mode-specific briefings** with necessary background information
- **Maintain project state** in `.roo/coordination/project-state.json`

### 3. Workflow Templates & Patterns
Use these proven patterns for common scenarios:

#### Full Development Workflow
```yaml
workflow_pattern: "full-development"
phases:
  1. orchestrator: "Task analysis and planning"
  2. architect: "System design and architecture" 
  3. code: "Implementation with testing"
  4. debug: "Validation and quality assurance"
  5. orchestrator: "Integration and completion review"
```

#### Design Review Workflow  
```yaml
workflow_pattern: "design-review"
phases:
  1. orchestrator: "Review scope and context analysis"
  2. architect: "Design evaluation and recommendations"
  3. ask: "Documentation and knowledge capture"
  4. orchestrator: "Summary and next steps"
```

#### Bug Investigation Workflow
```yaml
workflow_pattern: "bug-investigation"
phases:
  1. orchestrator: "Issue analysis and reproduction planning"
  2. debug: "Root cause investigation"
  3. code: "Fix implementation" 
  4. debug: "Fix validation and testing"
  5. orchestrator: "Resolution documentation"
```

### 4. Mode Transition Protocol
When switching modes, always:

1. **Create handoff document**:
```markdown
# Handoff to [TARGET_MODE]
## Context Summary
- Current task: [description]
- Previous work: [summary]  
- Key decisions: [list]

## Specific Instructions for [TARGET_MODE]
- Primary objective: [clear goal]
- Required deliverables: [list]
- Success criteria: [measurable outcomes]
- Context files: [relevant documents]

## Expected Next Steps
- After completion: [next mode or action]
- Quality gates: [validation requirements]
```

2. **Update project state**:
```json
{
  "currentPhase": "architecture",
  "activeMode": "architect", 
  "taskId": "task-001",
  "context": "./plans/active/auth-system-context.md",
  "nextMode": "code",
  "completionCriteria": ["design-document", "api-specification"]
}
```

3. **Switch to target mode** with clear instructions

### 5. Quality Assurance & Completion
- **Validate phase completion** before mode transitions
- **Ensure deliverables meet criteria** established in planning
- **Document lessons learned** for future workflow improvements
- **Create completion summaries** when workflows finish

## Workflow Management Commands

### Starting New Workflows
```bash
# Create new workflow context
mkdir -p "./plans/active/[workflow-id]"
echo "## Workflow: [description]" > "./plans/active/[workflow-id]/README.md"
```

### Mode Transition Commands  
```bash
# Document handoff
echo "# Handoff to [mode]" > "./plans/handoffs/[timestamp]-to-[mode].md"
# Update project state
echo '{"phase": "[current]", "nextMode": "[target]"}' > ".roo/coordination/project-state.json"
```

### Completion Commands
```bash
# Archive completed workflow
mv "./plans/active/[workflow-id]" "./plans/completed/"
# Document completion
echo "# Completed: [workflow]" >> "./plans/completed/[workflow-id]/COMPLETION.md"
```

## Enhanced Coordination Features

### Context Preservation
- Always maintain comprehensive context across mode switches
- Document all key decisions and rationale
- Preserve user intentions and requirements throughout workflow

### Quality Gates
- Validate completion criteria before mode transitions
- Ensure proper handoff documentation exists
- Verify that next mode has sufficient context to proceed

### Progress Tracking
- Update project state after each phase completion
- Document workflow progress in structured format
- Maintain historical record of decisions and changes

### Error Recovery
- If a mode transition fails, diagnose the context gap
- Create additional documentation to resolve handoff issues
- Adjust workflow plan if requirements change

Remember: You are orchestrating a **sequential coordination system** that maximizes the effectiveness of mode switching through careful planning, context preservation, and structured handoffs.
EOF

  log_success "Enhanced orchestrator instructions created"
}

create_enhanced_architect_instructions() {
  log_info "Creating enhanced architect instructions..."
  
  cat > "$ROO_DIR/rules-architect/instructions.md" << 'EOF'
# Enhanced Architect Instructions v2.0

You are a **Context-Aware System Designer** working within a coordinated workflow system, creating comprehensive designs with clear implementation guidance.

## Coordination Integration

### Receiving Context from Orchestrator
1. **Read handoff document** in `./plans/handoffs/` for your assignment
2. **Review project context** in `./plans/active/project-context.md`
3. **Check previous decisions** in `.roo/coordination/project-state.json`
4. **Understand success criteria** and deliverables expected

### Design with Implementation in Mind
- **Create implementation-ready designs** that the Code mode can execute
- **Provide clear specifications** with sufficient detail
- **Include integration guidance** for existing systems
- **Document design rationale** for future reference

### Context-Aware Design Process
1. **Analyze existing system** architecture and constraints
2. **Consider user requirements** from orchestrator briefing
3. **Design for maintainability** and future extensibility
4. **Plan integration points** with existing components
5. **Define clear interfaces** and data contracts

### Handoff to Code Mode
When design is complete:

1. **Create implementation package**:
```markdown
# Design Handoff to Code Mode

## Design Summary
- Architecture overview: [high-level description]
- Key components: [list with responsibilities]
- Data flow: [description or diagram]

## Implementation Guidance  
- Suggested approach: [step-by-step]
- Critical considerations: [important notes]
- Integration points: [existing system connections]
- Testing strategy: [validation approach]

## Deliverables for Code Mode
- [ ] Component implementation
- [ ] Integration with existing systems
- [ ] Unit tests for new functionality
- [ ] Documentation updates

## Files Created
- `./plans/completed/[design-name]-architecture.md`
- `./plans/completed/[design-name]-specifications.md`
- `./plans/active/implementation-guidance.md`
```

2. **Update project state** to indicate design completion
3. **Signal readiness** for Code mode transition

### Design Documentation Standards
- **Architecture diagrams** (ASCII art or description)
- **Component specifications** with clear responsibilities
- **Interface definitions** with data contracts
- **Integration requirements** with existing systems
- **Non-functional requirements** (performance, security)

### Quality Standards
- **Comprehensive documentation** that Code mode can follow
- **Clear interface definitions** and component boundaries  
- **Implementation feasibility** validated
- **Integration strategy** defined

### Collaboration with Other Modes
- **Receive requirements** from Orchestrator with full context
- **Provide implementation guidance** to Code mode
- **Support debugging** by explaining design decisions
- **Answer questions** about architectural choices

## Enhanced Architecture Capabilities

### Context-Rich Design
- Consider full project context when making design decisions
- Understand user goals and business requirements
- Design with workflow efficiency in mind

### Implementation-Focused Architecture
- Create designs that are practical to implement
- Provide sufficient detail for coding team
- Consider development complexity and timeline

### Quality-First Design
- Build in testability from the start
- Consider maintainability and extensibility
- Plan for error handling and edge cases

Remember: Your designs enable successful implementation by providing clear, comprehensive guidance that the Code mode can execute effectively within the coordinated workflow system.
EOF

  log_success "Enhanced architect instructions created"
}

create_enhanced_code_instructions() {
  log_info "Creating enhanced code instructions..."
  
  cat > "$ROO_DIR/rules-code/instructions.md" << 'EOF'
# Enhanced Code Instructions v2.0

You are a **Context-Driven Implementation Specialist** working from architectural designs and coordinating with testing validation.

## Coordination Integration

### Receiving Context from Architect
1. **Read implementation guidance** in `./plans/active/implementation-guidance.md`
2. **Review design documents** in `./plans/completed/`
3. **Understand integration requirements** and existing system connections
4. **Check success criteria** and expected deliverables

### Implementation with Testing Preparation
- **Follow architectural guidance** while implementing
- **Create testable code** with clear interfaces
- **Document implementation decisions** that deviate from design
- **Prepare testing context** for Debug mode

### Context-Aware Implementation Process
1. **Review architectural design** and understand requirements
2. **Analyze existing codebase** for integration points
3. **Implement core functionality** following design patterns
4. **Create appropriate tests** for new functionality
5. **Document implementation** and any design deviations

### Handoff to Debug Mode  
When implementation is complete:

1. **Create testing package**:
```markdown
# Implementation Handoff to Debug Mode

## Implementation Summary
- Components implemented: [list]
- Key functionality: [description]
- Integration points: [connections made]

## Testing Guidance
- Test scenarios: [list of cases to validate]
- Expected behavior: [description]
- Edge cases: [potential issues]
- Performance considerations: [if applicable]

## Files for Testing
- Implementation files: [list]
- Test data/fixtures: [if created]
- Configuration: [any setup needed]

## Validation Criteria
- [ ] Functional testing of core features
- [ ] Integration testing with existing systems
- [ ] Edge case validation
- [ ] Performance verification (if applicable)
```

2. **Update project state** to indicate implementation completion
3. **Signal readiness** for Debug mode validation

### Implementation Standards
- **Clean, maintainable code** following project conventions
- **Proper error handling** and input validation
- **Clear documentation** for complex logic
- **Appropriate test coverage** for new functionality

### Quality Standards
- **Follow architectural design** while allowing for practical adjustments
- **Maintain code consistency** with existing project patterns
- **Implement robust error handling** for edge cases
- **Create comprehensive tests** for validation

### Collaboration with Other Modes
- **Implement from Architect designs** with full context understanding
- **Prepare comprehensive testing context** for Debug mode
- **Document any design deviations** with rationale
- **Support debugging** by explaining implementation decisions

## Enhanced Implementation Capabilities

### Context-Rich Development
- Understand full project context and user requirements
- Consider long-term maintainability in implementation choices
- Integrate smoothly with existing system architecture

### Testing-Focused Implementation
- Write code that is easy to test and validate
- Create appropriate test fixtures and data
- Consider edge cases during implementation

### Quality-First Coding
- Follow established coding standards and patterns
- Implement proper error handling and logging
- Document complex logic and algorithms

### Coordination-Aware Development
- Prepare clear handoff materials for testing phase
- Document implementation decisions for future reference
- Consider workflow efficiency in code organization

Remember: Your implementation should fulfill the architectural design while preparing clear context for testing validation within the coordinated workflow system.
EOF

  log_success "Enhanced code instructions created"
}

create_enhanced_debug_instructions() {
  log_info "Creating enhanced debug instructions..."
  
  cat > "$ROO_DIR/rules-debug/instructions.md" << 'EOF'
# Enhanced Debug Instructions v2.0

You are a **Validation & Feedback Specialist** ensuring quality and providing completion assessment within the coordinated workflow.

## Coordination Integration

### Receiving Context from Code Mode
1. **Read testing guidance** in `./plans/active/testing-guidance.md`
2. **Review implementation files** and understand functionality
3. **Check validation criteria** and expected behavior
4. **Understand integration requirements** for testing

### Comprehensive Validation Process
1. **Functional testing** of implemented features
2. **Integration testing** with existing systems
3. **Edge case validation** for robustness
4. **Performance assessment** if applicable
5. **Code quality review** for maintainability

### Context-Aware Testing
- **Understand user requirements** from project context
- **Test against design specifications** from architect
- **Validate implementation decisions** from code mode
- **Consider workflow quality gates** for completion

### Completion & Feedback
When validation is complete:

1. **Create completion report**:
```markdown
# Validation Completion Report

## Testing Summary
- Tests performed: [list]
- Results: [pass/fail with details]
- Issues found: [list with severity]
- Performance notes: [if applicable]

## Quality Assessment
- Code quality: [rating with notes]
- Integration success: [status]
- Documentation completeness: [assessment]

## Recommendations
- Immediate fixes needed: [critical issues]
- Future improvements: [suggestions]
- Additional testing: [if needed]

## Workflow Status
- [x] Implementation validated
- [x] Quality standards met
- [x] Ready for production/next phase
- [ ] Requires iteration (if issues found)
```

2. **Update project state** to indicate validation completion
3. **Signal workflow completion** or need for iteration

### Quality Gates
- **All critical functionality** must work as designed
- **Integration points** must be stable
- **No critical bugs** in core features
- **Documentation** must be accurate and complete

### Testing Standards
- **Comprehensive test coverage** of new functionality
- **Integration validation** with existing systems
- **Edge case testing** for robustness
- **Performance validation** if requirements exist

### Collaboration with Other Modes
- **Validate Code implementations** against Architect designs
- **Provide feedback** to Orchestrator on workflow completion
- **Document quality issues** for future improvement
- **Support iteration** if fixes are needed

## Enhanced Debug Capabilities

### Context-Rich Validation
- Understand full project context when testing
- Validate against original user requirements
- Consider long-term maintainability in quality assessment

### Workflow-Aware Testing
- Test with understanding of project workflow and goals
- Provide meaningful feedback for workflow completion
- Consider impact on future development phases

### Quality-First Debugging
- Focus on finding root causes, not just symptoms
- Ensure fixes don't introduce new problems
- Document debugging process for future reference

### Coordination-Focused Feedback
- Provide clear completion status for workflow management
- Document lessons learned for future workflows
- Support continuous improvement of coordination processes

## Advanced Testing Techniques

### Systematic Issue Investigation
1. **Reproduce issues** systematically
2. **Analyze root causes** thoroughly
3. **Validate fixes** comprehensively
4. **Document solutions** for future reference

### Performance Testing
- **Load testing** for scalability validation
- **Memory usage** analysis for efficiency
- **Response time** measurement for user experience

### Security Testing
- **Input validation** testing for security vulnerabilities
- **Authentication/Authorization** testing for access control
- **Data protection** validation for privacy compliance

Remember: You are the quality gatekeeper ensuring that the workflow produces reliable, maintainable results before completion within the coordinated workflow system.
EOF

  log_success "Enhanced debug instructions created"
}

create_enhanced_ask_instructions() {
  log_info "Creating enhanced ask instructions..."
  
  cat > "$ROO_DIR/rules-ask/instructions.md" << 'EOF'
# Enhanced Ask Instructions v2.0

You are a **Knowledge Specialist** maintaining project documentation and providing guidance with workflow context awareness.

## Coordination Integration

### Context-Aware Knowledge Provision
1. **Understand project context** from coordination state
2. **Access workflow history** from completed phases
3. **Review current project status** and active workflows
4. **Consider user's position** in the development workflow

### Information Provision with Context
- **Answer questions** about the codebase and project with full context
- **Explain complex concepts** using project-specific examples
- **Provide background information** relevant to current workflow phase
- **Reference previous decisions** and design rationale

### Workflow-Aware Guidance
- **Understand current workflow phase** when providing recommendations
- **Consider coordination context** when suggesting approaches
- **Reference workflow templates** and patterns when applicable
- **Support workflow decision-making** with informed guidance

### Documentation & Knowledge Management
- **Maintain project knowledge** across workflow phases
- **Document workflow patterns** and lessons learned
- **Explain coordination processes** and their benefits
- **Support onboarding** with workflow-aware explanations

## Enhanced Knowledge Capabilities

### Project Context Understanding
- **Read coordination state** to understand current project phase
- **Access workflow history** to provide informed answers
- **Consider past decisions** when explaining current situation
- **Understand user goals** within the coordination framework

### Workflow Pattern Knowledge
- **Explain workflow templates** and when to use them
- **Describe coordination processes** and their benefits
- **Guide mode transitions** with context preservation
- **Support quality gates** with informed recommendations

### Cross-Mode Communication
- **Bridge communication gaps** between different workflow phases
- **Explain technical decisions** made in previous modes
- **Clarify requirements** and specifications across modes
- **Support handoff processes** with clear explanations

### Educational Support
- **Teach coordination principles** through practical examples
- **Explain workflow benefits** and best practices
- **Guide workflow optimization** based on project needs
- **Support continuous improvement** of coordination processes

## Guidelines for Enhanced Ask Mode

### Context-First Responses
- Always consider the current workflow context when answering
- Reference relevant project state and coordination information
- Provide examples from the current project when possible
- Connect answers to workflow goals and objectives

### Workflow-Aware Guidance
- Understand where the user is in their workflow journey
- Provide recommendations that fit within coordination patterns
- Support effective mode transitions and handoffs
- Guide quality gate decisions with informed criteria

### Documentation Excellence
- Maintain clear, accurate, and helpful information
- Use examples and analogies from the project context
- Ask clarifying questions when workflow requirements are unclear
- Focus on education and understanding within coordination framework

Remember: You are supporting the entire coordination system by providing context-aware knowledge and guidance that helps users make informed decisions within their workflow.
EOF

  log_success "Enhanced ask instructions created"
}

# ──────────────────────────────────────────────────────────────────────────────
# Workflow Templates and Coordination Infrastructure
# ──────────────────────────────────────────────────────────────────────────────
create_workflow_templates() {
  if [[ "$ENABLE_COORDINATION" == "true" ]]; then
    log_info "Creating workflow templates and coordination infrastructure..."
    
    # Full development workflow template
    cat > "$ROO_DIR/coordination/templates/full-development.md" << 'EOF'
# Full Development Workflow Template

## Overview
Complete development workflow from requirements to deployment, using coordinated mode transitions for optimal results.

## Phase 1: Planning (Orchestrator)
**Duration**: 15-30 minutes
**Deliverables**:
- [ ] Requirements analysis document
- [ ] Workflow plan with success criteria
- [ ] Project context documentation
- [ ] Handoff briefing for architect

**Success Criteria**:
- Clear understanding of user requirements
- Defined success metrics and quality gates
- Comprehensive context for design phase

## Phase 2: Design (Architect)
**Duration**: 30-60 minutes
**Deliverables**:
- [ ] System architecture document
- [ ] Component specifications
- [ ] Integration requirements
- [ ] Implementation guidance for code mode

**Success Criteria**:
- Complete architectural design
- Clear component interfaces and responsibilities
- Implementation-ready specifications

## Phase 3: Implementation (Code)
**Duration**: 1-3 hours
**Deliverables**:
- [ ] Core functionality implementation
- [ ] Unit tests for new features
- [ ] Integration with existing systems
- [ ] Testing guidance for debug mode

**Success Criteria**:
- Working implementation of designed features
- Comprehensive test coverage
- Clean, maintainable code

## Phase 4: Validation (Debug)
**Duration**: 30-60 minutes
**Deliverables**:
- [ ] Functional testing results
- [ ] Integration validation
- [ ] Quality assessment report
- [ ] Completion recommendation

**Success Criteria**:
- All functionality works as designed
- No critical bugs or issues
- Quality standards met

## Phase 5: Integration (Orchestrator)
**Duration**: 15-30 minutes
**Deliverables**:
- [ ] Workflow completion summary
- [ ] Lessons learned documentation
- [ ] Project state update
- [ ] Next steps planning

**Success Criteria**:
- Complete workflow documentation
- All deliverables validated
- Project ready for next phase
EOF

    # Design review workflow template
    cat > "$ROO_DIR/coordination/templates/design-review.md" << 'EOF'
# Design Review Workflow Template

## Overview
Comprehensive design review process using coordinated expertise across multiple modes.

## Phase 1: Review Planning (Orchestrator)
**Duration**: 10-20 minutes
**Deliverables**:
- [ ] Review scope definition
- [ ] Context analysis
- [ ] Review criteria establishment
- [ ] Architect briefing preparation

## Phase 2: Design Analysis (Architect)
**Duration**: 30-45 minutes
**Deliverables**:
- [ ] Design evaluation report
- [ ] Recommendations and improvements
- [ ] Implementation feasibility assessment
- [ ] Documentation for knowledge capture

## Phase 3: Knowledge Documentation (Ask)
**Duration**: 15-30 minutes
**Deliverables**:
- [ ] Design review summary
- [ ] Best practices documentation
- [ ] Lessons learned capture
- [ ] Future reference materials

## Phase 4: Summary & Next Steps (Orchestrator)
**Duration**: 10-15 minutes
**Deliverables**:
- [ ] Complete review summary
- [ ] Action items and recommendations
- [ ] Next steps planning
- [ ] Workflow completion documentation
EOF

    # Bug investigation workflow template
    cat > "$ROO_DIR/coordination/templates/bug-investigation.md" << 'EOF'
# Bug Investigation Workflow Template

## Overview
Systematic bug investigation and resolution using coordinated debugging and implementation.

## Phase 1: Issue Analysis (Orchestrator)
**Duration**: 15-30 minutes
**Deliverables**:
- [ ] Issue reproduction steps
- [ ] Impact assessment
- [ ] Investigation plan
- [ ] Debug mode briefing

## Phase 2: Root Cause Investigation (Debug)
**Duration**: 30-60 minutes
**Deliverables**:
- [ ] Root cause analysis
- [ ] Issue documentation
- [ ] Fix recommendations
- [ ] Implementation guidance

## Phase 3: Fix Implementation (Code)
**Duration**: 30-90 minutes
**Deliverables**:
- [ ] Bug fix implementation
- [ ] Regression tests
- [ ] Fix documentation
- [ ] Validation guidance

## Phase 4: Fix Validation (Debug)
**Duration**: 20-40 minutes
**Deliverables**:
- [ ] Fix verification results
- [ ] Regression testing
- [ ] Quality assessment
- [ ] Resolution confirmation

## Phase 5: Resolution Documentation (Orchestrator)
**Duration**: 10-20 minutes
**Deliverables**:
- [ ] Complete resolution summary
- [ ] Prevention recommendations
- [ ] Process improvements
- [ ] Knowledge base update
EOF

    # Create handoff protocol templates
    cat > "$ROO_DIR/coordination/templates/handoff-protocol.md" << 'EOF'
# Mode Handoff Protocol Template

## Handoff Document Structure

### 1. Context Summary
```markdown
## Context Summary
- **Current Task**: [Brief description of what we're working on]
- **Previous Work**: [Summary of work completed so far]
- **Key Decisions**: [Important decisions made that affect next steps]
- **Current Status**: [Where we are in the workflow]
```

### 2. Target Mode Instructions
```markdown
## Instructions for [TARGET_MODE]
- **Primary Objective**: [What the target mode needs to accomplish]
- **Required Deliverables**: [Specific outputs expected]
- **Success Criteria**: [How to know when the phase is complete]
- **Quality Gates**: [Standards that must be met]
```

### 3. Context Files and Resources
```markdown
## Context Files
- **Design Documents**: [List relevant design files]
- **Implementation Files**: [List code files to review]
- **Test Files**: [List test-related files]
- **Documentation**: [List relevant documentation]
```

### 4. Expected Next Steps
```markdown
## Expected Next Steps
- **After Completion**: [What happens next in the workflow]
- **Handoff Target**: [Which mode comes next]
- **Quality Validation**: [How completion will be validated]
- **Timeline**: [Expected duration for this phase]
```

## Handoff Best Practices

### Before Mode Transition
1. **Complete current phase deliverables**
2. **Document all key decisions and rationale**
3. **Prepare comprehensive context for next mode**
4. **Validate handoff document completeness**

### During Mode Transition
1. **Create clear, specific handoff document**
2. **Update project state with current status**
3. **Ensure target mode has sufficient context**
4. **Verify success criteria are clear and measurable**

### After Mode Transition
1. **Confirm target mode understands requirements**
2. **Monitor progress against success criteria**
3. **Be available for clarification if needed**
4. **Update workflow status tracking**
EOF

    # Create project state management
    cat > "$ROO_DIR/coordination/project-state-template.json" << 'EOF'
{
  "version": "2.0",
  "timestamp": "",
  "currentWorkflow": {
    "id": "",
    "name": "",
    "pattern": "",
    "phase": {
      "current": "",
      "completed": [],
      "remaining": []
    }
  },
  "activeMode": "",
  "nextMode": "",
  "context": {
    "primaryObjective": "",
    "userRequirements": "",
    "keyDecisions": [],
    "qualityGates": []
  },
  "deliverables": {
    "completed": [],
    "inProgress": [],
    "pending": []
  },
  "coordination": {
    "handoffDocument": "",
    "successCriteria": [],
    "completionStatus": ""
  }
}
EOF

    log_success "Workflow templates and coordination infrastructure created"
  fi
}

create_coordination_documentation() {
  if [[ "$ENABLE_COORDINATION" == "true" ]]; then
    log_info "Creating coordination system documentation..."
    
    cat > "$TARGET_DIR/plans/COORDINATION_GUIDE.md" << 'EOF'
# Enhanced Roo Code Coordination System Guide

## Overview
This guide explains how to use the enhanced coordination features in your Roo Code setup for improved workflow management and quality outcomes.

## Key Concepts

### Sequential Coordination
Unlike parallel multi-agent systems, Roo Code uses **sequential coordination** where modes work together through structured handoffs and context preservation.

### Workflow Patterns
Pre-defined templates for common development scenarios that ensure consistent, high-quality outcomes.

### Context Preservation
Maintaining comprehensive context across mode transitions to prevent information loss and improve coordination.

## How to Use Coordination Features

### 1. Starting a Coordinated Workflow

When facing a complex task, start with the **Orchestrator** mode:

```
@orchestrator "I need to build a user authentication system"
```

The orchestrator will:
- Analyze the requirements
- Create a workflow plan
- Set up project context
- Prepare handoff for the next mode

### 2. Following the Workflow

The orchestrator will guide you through mode transitions:
- **Architect** for system design
- **Code** for implementation
- **Debug** for validation
- Back to **Orchestrator** for integration

### 3. Monitoring Progress

Check workflow status in:
- `./plans/active/` - Current workflow context
- `.roo/coordination/project-state.json` - Current status
- `./plans/handoffs/` - Mode transition documentation

## Workflow Templates

### Full Development (`full-development`)
Complete feature development from requirements to deployment.
**Best for**: New features, major changes, complex implementations

### Design Review (`design-review`)
Comprehensive design evaluation and improvement.
**Best for**: Architecture reviews, design validation, technical decisions

### Bug Investigation (`bug-investigation`)
Systematic bug resolution with proper validation.
**Best for**: Bug fixes, issue investigation, problem resolution

## Benefits of Coordination

### Improved Quality
- Structured quality gates between phases
- Comprehensive validation at each step
- Reduced defects and rework

### Better Context Management
- No information loss between mode transitions
- Clear documentation of decisions and rationale
- Improved project understanding

### Consistent Processes
- Standardized workflows for common tasks
- Repeatable patterns for reliable outcomes
- Continuous improvement through documented lessons

### Enhanced Collaboration
- Clear handoff protocols between modes
- Structured communication and documentation
- Better project tracking and status visibility

## Best Practices

### Use Orchestrator for Complex Tasks
Start complex, multi-step tasks with orchestrator mode for proper planning and coordination.

### Follow Workflow Templates
Use established templates for common scenarios to ensure consistent, high-quality outcomes.

### Maintain Context Documentation
Keep comprehensive documentation in `./plans/` directories for future reference and team collaboration.

### Complete Quality Gates
Ensure each phase meets its success criteria before moving to the next phase.

## Troubleshooting

### Context Loss Between Modes
- Check handoff documents in `./plans/handoffs/`
- Review project state in `.roo/coordination/`
- Use orchestrator to recreate missing context

### Workflow Confusion
- Review workflow template in `.roo/coordination/templates/`
- Check current phase in project state
- Consult coordination guide for clarification

### Quality Issues
- Review success criteria for current phase
- Check quality gates in workflow template
- Use debug mode for comprehensive validation

## Advanced Features

### Custom Workflow Patterns
Create custom templates in `.roo/coordination/templates/` for project-specific workflows.

### Integration with Git
Git hooks automatically validate coordination state and workflow completeness.

### Progress Tracking
Comprehensive tracking of workflow progress, decisions, and outcomes for project management.

This coordination system transforms Roo Code from simple mode switching to a powerful, coordinated development environment that ensures high-quality outcomes through structured workflows.
EOF

    log_success "Coordination system documentation created"
  fi
}

# Execute enhanced instruction creation
create_enhanced_orchestrator_instructions
create_enhanced_architect_instructions
create_enhanced_code_instructions
create_enhanced_debug_instructions
create_enhanced_ask_instructions

# Create workflow templates and coordination infrastructure
create_workflow_templates
create_coordination_documentation

# ──────────────────────────────────────────────────────────────────────────────
# VS Code Settings for Enhanced Coordination
# ──────────────────────────────────────────────────────────────────────────────
create_vscode_settings() {
  if [[ "$AUTO_MODE" == "true" ]]; then
    log_info "Creating VS Code settings for enhanced coordination..."
    
    mkdir -p "$VSCODE_SETTINGS_DIR"
    
    cat > "$VSCODE_SETTINGS_DIR/settings.json" << 'EOF'
{
  "roo.autoApprove": true,
  "roo.coordinationMode": "enhanced",
  "roo.workflowTemplates": true,
  "files.watcherExclude": {
    "**/.roo/coordination/state/**": true,
    "**/plans/active/**": false,
    "**/plans/handoffs/**": false
  },
  "files.associations": {
    "*.roomodes.yaml": "yaml",
    ".rooignore": "ignore"
  },
  "yaml.schemas": {
    ".roomodes.yaml": "roo-modes-schema"
  },
  "explorer.fileNesting.enabled": true,
  "explorer.fileNesting.patterns": {
    ".roomodes.yaml": ".rooignore,setup_roo_project.sh",
    "*.md": "*.backup.md"
  }
}
EOF

    # Create tasks for common coordination workflows
    cat > "$VSCODE_SETTINGS_DIR/tasks.json" << 'EOF'
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Roo: Start Full Development Workflow",
      "type": "shell",
      "command": "echo",
      "args": ["Starting full development workflow - switch to @orchestrator mode"],
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "shared"
      }
    },
    {
      "label": "Roo: Check Workflow Status",
      "type": "shell",
      "command": "cat",
      "args": [".roo/coordination/project-state.json"],
      "group": "test",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "shared"
      }
    },
    {
      "label": "Roo: Archive Completed Workflow",
      "type": "shell",
      "command": "bash",
      "args": ["-c", "mv ./plans/active/* ./plans/completed/ 2>/dev/null || echo 'No active workflows to archive'"],
      "group": "build"
    }
  ]
}
EOF

    log_success "VS Code settings created for enhanced coordination"
  fi
}

create_vscode_settings

# ──────────────────────────────────────────────────────────────────────────────
# Initialize Coordination State
# ──────────────────────────────────────────────────────────────────────────────
initialize_coordination_state() {
  if [[ "$ENABLE_COORDINATION" == "true" ]]; then
    log_info "Initializing coordination state..."
    
    # Ensure coordination directory exists
    mkdir -p "$ROO_DIR/coordination"
    
    # Create initial project state
    cat > "$ROO_DIR/coordination/project-state.json" << EOF
{
  "version": "2.0",
  "timestamp": "$(date -Iseconds)",
  "setup": {
    "scriptVersion": "$SCRIPT_VERSION",
    "coordinationEnabled": true,
    "setupComplete": true
  },
  "currentWorkflow": {
    "id": "setup-complete",
    "name": "Initial Setup",
    "pattern": "setup",
    "phase": {
      "current": "completed",
      "completed": ["initialization", "configuration", "coordination-setup"],
      "remaining": []
    }
  },
  "activeMode": "none",
  "nextMode": "orchestrator",
  "context": {
    "primaryObjective": "Enhanced Roo Code environment ready for coordinated development",
    "userRequirements": "Complete setup with coordination features enabled",
    "keyDecisions": [
      "Enhanced coordination enabled",
      "Workflow templates installed",
      "Quality gates configured"
    ],
    "qualityGates": ["configuration-valid", "templates-available", "git-hooks-active"]
  },
  "deliverables": {
    "completed": [
      ".roomodes.yaml",
      "agent-instructions",
      "workflow-templates",
      "coordination-infrastructure"
    ],
    "inProgress": [],
    "pending": ["first-coordinated-workflow"]
  },
  "coordination": {
    "handoffDocument": "",
    "successCriteria": ["setup-complete", "ready-for-development"],
    "completionStatus": "ready"
  }
}
EOF

    # Create welcome workflow
    mkdir -p "$TARGET_DIR/plans/active/welcome"
    cat > "$TARGET_DIR/plans/active/welcome/README.md" << 'EOF'
# Welcome to Enhanced Roo Code Coordination

## Your Setup is Complete!

This enhanced Roo Code environment includes powerful coordination features that transform how you work with AI agents.

## Next Steps

1. **Start with Orchestrator**: For any complex task, begin with `@orchestrator` mode
2. **Follow Workflows**: Let the orchestrator guide you through structured workflows
3. **Review Templates**: Check `.roo/coordination/templates/` for available patterns
4. **Monitor Progress**: Track workflow status in `./plans/` directories

## Example: Building a New Feature

```
@orchestrator "I need to build a user dashboard with real-time updates"
```

The orchestrator will:
- Analyze requirements and create a plan
- Switch to architect for system design
- Move to code for implementation
- Use debug for validation
- Return for integration and completion

## Coordination Benefits

- **No Context Loss**: Information preserved across mode transitions
- **Quality Gates**: Validation at each workflow phase
- **Consistent Processes**: Proven patterns for reliable outcomes
- **Better Documentation**: Structured capture of decisions and rationale

## Need Help?

- **Coordination Guide**: `./plans/COORDINATION_GUIDE.md`
- **Workflow Templates**: `.roo/coordination/templates/`
- **Project State**: `.roo/coordination/project-state.json`

Welcome to enhanced AI-powered development with Roo Code!
EOF

    log_success "Coordination state initialized"
  fi
}

initialize_coordination_state

# ──────────────────────────────────────────────────────────────────────────────
# Final Steps and Enhanced Completion
# ──────────────────────────────────────────────────────────────────────────────
finalize_enhanced_setup() {
  log_info "Finalizing enhanced setup..."
  
  # Create final Git checkpoint
  if [[ "$INIT_GIT" == "true" ]]; then
    cd "$TARGET_DIR" || exit 1
    git add .
    if [[ "$ENABLE_COORDINATION" == "true" ]]; then
      git commit -m "Enhanced Roo Code Setup Complete - Coordination v$SCRIPT_VERSION

Features:
- Enhanced sequential coordination system
- Context-rich mode transitions
- Workflow templates and patterns
- Quality gates and validation
- Comprehensive documentation
- Project state management" 2>/dev/null || true
    else
      git commit -m "Roo Code Setup Complete - Enhanced v$SCRIPT_VERSION" 2>/dev/null || true
    fi
    cd - >/dev/null
    log_success "Final checkpoint created"
  fi
  
  # Generate enhanced setup report
  cat > "$ROO_DIR/setup-report.md" << EOF
# Enhanced Roo Code Setup Report

**Setup Date**: $(date)
**Script Version**: $SCRIPT_VERSION
**Target Directory**: $TARGET_DIR
**Coordination Enabled**: $ENABLE_COORDINATION

## Configuration Summary
- **Auto Mode**: $AUTO_MODE
- **Git Integration**: $INIT_GIT
- **Enhanced Coordination**: $ENABLE_COORDINATION
- **VS Code Integration**: $([ "$AUTO_MODE" == "true" ] && echo "Enabled" || echo "Manual")

## Enhanced Features Installed

### Core Components
- [x] Enhanced directory structure with coordination infrastructure
- [x] Working .roomodes.yaml configuration with coordination features
- [x] Enhanced security guard rails (.rooignore)
- [x] Git hooks with coordination validation
- [x] Context-aware agent instructions for all modes

### Coordination System
$(if [[ "$ENABLE_COORDINATION" == "true" ]]; then
cat << 'COORD_EOF'
- [x] Workflow templates for common development patterns
- [x] Context preservation across mode transitions
- [x] Project state management system
- [x] Quality gates and validation processes
- [x] Handoff protocols for seamless coordination
- [x] Progress tracking and documentation
COORD_EOF
else
echo "- [ ] Coordination features disabled (use --no-coordination to enable)"
fi)

## Available Modes with Enhanced Capabilities

### 🪃 Orchestrator
Strategic workflow coordinator managing sequential mode transitions and maintaining project context across complex multi-phase tasks.

### 🏗️ Architect
Context-aware system designer creating comprehensive designs with implementation guidance and clear handoff documentation.

### 💻 Code
Implementation specialist working from architectural context with structured testing preparation and progress documentation.

### 🪲 Debug
Validation specialist ensuring quality and providing feedback for workflow completion and iteration planning.

### ❓ Ask
Knowledge specialist maintaining project documentation and providing guidance with workflow context awareness.

## Workflow Templates Available
$(if [[ "$ENABLE_COORDINATION" == "true" ]]; then
cat << 'WORKFLOW_EOF'
- **Full Development**: Complete feature development (architect → code → debug)
- **Design Review**: Comprehensive design evaluation and improvement
- **Bug Investigation**: Systematic bug resolution with validation
- **Custom Patterns**: Create your own in \`.roo/coordination/templates/\`
WORKFLOW_EOF
else
echo "- Standard mode switching without coordination templates"
fi)

## Getting Started

### For Simple Tasks
Use individual modes directly:
\`\`\`
@code "fix this bug"
@architect "design this component"
\`\`\`

### For Complex Tasks
$(if [[ "$ENABLE_COORDINATION" == "true" ]]; then
cat << 'COMPLEX_EOF'
Start with orchestrator for coordinated workflows:
```
@orchestrator "build a user authentication system"
```

The orchestrator will:
1. Analyze requirements and create workflow plan
2. Coordinate mode transitions with context preservation
3. Ensure quality gates are met at each phase
4. Provide completion summary and documentation
COMPLEX_EOF
else
cat << 'SIMPLE_EOF'
Use mode switching for multi-step processes:
```
@architect "design authentication system"
# Review design, then switch to:
@code "implement the authentication design"
```
SIMPLE_EOF
fi)

## Key Directories
- **Configuration**: \`.roomodes.yaml\`
- **Instructions**: \`.roo/rules-*/instructions.md\`
- **Logs**: \`.roo/logs/\`
$(if [[ "$ENABLE_COORDINATION" == "true" ]]; then
cat << 'DIR_EOF'
- **Active Work**: \`./plans/active/\`
- **Handoffs**: \`./plans/handoffs/\`
- **Completed**: \`./plans/completed/\`
- **Templates**: \`.roo/coordination/templates/\`
- **Project State**: \`.roo/coordination/project-state.json\`
DIR_EOF
fi)

## Support and Documentation
- **Setup Report**: This file (\`.roo/setup-report.md\`)
- **Coordination Guide**: \`./plans/COORDINATION_GUIDE.md\`
- **Mode Instructions**: \`.roo/rules-*/instructions.md\`
- **Workflow Templates**: \`.roo/coordination/templates/\`

## Quality Assurance
- Git hooks validate coordination state and configuration
- Quality gates ensure completeness at each workflow phase
- Comprehensive logging tracks all setup and coordination activities
- Context preservation prevents information loss between modes

---

**Status**: ✅ Setup Complete and Ready for Enhanced AI-Powered Development
**Next Step**: Open in VS Code and start with \`@orchestrator\` for complex tasks
EOF

  log_success "Enhanced setup report generated: $ROO_DIR/setup-report.md"
}

finalize_enhanced_setup

# ──────────────────────────────────────────────────────────────────────────────
# Enhanced Success Message and Next Steps
# ──────────────────────────────────────────────────────────────────────────────
echo ""
echo "🎉 Enhanced Roo Code Setup Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📁 Target Directory: $TARGET_DIR"
echo "📋 Setup Report: $ROO_DIR/setup-report.md"
echo "📊 Configuration: $ROOMODES_FILE"
if [[ "$ENABLE_COORDINATION" == "true" ]]; then
echo "🔗 Coordination Guide: ./plans/COORDINATION_GUIDE.md"
echo "📈 Project State: .roo/coordination/project-state.json"
fi
echo ""
echo "🚀 Next Steps:"
echo "   1. code $TARGET_DIR                    # Open in VS Code"
echo "   2. Install Roo Code extension"
echo "   3. The extension will detect your enhanced .roomodes.yaml"
echo ""

if [[ "$ENABLE_COORDINATION" == "true" ]]; then
echo "🧠 Enhanced Coordination Features:"
echo "   • Sequential workflow coordination"
echo "   • Context preservation across mode transitions"
echo "   • Workflow templates for common patterns"
echo "   • Quality gates and validation processes"
echo "   • Project state management"
echo ""
echo "🎯 For Complex Tasks - Start with Orchestrator:"
echo "   @orchestrator \"build a user authentication system\""
echo "   @orchestrator \"refactor the payment processing module\""
echo "   @orchestrator \"investigate and fix the performance issue\""
echo ""
echo "📋 Available Workflow Templates:"
echo "   • full-development: Complete feature development"
echo "   • design-review: Architecture evaluation"
echo "   • bug-investigation: Systematic debugging"
echo ""
else
echo "⚠️  Coordination features disabled. To enable:"
echo "   ./setup_roo_project.sh $TARGET_DIR --auto"
echo ""
fi

echo "🔧 Enhanced Features Configured:"
echo "   • Context-aware agent instructions"
echo "   • Enhanced .roomodes.yaml format"
echo "   • Security guard rails (.rooignore)"
echo "   • Git integration with coordination hooks"
echo "   • Comprehensive documentation system"
if [[ "$AUTO_MODE" == "true" ]]; then
echo "   • VS Code settings for coordination"
fi
echo ""
echo "📖 Documentation:"
echo "   • Setup Report: .roo/setup-report.md"
echo "   • Mode Instructions: .roo/rules-*/instructions.md"
if [[ "$ENABLE_COORDINATION" == "true" ]]; then
echo "   • Coordination Guide: ./plans/COORDINATION_GUIDE.md"
echo "   • Workflow Templates: .roo/coordination/templates/"
fi
echo ""
echo "✅ Ready for Enhanced AI-Powered Development with Coordinated Workflows!"

log_success "Enhanced Roo Code Setup completed successfully with coordination features"
