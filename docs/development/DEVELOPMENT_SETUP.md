# Development Setup

This guide helps you set up a local development environment for InfraKit.

## 🛠️ Prerequisites

- **Docker**: 20.10+ or Docker Desktop
- **Docker Compose**: V1 or V2 (auto-detected)
- **Git**: For version control
- **Code Editor**: VS Code recommended (workspace config included)

## 🚀 Getting Started

### 1. Clone and Setup
```bash
# Clone the repository
git clone https://github.com/jshessen/infrakit.git
cd infrakit

# Set up development environment
./scripts/setup_env.sh

# Copy development environment
cp .env.example .env
```

### 2. Development Configuration

Edit `.env` for development:
```bash
# Development-specific settings
COMPOSE_PROFILES=container_management,observability,debug
ENVIRONMENT=development

# Enable debug logging
LOG_LEVEL=debug
```

### 3. Start Development Stack
```bash
# Start core services for development
make up portainer glances dozzle

# Or start full stack
make up
```

## 🧪 Testing

### Security Testing
```bash
# Run security checks
./scripts/security_check.sh

# Production readiness check
./scripts/production_check.sh
```

### Pre-Commit Validation
```bash
# Comprehensive pre-commit checks
./scripts/pre_commit_check.sh
```

### Manual Testing
```bash
# Test all deployment types
make clean && make up                    # Full stack
cd deployments/edge-agent && make up     # Edge agent
COMPOSE_PROFILES=observability make up   # Monitoring only
```

## 📝 Development Workflow

### 1. Feature Development
```bash
# Create feature branch
git checkout -b feature/new-feature

# Make changes and test
# ... development work ...

# Run validation
./scripts/pre_commit_check.sh

# Commit changes
git add .
git commit -m "feat: add new feature"
```

### 2. Testing Changes
- Test all deployment scenarios
- Verify security checks pass
- Ensure documentation is updated
- Run comprehensive validation

### 3. Documentation Updates
- Update relevant guides in `docs/guides/`
- Update `CHANGELOG.md`
- Add release notes if needed

## 🛠️ Development Tools

### VS Code Workspace
InfraKit includes a VS Code workspace configuration:
```bash
# Open in VS Code
code infrakit.code-workspace
```

### Useful Make Targets
```bash
make help               # Show all available commands
make logs               # View all service logs
make status             # Show service status
make health             # Run health checks
make performance        # Monitor performance
```

### Scripts Overview
- `setup_env.sh` - Environment setup
- `security_check.sh` - Security validation
- `production_check.sh` - Production readiness
- `pre_commit_check.sh` - Comprehensive validation
- `update.sh` - Safe updates with backup

## 🔧 Troubleshooting

### Common Issues

1. **Port Conflicts**
   ```bash
   # Check what's using ports
   netstat -tulpn | grep :9000
   
   # Adjust ports in .env files
   ```

2. **Permission Issues**
   ```bash
   # Fix Docker permissions
   sudo usermod -aG docker $USER
   # Log out and back in
   ```

3. **Service Startup Issues**
   ```bash
   # Check logs
   make logs <service>
   
   # Restart service
   make restart <service>
   ```

## 📚 Additional Resources

- [Architecture Overview](ARCHITECTURE.md)
- [Contributing Guidelines](CONTRIBUTING.md)
- [Security Best Practices](../guides/SECRETS_SETUP.md)

---

**Questions?** Open an issue on [GitHub](https://github.com/jshessen/infrakit/issues)!
