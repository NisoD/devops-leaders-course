# Contributing to DevOps Bootcamp - IaC and Monitoring

Thank you for your interest in contributing to this workshop! This guide will help you understand how to contribute effectively.

## 🎯 How to Contribute

### Types of Contributions

We welcome the following types of contributions:

1. **Bug Fixes** - Fix issues in code, configurations, or documentation
2. **Documentation Improvements** - Enhance explanations, add examples, fix typos
3. **New Features** - Add new tasks, tools, or learning modules
4. **Workshop Enhancements** - Improve the learning experience
5. **Platform Support** - Add support for different operating systems or environments

### Getting Started

1. **Fork the repository**
2. **Clone your fork locally**
3. **Create a new branch** for your contribution
4. **Make your changes**
5. **Test thoroughly**
6. **Submit a pull request**

## 🛠️ Development Setup

### Prerequisites

- All workshop prerequisites (see PREREQUISITES.md)
- Basic understanding of the workshop content
- Testing environment for validation

### Local Development

```bash
# Clone your fork
git clone https://github.com/YOUR-USERNAME/devops-bootcamp-iac-monitoring.git
cd devops-bootcamp-iac-monitoring

# Create a new branch
git checkout -b feature/your-contribution-name

# Test the current setup
./scripts/setup.sh

# Make your changes
# ...

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
