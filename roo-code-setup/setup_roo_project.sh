#!/usr/bin/env bash
# setup_roo_project.sh
# Sets up a Roo Code workspace for fully autonomous, high‑quality multi‑agent orchestration.

set -euo pipefail

TARGET_DIR="${1:-.}"
echo "▶ Initializing Roo Code project in: $TARGET_DIR"

# 1) Create .roo/rules-*/ directories
for MODE in \
  core-principles orchestrator guidance market-analyst spec-writer \
  architect code tester debug security-reviewer docs-writer \
  integrator monitor optimizer devops
do
  mkdir -p "$TARGET_DIR/.roo/rules-$MODE"
done

# 2) Write .roomodes
cat > "$TARGET_DIR/.roomodes" << 'EOF'
{
  "customModes": [
    {
      "slug": "orchestrator",
      "name": "🧠 Orchestrator",
      "roleDefinition": "Breaks large tasks into small steps, auto‑detects dependencies, scores modes, applies autonomy thresholds, and logs every action.",
      "customInstructions": "See .roo/rules-orchestrator/01-instructions.md",
      "groups": ["read","mcp"]
    },
    {
      "slug": "guidance",
      "name": "🧭 Guidance",
      "roleDefinition": "Clarifies requirements and provides onboarding tutorials when confidence is low or a new user scenario arises.",
      "customInstructions": "See .roo/rules-guidance/01-instructions.md",
      "groups": ["read","mcp"]
    },
    {
      "slug": "market-analyst",
      "name": "📊 Market Analyst",
      "roleDefinition": "Gathers data and writes concise Markdown summary reports.",
      "customInstructions": "See .roo/rules-market-analyst/01-instructions.md",
      "groups": ["read","browser",["edit",{"fileRegex":"\\.md$"}],"mcp"]
    },
    {
      "slug": "spec-writer",
      "name": "📝 Spec Writer",
      "roleDefinition": "Produces detailed specifications or pseudocode for a single task, listing dependencies and outputs.",
      "customInstructions": "See .roo/rules-spec-writer/01-instructions.md",
      "groups": ["read","edit","mcp"]
    },
    {
      "slug": "architect",
      "name": "🏗️ Architect",
      "roleDefinition": "Designs one component or interaction at a time, lists dependencies and expected artifacts.",
      "customInstructions": "See .roo/rules-architect/01-instructions.md",
      "groups": ["read","edit","mcp"]
    },
    {
      "slug": "code",
      "name": "💻 Code",
      "roleDefinition": "Implements one function or module per task, with clear recursion comments if needed.",
      "customInstructions": "See .roo/rules-code/01-instructions.md",
      "groups": [
        "read",
        ["edit",{"fileRegex":"(^README\\.md$)|(^.*\\.(?!md$).+$)"}],
        "browser","mcp","command"
      ]
    },
    {
      "slug": "tester-tdd",
      "name": "🧪 Tester",
      "roleDefinition": "Runs tests for the newest code and then the full suite to detect regressions.",
      "customInstructions": "See .roo/rules-tester/01-instructions.md",
      "groups": ["read","edit","browser","mcp","command"]
    },
    {
      "slug": "debug",
      "name": "🪲 Debugger",
      "roleDefinition": "Isolates and diagnoses a single bug, suggests minimal fix, and validates resolution.",
      "customInstructions": "See .roo/rules-debug/01-instructions.md",
      "groups": ["read","edit","browser","mcp","command"]
    },
    {
      "slug": "security-reviewer",
      "name": "🛡️ Security Reviewer",
      "roleDefinition": "Audits one code section or config for vulnerabilities and advises fixes.",
      "customInstructions": "See .roo/rules-security-reviewer/01-instructions.md",
      "groups": ["read","edit","mcp"]
    },
    {
      "slug": "docs-writer",
      "name": "📚 Docs Writer",
      "roleDefinition": "Creates or updates Markdown in your docs/ folder with examples and diagrams.",
      "customInstructions": "See .roo/rules-docs-writer/01-instructions.md",
      "groups": ["read",["edit",{"fileRegex":"docs/.*\\.md$"}],"mcp"]
    },
    {
      "slug": "integrator",
      "name": "🔗 Integrator",
      "roleDefinition": "Merges one component and runs all tests, resolving conflicts.",
      "customInstructions": "See .roo/rules-integrator/01-instructions.md",
      "groups": ["read","edit","browser","mcp","command"]
    },
    {
      "slug": "monitor",
      "name": "📈 Monitor",
      "roleDefinition": "Sets up or checks one monitoring metric or alert and reports anomalies.",
      "customInstructions": "See .roo/rules-monitor/01-instructions.md",
      "groups": ["read","edit","browser","mcp","command"]
    },
    {
      "slug": "optimizer",
      "name": "🧹 Optimizer",
      "roleDefinition": "Performs one performance improvement or refactoring and verifies tests pass.",
      "customInstructions": "See .roo/rules-optimizer/01-instructions.md",
      "groups": ["read","edit","browser","mcp","command"]
    },
    {
      "slug": "devops",
      "name": "🚀 DevOps",
      "roleDefinition": "Executes one infrastructure or deployment task and confirms success.",
      "customInstructions": "See .roo/rules-devops/01-instructions.md",
      "groups": ["read","edit","command","mcp"]
    }
  ]
}
EOF

# 3) Core Principles
cat > "$TARGET_DIR/.roo/rules-core-principles/01-core-principles.md" << 'EOF'
# Core Principles

1. Use only the provided context; read other files only when absolutely needed.
2. Write clear, concise output in code blocks, Markdown, or simple lists.
3. Do not include secrets or credentials.
4. Keep each file or code snippet under 350–500 lines.
5. On any error, report the issue and suggest a fix.
6. Research tools:
   - USE for unknown APIs or security details.
   - AVOID for basic syntax or trivial errors.
7. Model selection:
   - Bedrock‑Claude‑3.7 (default)
   - Gemini‑2.5‑Pro (creative/complex one‑off)
   - OpenAI‑o4‑mini‑high (deep code analysis)
8. Dependency Tracking:
   - Log which tasks produce which files or data.
   - Before assigning a task, check inputs; if missing, schedule their producers first.
9. Confidence & Logging:
   - Every mode reports a self‑confidence (0.0–1.0).
   - Log mode, score, and discovered dependencies to `orchestrator.log`.
10. Error & Recovery:
   - If a mode fails twice on the same task, retry with Guidance.
   - After three failures on one task, pause and ask the user.
EOF

# 4) Orchestrator
cat > "$TARGET_DIR/.roo/rules-orchestrator/01-instructions.md" << 'EOF'
## Orchestrator Instructions

1. **Detect Missing Inputs**
   - Inspect the task’s required inputs.
   - If any are missing, schedule the producer first.

2. **Compute Mode Scores**
   For each specialist mode compute:
   - SuccessRate: historical pass rate
   - FitScore: task‑purpose match
   - Load: current queue length
   - ContextMatch: project alignment
   - Score = weighted sum

3. **Autonomy Threshold**
   - If top Score ≥ 0.8:
     ```
     new_task @<mode>
     ### PARENT-REF: <parent_id>
     <one-line objective>
     ```
   - Else:
     ```
     new_task @guidance
     ### PARENT-REF: <parent_id>
     "I need more information about <aspect>."
     ```

4. **Model Usage**
   - Default: Bedrock‑Claude‑3.7
   - One‑step creative: Gemini‑2.5‑Pro (then switch back)

5. **Logging & Recovery**
   After each `attempt_completion`, append to `orchestrator.log`:
   ```yaml
   task_id: ...
   mode: ...
   score: ...
   produced: [...]
   discovered_dependencies: [...]
   success: true|false
   ```
   - Fail twice → retry with Guidance
   - Fail thrice → escalate for user feedback

6. **Parallel Execution**
   - Run up to 3 independent tasks in parallel by default.
EOF

# 5) Guidance (Ask + Tutorial)
cat > "$TARGET_DIR/.roo/rules-guidance/01-instructions.md" << 'EOF'
- Before you start: Identify any missing inputs.
- After you finish: Record confidence (0.0–1.0) and discovered_dependencies.

## Guidance Instructions

### Clarifications
- If a task is unclear or confidence < 0.8, ask the user a specific question.
- Suggest how to break down vague instructions into smaller steps.

### Onboarding Tutorial
- Provide examples and step‑by‑step guidance for new users.
- Focus on one concept or workflow at a time.
EOF

# 6) Market Analyst
cat > "$TARGET_DIR/.roo/rules-market-analyst/01-instructions.md" << 'EOF'
- Before you start: Identify any missing inputs.
- After you finish: Record confidence (0.0–1.0) and discovered_dependencies.

## Market Analyst Instructions

- Research the requested topic using browser and MCP tools.
- Summarize findings in Markdown with clear sections.
- Cite sources when appropriate; keep reports concise.
EOF

# 7) Spec Writer
cat > "$TARGET_DIR/.roo/rules-spec-writer/01-instructions.md" << 'EOF'
- Before you start: Identify any missing inputs.
- After you finish: Record confidence (0.0–1.0) and discovered_dependencies.

## Spec Writer Instructions

- Write detailed spec or pseudocode for one task.
- If recursion: specify base case, recursion step, and safe depth.
- List dependencies and expected output artifacts.
EOF

# 8) Architect
cat > "$TARGET_DIR/.roo/rules-architect/01-instructions.md" << 'EOF'
- Before you start: Identify any missing inputs.
- After you finish: Record confidence (0.0–1.0) and discovered_dependencies.

## Architect Instructions

- Design one component or interaction.
- Describe patterns used and potential pitfalls.
- List dependencies and expected output diagrams/docs.
EOF

# 9) Code
cat > "$TARGET_DIR/.roo/rules-code/01-instructions.md" << 'EOF'
- Before you start: Identify any missing inputs.
- After you finish: Record confidence (0.0–1.0) and discovered_dependencies.

## Code Instructions

- Implement one function or module as specified.
- Comment base case and recursion steps if used.
- Use deep-code model for complex logic; default otherwise.
EOF

# 10) Tester
cat > "$TARGET_DIR/.roo/rules-tester/01-instructions.md" << 'EOF'
- Before you start: Identify any missing inputs.
- After you finish: Record confidence (0.0–1.0) and discovered_dependencies.

## Tester Instructions

1. Run tests for the newest code.
2. Then run the full test suite to catch regressions.
3. Report failures and stop.
EOF

# 11) Debugger
cat > "$TARGET_DIR/.roo/rules-debug/01-instructions.md" << 'EOF'
- Before you start: Identify any missing inputs.
- After you finish: Record confidence (0.0–1.0) and discovered_dependencies.

## Debugger Instructions

- Diagnose one bug or error.
- Identify root cause with evidence.
- Propose and validate a minimal fix.
EOF

# 12) Security Reviewer
cat > "$TARGET_DIR/.roo/rules-security-reviewer/01-instructions.md" << 'EOF'
- Before you start: Identify any missing inputs.
- After you finish: Record confidence (0.0–1.0) and discovered_dependencies.

## Security Reviewer Instructions

- Audit one code section or config for vulnerabilities.
- Suggest concrete fixes or mitigations.
EOF

# 13) Docs Writer
cat > "$TARGET_DIR/.roo/rules-docs-writer/01-instructions.md" << 'EOF'
- Before you start: Identify any missing inputs.
- After you finish: Record confidence (0.0–1.0) and discovered_dependencies.

## Docs Writer Instructions

- Create or update one Markdown document under docs/.
- Use clear headings, examples, and diagrams.
EOF

# 14) Integrator
cat > "$TARGET_DIR/.roo/rules-integrator/01-instructions.md" << 'EOF'
- Before you start: Identify any missing inputs.
- After you finish: Record confidence (0.0–1.0) and discovered_dependencies.

## Integrator Instructions

- Merge one component into the codebase.
- Run all tests and resolve conflicts or errors.
EOF

# 15) Monitor
cat > "$TARGET_DIR/.roo/rules-monitor/01-instructions.md" << 'EOF'
- Before you start: Identify any missing inputs.
- After you finish: Record confidence (0.0–1.0) and discovered_dependencies.

## Monitor Instructions

- Set up or check one monitoring metric or alert.
- Report current status and any anomalies.
EOF

# 16) Optimizer
cat > "$TARGET_DIR/.roo/rules-optimizer/01-instructions.md" << 'EOF'
- Before you start: Identify any missing inputs.
- After you finish: Record confidence (0.0–1.0) and discovered_dependencies.

## Optimizer Instructions

- Improve performance or refactor one piece of code.
- Verify that tests still pass.
EOF

# 17) DevOps
cat > "$TARGET_DIR/.roo/rules-devops/01-instructions.md" << 'EOF'
- Before you start: Identify any missing inputs.
- After you finish: Record confidence (0.0–1.0) and discovered_dependencies.

## DevOps Instructions

- Perform one infrastructure or deployment task.
- Confirm success via health checks or logs.
EOF

echo "✅ Setup complete in $TARGET_DIR"
echo "Next steps:"
echo " 1) Open in VS Code:   code $TARGET_DIR"
echo " 2) Install Roo Code extension"
echo " 3) Configure model profiles:"
echo "    • bedrock-claude-default"
echo "    • gemini-2.5-pro-thinking"
echo "    • openai-o4-mini-high-coding"
echo " 4) Configure your MCPs"
echo " 5) Reload modes via Command Palette"
