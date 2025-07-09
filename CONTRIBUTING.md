# Contributing to InfraKit

Thank you for your interest in contributing to InfraKit! This document provides guidelines for contributing to this project.

## 🤝 How to Contribute

### 🐛 Reporting Bugs
- Use the bug report template
- Include detailed reproduction steps
- Provide environment information
- Include relevant logs

### 💡 Suggesting Features
- Use the feature request template
- Explain the use case clearly
- Consider security implications
- Think about all deployment types

### 🔧 Code Contributions

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Make your changes**
4. **Test thoroughly**
5. **Run security checks**
   ```bash
   ./scripts/security_check.sh
   ```
6. **Submit a pull request**

## 📋 Development Guidelines

### 🔒 Security First
- Never commit secrets or sensitive data
- Use Docker secrets pattern: `file:///run/secrets/`
- Update `.gitignore` for new sensitive files
- Run security checks before committing

### 🐳 Docker Best Practices
- Use specific image tags, not `latest` in production
- Implement proper health checks
- Use multi-stage builds when appropriate
- Follow least privilege principle

### 📝 Documentation
- Update README.md for new features
- Create/update `.env.example` files
- Document new secrets in SECRETS_SETUP.md
- Include deployment considerations

### 🧪 Testing
- Test all deployment types (full, edge, monitoring)
- Verify `make` commands work correctly
- Test environment setup scripts
- Validate Docker Compose files

## 🏗️ Project Structure

```
it_management/
├── .github/                 # GitHub workflows and templates
├── deployments/             # Deployment-specific configurations
├── services/                # Individual service configurations
├── scripts/                 # Utility scripts
├── docs/                    # Additional documentation
└── tests/                   # Test scripts and configurations
```

## 🔄 Pull Request Process

1. **Update documentation** for any new features
2. **Add tests** for new functionality
3. **Update CHANGELOG.md** with your changes
4. **Ensure security check passes**
5. **Request review** from maintainers

### PR Requirements
- [ ] Security check passes
- [ ] All deployment types tested
- [ ] Documentation updated
- [ ] No secrets in commits
- [ ] Follows coding standards

## 📊 Code Review Criteria

- **Security**: No exposed secrets or vulnerabilities
- **Functionality**: Works across all deployment types
- **Documentation**: Clear and comprehensive
- **Maintainability**: Clean, readable code
- **Backwards compatibility**: Doesn't break existing setups

## 🎯 Development Environment

### Setup
```bash
git clone <your-fork>
cd infrakit
./scripts/setup_env.sh
```

### Testing
```bash
# Security check
./scripts/security_check.sh

# Test full deployment
make up

# Test edge deployment
cd deployments/edge-agent
make up

# Test monitoring deployment
COMPOSE_PROFILES=observability,auto_update make up
```

## 🏷️ Versioning

We use [Semantic Versioning](https://semver.org/):
- **MAJOR**: Breaking changes
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes, backward compatible

## 📄 License

By contributing, you agree that your contributions will be licensed under the same license as the project.

## 🆘 Getting Help

- Check existing issues and discussions
- Join our community Discord (if available)
- Tag maintainers in issues for guidance

## 🎉 Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Community hall of fame

Thank you for helping make this project better! 🚀
