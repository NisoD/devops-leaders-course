# Contributing to DevOps Bootcamp - IaC and Monitoring

Thank you for your interest in contributing to this workshop! This guide will help you contribute effectively and ensure a consistent experience for all learners.

## 📖 Contribution Overview

### 🎯 **Our Mission**
Create an accessible, hands-on learning experience that teaches Infrastructure as Code and Observability concepts through practical implementation.

### 🤝 **Types of Contributions Welcome**

| Type | Description | Examples |
|------|-------------|----------|
| 🐛 **Bug Fixes** | Fix issues in code, configurations, or documentation | Terraform errors, broken links, typos |
| 📚 **Documentation** | Improve explanations, add examples, fix formatting | README updates, better error messages |
| ✨ **Features** | Add new learning modules, tools, or capabilities | New monitoring stack, additional tasks |
| 🔧 **Enhancements** | Improve existing workshop experience | Better automation, clearer instructions |
| 🖥️ **Platform Support** | Add support for different OS or environments | Windows WSL improvements, ARM support |
| 🎨 **User Experience** | Make the workshop more accessible and engaging | Better validation scripts, visual guides |

---

## 🚀 Getting Started

### **Step 1: Fork and Clone**
```bash
# Fork the repository on GitHub
# Then clone your fork
git clone https://github.com/YOUR-USERNAME/devops-leaders-course-v2.git
cd devops-leaders-course-v2

# Add upstream remote
git remote add upstream https://github.com/ORIGINAL-OWNER/devops-leaders-course-v2.git
```

### **Step 2: Set Up Development Environment**
```bash
# Install prerequisites (see PREREQUISITES.md)
./Workshop/scripts/verify-setup.sh

# Test current workshop setup
cd Workshop
./scripts/setup-workshop.sh

# Run through a task to understand the flow
cd 01-iac-concepts && cat README.md
```

### **Step 3: Create Feature Branch**
```bash
# Create descriptive branch name
git checkout -b feature/improve-monitoring-docs
# or
git checkout -b fix/terraform-provider-issue
# or  
git checkout -b enhancement/better-validation-script
```

---

## 🛠️ Development Workflow

### **Making Changes**

#### **For Documentation Changes**
```bash
# Edit README files
vim Workshop/01-iac-concepts/README.md

# Test markdown rendering
# (Use VS Code preview or markdown tools)

# Verify links work
./scripts/check-links.sh
```

#### **For Code/Configuration Changes**  
```bash
# Make your changes
vim Workshop/02-terraform-k8s/main.tf

# Test the specific task
cd Workshop/02-terraform-k8s
terraform init
terraform plan
terraform apply

# Test cleanup
terraform destroy
```

#### **For Script Changes**
```bash
# Edit script
vim Workshop/scripts/verify-setup.sh

# Test on clean environment (if possible)
# Ensure script handles edge cases

# Test script help/usage
./scripts/verify-setup.sh --help
```

### **Testing Your Changes**

#### **Comprehensive Testing Checklist**
- [ ] Run `./scripts/verify-setup.sh` successfully
- [ ] Complete affected tasks from start to finish
- [ ] Test both success and failure scenarios  
- [ ] Verify cleanup works properly
- [ ] Check all links in documentation
- [ ] Validate on different platforms (if possible)

#### **Platform-Specific Testing**
```bash
# macOS testing
./test-on-macos.sh

# Linux testing (if you have access)  
./test-on-linux.sh

# Windows WSL testing (if you have access)
./test-on-wsl.sh
```

---

## 📝 Contribution Standards

### **Code Quality Standards**

#### **Terraform Code**
- ✅ Follow HashiCorp style guide
- ✅ Use meaningful variable names and descriptions
- ✅ Include provider version constraints
- ✅ Add comments for complex logic
- ✅ Use consistent formatting (`terraform fmt`)

```hcl
# ✅ Good example
variable "cluster_name" {
  description = "Name of the Kubernetes cluster to create"
  type        = string
  default     = "devops-workshop"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.cluster_name))
    error_message = "Cluster name must contain only lowercase letters, numbers, and hyphens."
  }
}
```

#### **Shell Scripts**
- ✅ Use `#!/bin/bash` shebang
- ✅ Add error handling (`set -euo pipefail`)
- ✅ Include help/usage information
- ✅ Use meaningful variable names
- ✅ Add comments for complex logic

```bash
#!/bin/bash
set -euo pipefail

# ✅ Good example
function validate_docker() {
  if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed"
    return 1
  fi
  
  if ! docker info &> /dev/null; then
    echo "❌ Docker daemon is not running"
    return 1
  fi
  
  echo "✅ Docker is running"
  return 0
}
```

### **Documentation Standards**

#### **README Structure**
Follow this consistent structure across all README files:

```markdown
# Task/Module Title

## 📖 [Module/Task] Outline
- Overview of what's covered
- Learning objectives
- Time estimates
- Prerequisites

## 🚀 Step-by-Step Execution
- Clear, numbered steps
- Expected outputs
- Validation commands

## 🔍 Understanding [Concept]
- Explain what was built/learned
- Why it matters
- Key takeaways

## ✅ Validation Checklist
- Concrete success criteria
- Troubleshooting for common issues

## 📚 Further Reading (Extensions)
- Advanced topics not covered
- Related technologies
- External resources
```

#### **Writing Style Guidelines**
- ✅ **Use active voice**: "Deploy the application" not "The application should be deployed"
- ✅ **Be specific**: "Run `terraform apply`" not "apply the configuration"
- ✅ **Include expected outputs**: Show what success looks like
- ✅ **Add context**: Explain why we're doing something
- ✅ **Use consistent emoji**: Follow established patterns
- ✅ **Keep sections focused**: One concept per section

### **Version Control Standards**

#### **Commit Message Format**
```bash
# Format: type(scope): description
# Examples:
git commit -m "docs(monitoring): improve troubleshooting section"
git commit -m "fix(terraform): correct provider version constraint"
git commit -m "feat(scripts): add automated dashboard import"
git commit -m "enhancement(workshop): better error messages in validation"
```

#### **Commit Types**
- `feat`: New feature or task
- `fix`: Bug fix
- `docs`: Documentation only changes
- `enhancement`: Improve existing functionality
- `refactor`: Code restructuring without feature changes
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

---

## 📋 Pull Request Process

### **Before Submitting PR**

#### **Pre-submission Checklist**
- [ ] Branch is up to date with main branch
- [ ] All tests pass locally
- [ ] Documentation updated (if needed)
- [ ] No breaking changes (or clearly documented)
- [ ] Commit messages follow standards
- [ ] Changes are focused and related

```bash
# Update your branch
git fetch upstream
git rebase upstream/main

# Run final tests
./Workshop/scripts/verify-setup.sh
./test-your-changes.sh
```

### **Pull Request Template**
When creating a PR, include:

```markdown
## 📝 Description
Brief description of changes and why they were made.

## 🧪 Testing
- [ ] Tested on macOS/Linux/Windows
- [ ] All workshop tasks complete successfully
- [ ] Documentation renders correctly
- [ ] No broken links

## 📷 Screenshots (if applicable)
Before/after screenshots for UI changes.

## ⚡ Breaking Changes
List any breaking changes and migration steps.

## 📚 Additional Context
Link to issues, discussions, or external references.
```

### **Review Process**
1. **Automated checks** run on all PRs
2. **Maintainer review** for code quality and workshop fit
3. **Community feedback** welcome on larger changes
4. **Testing** by maintainers on different platforms
5. **Merge** after approval and passing checks

---

## 🎯 Contribution Ideas

### **Good First Contributions**
- Fix typos or broken links
- Improve error messages in scripts
- Add missing validation steps
- Enhance troubleshooting sections
- Test on different platforms and document issues

### **Intermediate Contributions**  
- Add support for additional platforms
- Improve automation scripts
- Create additional dashboard examples
- Add more comprehensive testing
- Enhance workshop validation

### **Advanced Contributions**
- Add new monitoring tools or techniques
- Create alternative deployment methods
- Add advanced troubleshooting tools
- Implement workshop analytics
- Create instructor guides

---

## 🌟 Recognition

### **Contributors Hall of Fame**
All contributors are recognized in:
- Repository README
- Workshop credits
- Release notes for significant contributions

### **Contribution Levels**
- 🥉 **Helper**: Documentation improvements, bug reports
- 🥈 **Contributor**: Feature additions, platform support
- 🥇 **Maintainer**: Ongoing support, major enhancements

---

## 📞 Getting Help

### **Development Questions**
- **GitHub Discussions**: For feature ideas and design questions
- **Issues**: For bug reports and specific problems
- **Direct Contact**: Reach out to maintainers for guidance

### **Resources for Contributors**
- [Terraform Style Guide](https://www.terraform.io/docs/extend/best-practices/naming.html)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
- [Markdown Guide](https://www.markdownguide.org/)
- [Git Best Practices](https://git-scm.com/book/en/v2)

---

## 🚀 Development Environment Setup

### **Recommended Tools**
- **IDE**: VS Code with Terraform, YAML, and Markdown extensions
- **Testing**: Docker Desktop, kind for local cluster testing
- **Validation**: `terraform validate`, `terraform fmt`, markdown linters

### **Local Development Tips**
```bash
# Keep your fork up to date
git fetch upstream
git checkout main  
git merge upstream/main
git push origin main

# Clean up feature branches
git branch -d feature/completed-feature

# Test workshop changes end-to-end
./Workshop/scripts/setup-workshop.sh
# Complete all tasks
./Workshop/scripts/cleanup-workshop.sh
```

---

## 📜 Code of Conduct

### **Our Pledge**
We are committed to providing a welcoming and inclusive experience for all contributors, regardless of background or experience level.

### **Expected Behavior**
- ✅ **Be respectful** and considerate in all interactions
- ✅ **Help others learn** - this is an educational project
- ✅ **Focus on constructive feedback** rather than criticism
- ✅ **Assume good intent** when reviewing contributions
- ✅ **Share knowledge** and document your learnings

### **Unacceptable Behavior**
- ❌ Harassment, discrimination, or exclusionary language
- ❌ Trolling, insulting, or derogatory comments
- ❌ Publishing others' private information
- ❌ Spam or excessive self-promotion

---

**Ready to contribute? We can't wait to see what you build! 🎉**

**Questions?** Open an issue or discussion - the community is here to help!

# Test your changes
./scripts/cleanup.sh
./scripts/setup.sh
```

## 📝 Contribution Guidelines

### Code Standards

#### **Terraform Code**
- Use consistent formatting (`terraform fmt`)
- Include meaningful variable descriptions
- Add appropriate outputs
- Use meaningful resource names
- Include proper tagging

#### **Shell Scripts**
- Use `#!/bin/bash` shebang
- Include error handling (`set -e`)
- Add colored output for better UX
- Include help/usage information
- Make scripts executable

#### **Documentation**
- Use clear, concise language
- Include practical examples
- Add appropriate emojis for visual appeal
- Follow the existing structure
- Include validation steps

#### **YAML/JSON Configurations**
- Use consistent indentation (2 spaces for YAML)
- Include comments where helpful
- Validate syntax before submitting

### Commit Message Format

Use conventional commit messages:

```
type(scope): description

body (optional)

footer (optional)
```

**Types:**
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes
- `refactor:` Code refactoring
- `test:` Test additions or changes
- `chore:` Maintenance tasks

**Examples:**
```
feat(monitoring): add Jaeger tracing support

Add distributed tracing with Jaeger to the monitoring stack.
Includes Terraform configuration and documentation.

Closes #42

fix(terraform): resolve Kind cluster creation issue

The cluster wasn't starting due to incorrect port mappings.
Updated the Kind configuration to fix the issue.

docs(readme): improve setup instructions

Added troubleshooting section and clearer step-by-step
instructions for new users.
```

## 🧪 Testing Your Contributions

### Required Testing

Before submitting a pull request:

1. **Full Workshop Test**
   ```bash
   ./scripts/cleanup.sh
   ./scripts/setup.sh
   ```

2. **Individual Task Testing**
   - Test each modified task independently
   - Verify all commands work as documented
   - Ensure outputs match expectations

3. **Documentation Testing**
   - Verify all links work
   - Test all code examples
   - Check formatting renders correctly

4. **Cross-Platform Testing** (if applicable)
   - Test on different operating systems
   - Verify scripts work in different shells

### Testing Checklist

- [ ] All existing functionality still works
- [ ] New features work as documented
- [ ] Scripts are executable and handle errors
- [ ] Documentation is accurate and clear
- [ ] No sensitive information is exposed
- [ ] Resource cleanup works properly

## 📋 Pull Request Process

### Before Submitting

1. **Rebase your branch** on the latest main
2. **Run the full test suite**
3. **Update documentation** if needed
4. **Add/update examples** as appropriate

### Pull Request Template

```markdown
## Description
Brief description of changes made.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Breaking change

## Testing
- [ ] Tested full workshop setup
- [ ] Tested individual components
- [ ] Updated documentation
- [ ] Added examples

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No breaking changes (or clearly documented)
```

### Review Process

1. **Automated checks** will run on your PR
2. **Maintainer review** for code quality and workshop alignment
3. **Testing verification** to ensure everything works
4. **Documentation review** for clarity and accuracy

## 🎓 Workshop-Specific Guidelines

### Learning Objectives

All contributions should support the workshop's learning objectives:
- Infrastructure as Code principles
- Kubernetes deployment and management
- Observability and monitoring
- Best practices and real-world scenarios

### Beginner-Friendly Approach

Remember this workshop is designed for learners:
- **Clear explanations** for complex concepts
- **Step-by-step instructions** with expected outputs
- **Troubleshooting guidance** for common issues
- **Progressive complexity** from basic to advanced

### Time Considerations

Keep the 4-hour workshop timeframe in mind:
- Tasks should be appropriately scoped
- Include realistic time estimates
- Provide shortcuts for complex setups
- Balance depth with practical time constraints

## 🐛 Reporting Issues

### Bug Reports

Include the following information:
- Operating system and version
- Tool versions (Docker, Terraform, kubectl, etc.)
- Step-by-step reproduction instructions
- Expected vs. actual behavior
- Error messages or logs
- Screenshots if helpful

### Feature Requests

- Clearly describe the proposed feature
- Explain the use case and benefits
- Consider impact on workshop timing
- Suggest implementation approach

## 📚 Resources

### Understanding the Workshop

- Review the main README.md
- Complete the workshop yourself
- Understand the learning flow
- Familiarize yourself with all tools used

### Technical Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs)
- [Prometheus Documentation](https://prometheus.io/docs)
- [Grafana Documentation](https://grafana.com/docs)

## 🏆 Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes for significant contributions
- Workshop presentations (with permission)

## 📞 Getting Help

- **Discussion**: Use GitHub Discussions for questions
- **Issues**: Create GitHub Issues for bugs or feature requests
- **Direct Contact**: Reach out to maintainers for complex topics

## 🎉 Thank You!

Your contributions help make this workshop better for everyone. Whether it's fixing a typo, adding a feature, or improving documentation, every contribution is valuable!

**Happy Contributing! 🚀**
