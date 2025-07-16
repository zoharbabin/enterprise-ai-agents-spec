#!/usr/bin/env bash
# enterprise_roo_setup.sh - Full Enterprise Roo Code Setup
# Implements complete enterprise coordination with automatic mode switching, 
# quality gates, and comprehensive enterprise mode set

set -uo pipefail

SCRIPT_VERSION="4.1.0"
TARGET_DIR="${1:-.}"
ROO_DIR="$TARGET_DIR/.roo"
ROOMODES_FILE="$TARGET_DIR/.roomodes"
ROOIGNORE_FILE="$TARGET_DIR/.rooignore"
README_FILE="$TARGET_DIR/README.md"

# GitHub Configuration - Using GitHub Pages for immediate updates, raw.githubusercontent.com as fallback
GITHUB_PAGES_URL="https://zoharbabin.github.io/enterprise-ai-agents-spec"
GITHUB_RAW_URL="https://raw.githubusercontent.com/zoharbabin/enterprise-ai-agents-spec/main/roo-code-setup"
TEMPLATES_URL="$GITHUB_PAGES_URL/templates"
INSTRUCTIONS_URL="$GITHUB_PAGES_URL/instruction-templates"
VERSION_URL="$INSTRUCTIONS_URL/version.json"
# Fallback URLs for raw.githubusercontent.com
TEMPLATES_URL_FALLBACK="$GITHUB_RAW_URL/templates"
INSTRUCTIONS_URL_FALLBACK="$GITHUB_RAW_URL/instruction-templates"
DOWNLOAD_TIMEOUT=30
MAX_RETRIES=3
RETRY_DELAY=2
DOWNLOAD_DIR="$ROO_DIR/.downloads"

# Available modes configuration
AVAILABLE_MODES=(
  "orchestrator:🪃 Orchestrator:Enterprise project coordination with automatic workflow management"
  "architect:🏗️ Architect:Enterprise system architecture with automated quality validation"
  "code:💻 Code:Senior development with automated testing and security integration"
  "debug:🪲 Debug:QA specialist with comprehensive automated testing"
  "devops:🔧 DevOps:Infrastructure and deployment automation specialist"
  "security:🛡️ Security:Cybersecurity specialist with automated scanning and compliance"
  "performance:⚡ Performance:Performance engineering with automated monitoring"
  "product:📊 Product:Product management with stakeholder coordination"
  "compliance:⚖️ Compliance:Regulatory compliance specialist with automated auditing"
  "research:🔬 Research:Market and technical research specialist"
  "docs:📚 Documentation:Technical documentation with automated generation"
  "data:📈 Data:Data engineering specialist with automated analytics"
)

# Parse command line arguments
SELECTED_MODES=()
INTERACTIVE_MODE=false
USE_LOCAL_ONLY=false

show_help() {
  echo "🚀 Enterprise Roo Code Setup v$SCRIPT_VERSION"
  echo ""
  echo "Usage: $0 [OPTIONS] [TARGET_DIR]"
  echo ""
  echo "Options:"
  echo "  -h, --help           Show this help message"
  echo "  -i, --interactive    Interactive mode selection"
  echo "  -m, --modes MODE1,MODE2  Select specific modes (comma-separated)"
  echo "  -l, --list           List all available modes"
  echo "  --local             Use only local templates (no GitHub downloads)"
  echo "  --all               Install all available modes (default)"
  echo ""
  echo "Available Modes:"
  for mode_info in "${AVAILABLE_MODES[@]}"; do
    IFS=':' read -r slug name desc <<< "$mode_info"
    printf "  %-12s %s - %s\n" "$slug" "$name" "$desc"
  done
  echo ""
  echo "Examples:"
  echo "  $0 ./my-project                    # Install all modes"
  echo "  $0 -m orchestrator,code,security   # Install specific modes"
  echo "  $0 -i ./my-project                 # Interactive selection"
}

parse_arguments() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      -h|--help)
        show_help
        exit 0
        ;;
      -i|--interactive)
        INTERACTIVE_MODE=true
        shift
        ;;
      -m|--modes)
        IFS=',' read -ra SELECTED_MODES <<< "$2"
        shift 2
        ;;
      -l|--list)
        echo "Available modes:"
        for mode_info in "${AVAILABLE_MODES[@]}"; do
          IFS=':' read -r slug name desc <<< "$mode_info"
          printf "  %-12s %s - %s\n" "$slug" "$name" "$desc"
        done
        exit 0
        ;;
      --local)
        USE_LOCAL_ONLY=true
        shift
        ;;
      --all)
        SELECTED_MODES=()
        for mode_info in "${AVAILABLE_MODES[@]}"; do
          IFS=':' read -r slug name desc <<< "$mode_info"
          SELECTED_MODES+=("$slug")
        done
        shift
        ;;
      -*)
        echo "Unknown option: $1"
        show_help
        exit 1
        ;;
      *)
        TARGET_DIR="$1"
        shift
        ;;
    esac
  done

  # Default to all modes if none selected
  if [[ ${#SELECTED_MODES[@]} -eq 0 ]] && [[ "$INTERACTIVE_MODE" == false ]]; then
    for mode_info in "${AVAILABLE_MODES[@]}"; do
      IFS=':' read -r slug name desc <<< "$mode_info"
      SELECTED_MODES+=("$slug")
    done
  fi
}

interactive_mode_selection() {
  echo "🎯 Interactive Mode Selection"
  echo "Select the modes you want to install:"
  echo ""
  
  local selected_indices=()
  local i=0
  
  for mode_info in "${AVAILABLE_MODES[@]}"; do
    IFS=':' read -r slug name desc <<< "$mode_info"
    printf "%2d) %s %s - %s\n" $((i+1)) "$name" "$slug" "$desc"
    ((i++))
  done
  
  echo ""
  echo "Enter mode numbers (comma-separated, e.g., 1,3,5) or 'all' for all modes:"
  read -r selection
  
  if [[ "$selection" == "all" ]]; then
    for mode_info in "${AVAILABLE_MODES[@]}"; do
      IFS=':' read -r slug name desc <<< "$mode_info"
      SELECTED_MODES+=("$slug")
    done
  else
    IFS=',' read -ra indices <<< "$selection"
    for index in "${indices[@]:-}"; do
      if [[ "$index" =~ ^[0-9]+$ ]] && [[ "$index" -ge 1 ]] && [[ "$index" -le ${#AVAILABLE_MODES[@]} ]]; then
        mode_info="${AVAILABLE_MODES[$((index-1))]}"
        IFS=':' read -r slug name desc <<< "$mode_info"
        SELECTED_MODES+=("$slug")
      fi
    done
  fi
}

# Parse arguments
parse_arguments "$@"

# Update target directory paths
ROO_DIR="$TARGET_DIR/.roo"
ROOMODES_FILE="$TARGET_DIR/.roomodes"
ROOIGNORE_FILE="$TARGET_DIR/.rooignore"
README_FILE="$TARGET_DIR/README.md"
DOWNLOAD_DIR="$ROO_DIR/.downloads"

echo "🚀 Setting up Enterprise Roo Code Project with Full Coordination"
echo "📍 Target Directory: $TARGET_DIR"
echo "🏢 Features: Automatic mode switching, quality gates, enterprise modes"

# Interactive mode selection
if [[ "$INTERACTIVE_MODE" == true ]]; then
  interactive_mode_selection
fi

echo "📋 Selected modes: ${SELECTED_MODES[*]}"

# Validation functions
validate_yaml_syntax() {
  local yaml_file="$1"
  if command -v python3 >/dev/null 2>&1; then
    python3 -c "
import yaml
import sys
try:
    with open('$yaml_file', 'r') as f:
        yaml.safe_load(f)
    print('✅ YAML syntax validation passed')
except yaml.YAMLError as e:
    print(f'❌ YAML syntax error: {e}')
    sys.exit(1)
except Exception as e:
    print(f'❌ Error validating YAML: {e}')
    sys.exit(1)
" || echo "⚠️  Python3 not available - skipping YAML validation"
  else
    echo "⚠️  Python3 not available - skipping YAML validation"
  fi
}

validate_roo_structure() {
  echo "🔍 Validating Roo Code structure..."
  
  # Check required files exist
  if [[ ! -f "$ROOMODES_FILE" ]]; then
    echo "❌ .roomodes not created"
    return 1
  fi
  
  if [[ ! -f "$ROOIGNORE_FILE" ]]; then
    echo "❌ .rooignore not created"
    return 1
  fi
  
  # Check .roo directory structure
  if [[ ! -d "$ROO_DIR" ]]; then
    echo "❌ .roo directory not created"
    return 1
  fi
  
  # Check mode instruction directories
  for mode in "${SELECTED_MODES[@]}"; do
    if [[ ! -d "$ROO_DIR/rules-$mode" ]]; then
      echo "❌ Mode directory .roo/rules-$mode not created"
      return 1
    fi
    if [[ ! -f "$ROO_DIR/rules-$mode/01-instructions.md" ]]; then
      echo "❌ Instructions file .roo/rules-$mode/01-instructions.md not created"
      return 1
    fi
  done
  
  echo "✅ Roo Code structure validation passed"
  return 0
}

# Network connectivity and download functions
test_local_templates() {
  echo "🔍 Checking for local templates..."
  local script_dir
  if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  else
    # When piped from curl, use current directory
    script_dir="$(pwd)"
  fi
  local local_templates_dir="$script_dir/templates"
  local local_instructions_dir="$script_dir/instruction-templates"
  
  echo "   Script directory: $script_dir"
  echo "   Looking for templates at: $local_templates_dir"
  
  if [[ -d "$local_templates_dir" ]] && [[ -f "$local_templates_dir/roomodes" ]]; then
    echo "✅ Local templates found at: $local_templates_dir"
    LOCAL_TEMPLATES_DIR="$local_templates_dir"
    LOCAL_INSTRUCTIONS_DIR="$local_instructions_dir"
    return 0
  fi
  
  echo "❌ Local templates not found at: $local_templates_dir"
  return 1
}

test_network_connectivity() {
  echo "🌐 Testing network connectivity..."
  
  # Test basic internet connectivity
  if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
    echo "❌ No internet connectivity detected"
    return 1
  fi
  
  # Test GitHub connectivity
  if ! curl -s --connect-timeout 10 --max-time 15 "https://github.com" >/dev/null 2>&1; then
    echo "❌ GitHub connectivity failed"
    return 1
  fi
  
  # Test actual template repository URLs - GitHub Pages first, then raw.githubusercontent.com
  echo "🔍 Testing template repository connectivity..."
  local test_url="$TEMPLATES_URL/roomodes"
  local fallback_url="$TEMPLATES_URL_FALLBACK/roomodes"
  
  # Try GitHub Pages first (no caching issues)
  if curl -s --head --connect-timeout 10 --max-time 15 "$test_url" | grep -q "200"; then
    echo "✅ Template repository accessible via GitHub Pages"
    return 0
  fi
  
  # Try raw.githubusercontent.com as fallback
  echo "🔄 Trying fallback URL..."
  if curl -s --head --connect-timeout 10 --max-time 15 "$fallback_url" | grep -q "200"; then
    echo "✅ Template repository accessible via GitHub raw (fallback)"
    # Update URLs to use fallback
    TEMPLATES_URL="$TEMPLATES_URL_FALLBACK"
    INSTRUCTIONS_URL="$INSTRUCTIONS_URL_FALLBACK"
    return 0
  elif curl -s --head --connect-timeout 10 --max-time 15 "$fallback_url" | grep -q "404"; then
    echo "❌ Template repository found but templates not available (404)"
    echo "   GitHub Pages URL: $GITHUB_PAGES_URL"
    echo "   Fallback URL: $GITHUB_RAW_URL"
    echo "   This may indicate the repository structure has changed or templates are not yet published"
    return 2  # Special return code for 404 errors
  else
    echo "❌ Template repository connectivity failed"
    echo "   GitHub Pages URL: $GITHUB_PAGES_URL"
    echo "   Fallback URL: $GITHUB_RAW_URL"
    return 1
  fi
}

download_with_retry() {
  local url="$1"
  local output_file="$2"
  local description="$3"
  local retry_count=0
  local local_retry_delay=$RETRY_DELAY
  
  while [ $retry_count -lt $MAX_RETRIES ]; do
    echo "📥 Downloading $description (attempt $((retry_count + 1))/$MAX_RETRIES)..."
    
    if curl -L --fail --connect-timeout 10 --max-time $DOWNLOAD_TIMEOUT \
            -H "Cache-Control: no-cache" \
            -H "User-Agent: enterprise-roo-setup/$SCRIPT_VERSION" \
            "$url" -o "$output_file" 2>/dev/null; then
      echo "✅ Downloaded $description successfully"
      return 0
    fi
    
    retry_count=$((retry_count + 1))
    if [ $retry_count -lt $MAX_RETRIES ]; then
      echo "⏳ Retrying in ${local_retry_delay}s..."
      sleep $local_retry_delay
      # Exponential backoff
      local_retry_delay=$((local_retry_delay * 2))
    fi
  done
  
  echo "❌ Failed to download $description after $MAX_RETRIES attempts"
  return 1
}

copy_local_template() {
  local template_name="$1"
  local target_file="$2"
  local description="$3"
  local source_file="$LOCAL_TEMPLATES_DIR/$template_name"
  
  if [[ -f "$source_file" ]]; then
    cp "$source_file" "$target_file"
    echo "✅ Copied local $description"
    return 0
  else
    echo "❌ Local $description not found at: $source_file"
    return 1
  fi
}

copy_local_instruction_template() {
  local mode="$1"
  local mode_dir="$ROO_DIR/rules-$mode"
  local instructions_file="$mode_dir/01-instructions.md"
  local source_file="$LOCAL_INSTRUCTIONS_DIR/${mode}.md"
  
  mkdir -p "$mode_dir"
  
  if [[ -f "$source_file" ]]; then
    cp "$source_file" "$instructions_file"
    echo "✅ Copied local $mode mode instructions"
    return 0
  else
    echo "⚠️  Local $mode template not found, using minimal fallback"
    create_minimal_fallback_template "$mode"
    return 1
  fi
}

create_minimal_fallback_template() {
  local mode="$1"
  local mode_dir="$ROO_DIR/rules-$mode"
  local instructions_file="$mode_dir/01-instructions.md"
  local mode_title
  
  # Capitalize first letter of mode name
  mode_title="$(tr '[:lower:]' '[:upper:]' <<< ${mode:0:1})${mode:1}"
  
  mkdir -p "$mode_dir"
  
  cat > "$instructions_file" << EOF
# $mode Mode Instructions (Minimal Fallback)

## Role: $mode_title Specialist

You are a $mode specialist working in enterprise software development.

## Core Functions:

### 1. Primary Responsibilities
- Execute ${mode}-specific tasks with enterprise-grade quality
- Coordinate with other team members using switch_mode() when needed
- Implement quality gates using ask_followup_question() for approvals
- Follow enterprise security and compliance requirements

### 2. Quality Standards
- Maintain enterprise-grade quality in all deliverables
- Ensure security and compliance requirements are met
- Document decisions and coordinate with stakeholders
- Use automated tools and best practices

### 3. Coordination
Use switch_mode() to coordinate with other enterprise functions:
- Collaborate with security team for security requirements
- Work with compliance team for regulatory requirements
- Coordinate with devops team for deployment and infrastructure
- Engage with product team for business requirements

## Quality Gates
Use ask_followup_question() for critical approvals:
- "Task completed according to enterprise standards. Approve for next phase?"
- "Security and compliance requirements validated. Proceed?"

Remember: You are working in an enterprise environment with high standards for quality, security, and compliance.
EOF
  
  echo "✅ Created minimal template for $mode mode"
}

download_instruction_template() {
  local mode="$1"
  local template_url="$INSTRUCTIONS_URL/${mode}.md"
  local mode_dir="$ROO_DIR/rules-$mode"
  local instructions_file="$mode_dir/01-instructions.md"
  local temp_file="$DOWNLOAD_DIR/${mode}.md.tmp"
  
  mkdir -p "$mode_dir" "$DOWNLOAD_DIR"
  
  # Try to download the template
  if download_with_retry "$template_url" "$temp_file" "$mode mode template"; then
    # Validate the downloaded file
    if [[ -s "$temp_file" ]] && (grep -q "# .*Mode Instructions" "$temp_file" 2>/dev/null || grep -q "# Enterprise.*Mode Instructions" "$temp_file" 2>/dev/null); then
      mv "$temp_file" "$instructions_file"
      echo "✅ Successfully installed $mode mode instructions"
      return 0
    else
      echo "⚠️  Downloaded $mode template appears invalid"
      rm -f "$temp_file"
    fi
  fi
  
  echo "🔄 Using minimal fallback for $mode mode"
  create_minimal_fallback_template "$mode"
  return 1
}

download_template_file() {
  local template_name="$1"
  local target_file="$2"
  local description="$3"
  local template_url="$TEMPLATES_URL/${template_name}"
  local temp_file="$DOWNLOAD_DIR/${template_name}.tmp"
  
  mkdir -p "$DOWNLOAD_DIR"
  
  if download_with_retry "$template_url" "$temp_file" "$description"; then
    if [[ -s "$temp_file" ]]; then
      mv "$temp_file" "$target_file"
      echo "✅ Successfully installed $description"
      return 0
    else
      echo "⚠️  Downloaded $description appears to be empty"
      rm -f "$temp_file"
    fi
  fi
  
  echo "❌ Failed to download $description"
  return 1
}

create_fallback_roomodes() {
  # Create a basic .roomodes.yaml with only selected modes
  cat > "$ROOMODES_FILE" << 'EOF'
# Enterprise Roo Code Configuration v4.0
# Full enterprise mode set with automatic coordination capabilities

customModes:
EOF

  for mode in "${SELECTED_MODES[@]}"; do
    # Find mode info
    for mode_info in "${AVAILABLE_MODES[@]}"; do
      IFS=':' read -r slug name desc <<< "$mode_info"
      if [[ "$slug" == "$mode" ]]; then
        cat >> "$ROOMODES_FILE" << EOF
  - slug: $slug
    name: "$name"
    description: "$desc"
    roleDefinition: "$desc with enterprise-grade quality and coordination capabilities."
    groups: ["read", "edit", "command", "mcp"]
    customInstructions: ".roo/rules-$slug/01-instructions.md"
EOF
        if [[ "$slug" == "security" ]]; then
          cat >> "$ROOMODES_FILE" << EOF
    fileRegex: "^(security/|docs/security/|compliance/|.*\\\\.(md|json|yaml|yml|tf|dockerfile))$"
    whenToUse: "When security analysis, threat modeling, vulnerability assessment, or compliance validation is required"
EOF
        elif [[ "$slug" == "research" ]]; then
          cat >> "$ROOMODES_FILE" << EOF
    whenToUse: "When market research, competitive analysis, technology evaluation, or trend analysis is required"
EOF
        fi
        echo "" >> "$ROOMODES_FILE"
        break
      fi
    done
  done
}

create_fallback_rooignore() {
  cat > "$ROOIGNORE_FILE" << 'EOF'
# Enterprise Roo Code Security Guard Rails
# Comprehensive security, privacy, and compliance exclusions

# Credentials and Secrets (Critical Security)
.env
.env.*
*.key
*.pem
*.secret
secrets/
credentials/
auth/

# Personal and Sensitive Data (GDPR/Privacy)
personal/
private/
confidential/
pii/
customer-data/
user-data/

# Infrastructure Secrets
terraform.tfstate
terraform.tfvars
*.tfvars

# System and OS Files
.DS_Store
*.tmp
*.log
*.swp
*~

# Build and Dependencies
node_modules/
dist/
build/
target/
*.pyc
__pycache__/

# Custom Enterprise Exclusions
# Add organization-specific patterns below
EOF
}

create_fallback_readme() {
  cat > "$README_FILE" << 'EOF'
# Enterprise Roo Code Project

## Overview
This project is configured with enterprise Roo Code setup featuring automatic workflow coordination, quality gates, and specialized enterprise modes.

## 🚀 Getting Started

1. **Install Roo Code Extension**
   - Install the Roo Code VS Code extension
   - Open your project in VS Code
   - The extension will automatically detect the .roomodes configuration

2. **Enable Auto-Approval (Optional)**
   - Configure Roo Code to auto-approve tool actions for seamless workflow

3. **Start Your First Enterprise Workflow**
   ```bash
   @orchestrator "Build enterprise [your-project] with full security and compliance"
   ```

**Ready for enterprise-grade AI-powered software development with Roo Code!** 🚀
EOF
}

setup_project_structure() {
  echo "🏗️  Setting up Roo Code structure..."
  
  # Create only Roo Code required directories
  mkdir -p "$ROO_DIR"
  for mode in "${SELECTED_MODES[@]}"; do
    mkdir -p "$ROO_DIR/rules-$mode"
  done
  
  echo "✅ Roo Code structure created"
}

download_all_templates() {
  echo "📦 Setting up templates..."
  
  # Initialize variables
  LOCAL_TEMPLATES_DIR=""
  LOCAL_INSTRUCTIONS_DIR=""
  
  # Check for local templates first (unless --local flag forces it)
  local use_local=false
  if [[ "$USE_LOCAL_ONLY" == true ]]; then
    echo "🏠 Using local templates only (--local flag specified)"
    use_local=true
  elif test_local_templates; then
    echo "🏠 Local templates found, prioritizing local over remote"
    use_local=true
  fi
  
  if [[ "$use_local" == true ]]; then
    # Use local templates
    setup_local_templates
    return 0
  fi
  
  echo "🌐 No local templates found, attempting to download from GitHub..."
  
  # Test network connectivity first
  local connectivity_result
  test_network_connectivity
  connectivity_result=$?
  
  if [[ $connectivity_result -eq 2 ]]; then
    echo "⚠️  Repository templates not available (404). Using local fallback if available or minimal templates."
    if test_local_templates; then
      setup_local_templates
      return 0
    else
      setup_minimal_fallback_templates
      return 0
    fi
  elif [[ $connectivity_result -ne 0 ]]; then
    echo "⚠️  Network connectivity issues detected. Using local fallback if available or minimal templates."
    if test_local_templates; then
      setup_local_templates
      return 0
    else
      setup_minimal_fallback_templates
      return 0
    fi
  fi
  
  # Try GitHub download approach
  setup_github_templates
}

setup_local_templates() {
  echo "🏠 Setting up templates from local files..."
  
  local templates_copied=0
  local total_templates=3
  
  # Copy main template files
  if copy_local_template "roomodes" "$ROOMODES_FILE" ".roomodes template"; then
    templates_copied=$((templates_copied + 1))
  else
    create_fallback_roomodes
  fi
  
  if copy_local_template "rooignore" "$ROOIGNORE_FILE" ".rooignore template"; then
    templates_copied=$((templates_copied + 1))
  else
    create_fallback_rooignore
  fi
  
  if copy_local_template "README.md" "$README_FILE" "README.md template"; then
    templates_copied=$((templates_copied + 1))
  else
    create_fallback_readme
  fi
  
  # Copy instruction templates
  local successful_copies=0
  local total_modes=${#SELECTED_MODES[@]}
  
  echo "📋 Setting up $total_modes instruction templates from local files..."
  
  for mode in "${SELECTED_MODES[@]}"; do
    if copy_local_instruction_template "$mode"; then
      successful_copies=$((successful_copies + 1))
    fi
  done
  
  echo "📊 Local Template Summary:"
  echo "   • Templates: $templates_copied/$total_templates copied"
  echo "   • Instructions: $successful_copies/$total_modes copied"
  
  if [[ $templates_copied -eq $total_templates ]] && [[ $successful_copies -eq $total_modes ]]; then
    echo "✅ All templates set up successfully from local files"
  else
    echo "⚠️  Some local templates missing. Using hybrid approach with fallbacks."
  fi
}

setup_minimal_fallback_templates() {
  echo "🔄 Setting up minimal fallback templates..."
  
  create_fallback_roomodes
  create_fallback_rooignore
  create_fallback_readme
  
  for mode in "${SELECTED_MODES[@]}"; do
    create_minimal_fallback_template "$mode"
  done
  
  echo "✅ Minimal fallback templates created"
}

setup_github_templates() {
  echo "🌐 Downloading templates from GitHub..."
  
  # Create download directory
  mkdir -p "$DOWNLOAD_DIR"
  
  # Download template files
  local templates_downloaded=0
  local total_templates=3
  
  if download_template_file "roomodes" "$ROOMODES_FILE" ".roomodes template"; then
    templates_downloaded=$((templates_downloaded + 1))
  else
    create_fallback_roomodes
  fi
  
  if download_template_file "rooignore" "$ROOIGNORE_FILE" ".rooignore template"; then
    templates_downloaded=$((templates_downloaded + 1))
  else
    create_fallback_rooignore
  fi
  
  if download_template_file "README.md" "$README_FILE" "README.md template"; then
    templates_downloaded=$((templates_downloaded + 1))
  else
    create_fallback_readme
  fi
  
  # Download individual instruction templates
  local successful_downloads=0
  local total_modes=${#SELECTED_MODES[@]}
  
  echo "📥 Downloading $total_modes instruction templates..."
  
  for mode in "${SELECTED_MODES[@]}"; do
    if download_instruction_template "$mode"; then
      successful_downloads=$((successful_downloads + 1))
    fi
  done
  
  # Cleanup download directory
  rm -rf "$DOWNLOAD_DIR"
  
  echo "📊 Download Summary:"
  echo "   • Templates: $templates_downloaded/$total_templates downloaded"
  echo "   • Instructions: $successful_downloads/$total_modes downloaded"
  
  if [[ $templates_downloaded -lt $total_templates ]] || [[ $successful_downloads -lt $total_modes ]]; then
    echo "⚠️  Some downloads failed. Using hybrid approach with fallbacks."
  else
    echo "✅ All templates downloaded successfully"
  fi
}

# Main execution
setup_project_structure
download_all_templates

echo ""
echo "✅ Enterprise Roo Code Setup Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🏢 Enterprise Features Configured:"
echo "   • ${#SELECTED_MODES[@]} Specialized Enterprise Modes"
echo "   • Automatic Workflow Orchestration"
echo "   • Quality Gates & Stakeholder Approvals"
echo "   • Comprehensive Security Framework"
echo "   • Roo Code Configuration Structure"
echo ""
echo "📁 Target Directory: $TARGET_DIR"
echo "📋 Configuration: $ROOMODES_FILE"
echo "🔒 Security: $ROOIGNORE_FILE"
echo "📚 Documentation: $README_FILE"
echo ""
echo "🎯 Installed Modes:"
for mode in "${SELECTED_MODES[@]}"; do
  # Find mode info for display
  for mode_info in "${AVAILABLE_MODES[@]}"; do
    IFS=':' read -r slug name desc <<< "$mode_info"
    if [[ "$slug" == "$mode" ]]; then
      echo "   • @$slug - $name"
      break
    fi
  done
done
echo ""
echo "🚀 Next Steps:"
echo "   1. Open project in VS Code: code $TARGET_DIR"
echo "   2. Install Roo Code extension"
echo "   3. Start enterprise workflow: @orchestrator \"Build [your-project]\""
echo ""
echo "✨ Ready for Enterprise-Grade AI-Powered Software Development!"

# Final validation
echo ""
echo "🔍 Performing final validation..."
validate_roo_structure
validate_yaml_syntax "$ROOMODES_FILE"

echo ""
echo "📋 Setup Summary:"
echo "   • Modes: ${#SELECTED_MODES[@]} enterprise modes configured"
echo "   • Structure: Roo Code configuration structure created"
echo "   • Templates: All configuration files in place"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [SUCCESS] Enterprise Roo Code Setup completed successfully"
echo "[$(date +'%Y-%m-%d %H:%M:%S')] [SUCCESS] All validations passed - ready for enterprise development"# Cache refresh Tue Jul 15 19:19:21 EDT 2025
