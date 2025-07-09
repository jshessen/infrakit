---
name: Bug Report
about: Report a bug or issue
title: '[BUG] '
labels: bug
assignees: ''
---

## 🐛 Bug Description
A clear and concise description of what the bug is.

## 🔄 To Reproduce
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '...'
3. Scroll down to '...'
4. See error

## ✅ Expected Behavior
A clear and concise description of what you expected to happen.

## 🖥️ Environment
- **Deployment Type**: [full/edge/monitoring]
- **OS**: [e.g., Ubuntu 22.04, Raspberry Pi OS]
- **Docker Version**: [e.g., 24.0.7]
- **Docker Compose Version**: [e.g., 2.21.0]

## 📋 Configuration
- **Services involved**: [e.g., authentik, portainer]
- **Custom ports**: [yes/no, list if yes]
- **Profiles used**: [e.g., container_management,observability]

## 📊 Logs
```
# Paste relevant logs here
make logs <service_name>
```

## 🔍 Additional Context
Add any other context about the problem here.

## ✅ Checklist
- [ ] I've run `./scripts/security_check.sh` and it passes
- [ ] I've checked the logs with `make logs <service>`
- [ ] I've verified my `.env` configuration
- [ ] I've checked if secrets are properly configured
