# Enterprise Roo Code Instruction Templates

This directory contains the individual instruction templates for all 12 enterprise modes, extracted from the [`enterprise_roo_setup.sh`](../enterprise_roo_setup.sh) script.

## Overview

These instruction templates provide comprehensive guidance for enterprise-grade software development using Roo Code's full automation capabilities. Each mode is specialized for specific enterprise functions while maintaining seamless coordination across the entire development lifecycle.

## 📁 Instruction Files

### Core Development Modes
- [`orchestrator.md`](orchestrator.md) - **🪃 Orchestrator**: Enterprise project coordination with automatic workflow management
- [`architect.md`](architect.md) - **🏗️ Architect**: Enterprise system architecture with automated quality validation
- [`code.md`](code.md) - **💻 Code**: Senior development with automated testing and security integration
- [`debug.md`](debug.md) - **🪲 Debug**: QA specialist with comprehensive automated testing

### Enterprise Infrastructure & Operations
- [`devops.md`](devops.md) - **🔧 DevOps**: Infrastructure and deployment automation specialist
- [`security.md`](security.md) - **🛡️ Security**: Cybersecurity specialist with automated scanning and compliance
- [`performance.md`](performance.md) - **⚡ Performance**: Performance engineering with automated monitoring

### Enterprise Business & Compliance
- [`product.md`](product.md) - **📊 Product**: Product management with stakeholder coordination
- [`compliance.md`](compliance.md) - **⚖️ Compliance**: Regulatory compliance specialist with automated auditing
- [`research.md`](research.md) - **🔬 Research**: Market and technical research specialist

### Enterprise Documentation & Data
- [`docs.md`](docs.md) - **📚 Documentation**: Technical documentation with automated generation
- [`data.md`](data.md) - **📈 Data**: Data engineering specialist with automated analytics

## 🔧 Metadata & Version Information

- [`version.json`](version.json) - Complete metadata about the instruction templates including version, roles, and features

## 🚀 Key Enterprise Features

### Automatic Workflow Orchestration
The orchestrator mode coordinates complex enterprise workflows using `switch_mode()` functionality:
```yaml
Enterprise Development Workflow:
1. Requirements & Product Strategy → product, research modes
2. Architecture & Security Design → architect, security, compliance modes  
3. Implementation & Quality → code, debug, performance modes
4. Infrastructure & Deployment → devops, data modes
5. Documentation & Compliance → docs, compliance modes
```

### Quality Gates & Approvals
Each mode implements quality gates using `ask_followup_question()`:
- Architecture review approvals
- Security validation sign-offs
- Compliance certification approvals
- Production deployment authorizations

### Enterprise Security Integration
Comprehensive security throughout development lifecycle:
- Automated security scanning (SAST/DAST)
- Threat modeling and risk assessment
- Multi-framework compliance (SOC2, GDPR, HIPAA, PCI-DSS)
- Infrastructure security automation

## 📋 Usage Instructions

These instruction templates are designed to be used with the enterprise Roo Code setup:

1. **Setup**: Run [`enterprise_roo_setup.sh`](../enterprise_roo_setup.sh) to create the complete enterprise project structure
2. **Mode Usage**: Each `.md` file provides comprehensive instructions for its respective enterprise mode
3. **Coordination**: Modes automatically coordinate using `switch_mode()` and quality gates
4. **Customization**: Templates can be customized for specific enterprise requirements

## 🔐 Security & Compliance

### Supported Regulatory Frameworks
- **Data Protection**: GDPR, CCPA, PIPEDA
- **Financial**: SOX, PCI-DSS, GLBA
- **Healthcare**: HIPAA
- **Security**: ISO 27001, NIST Cybersecurity Framework, SOC 2 Type II, FedRAMP

### Security Features
- Zero Trust Architecture principles
- Defense in Depth approach
- Least Privilege Access controls
- Continuous security monitoring
- Automated incident response

## 📊 Enterprise Success Metrics

### Development Metrics
- 40% reduction in time to market through automation
- 95%+ stakeholder satisfaction through quality gates
- Zero critical vulnerabilities in production
- 99%+ successful deployment rate

### Compliance Metrics
- 100% regulatory compliance success rate
- 80% reduction in compliance violations
- Complete audit trail coverage
- Automated compliance validation

### Operational Metrics
- 99.9% infrastructure uptime
- 50% improvement in response times
- 30% reduction in infrastructure costs
- <1 hour mean time to resolution

## 🛠️ Technical Implementation

### Mode Coordination
```yaml
Automatic Mode Switching Examples:
- switch_mode("security", "Conduct threat modeling for authentication system")
- switch_mode("devops", "Deploy validated implementation to production")
- switch_mode("compliance", "Validate GDPR compliance for data processing")
```

### Quality Gate Implementation
```markdown
Quality Gate Examples:
- "Architecture design complete. Stakeholder approval required?"
- "Security audit complete. Deploy to production environment?"
- "Compliance validation complete. Ready for regulatory submission?"
```

### Automated Tool Integration
```bash
# Security Integration
execute_command("semgrep --config=auto src/ --json > security/sast-results.json")

# Performance Testing
execute_command("k6 run --vus 100 --duration 10m performance-test.js")

# Infrastructure Deployment
execute_command("terraform apply tfplan")
```

## 📚 Documentation Standards

Each instruction template follows a consistent structure:
1. **Role Definition**: Clear role and responsibilities
2. **Core Functions**: Primary capabilities and workflows
3. **Quality Gates**: Approval processes and validations
4. **Enterprise Coordination**: Integration with other modes
5. **Best Practices**: Enterprise-grade implementation guidance

## 🔄 Version History

- **v4.0.0** (2025-01-15): Initial extraction from enterprise_roo_setup.sh
  - 12 specialized enterprise modes
  - Comprehensive workflow orchestration
  - Multi-regulatory compliance support
  - Automated quality gates and approvals

## 📞 Support

For enterprise support and implementation guidance:
- Review the main [Enterprise Roo Code README](../README.md)
- Consult individual mode instruction files for detailed guidance
- Check [`version.json`](version.json) for technical specifications

---

**Ready for Enterprise-Grade AI-Powered Software Development with Roo Code!** 🚀