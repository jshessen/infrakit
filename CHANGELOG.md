# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release of IT Management Docker Stack
- Full stack deployment with all services
- Edge agent deployment for lightweight devices
- Monitoring-only deployment option
- Automated installation scripts
- Comprehensive security checks
- Docker secrets management
- Multi-profile support

### Services Included
- Authentik - Identity Provider & SSO
- Portainer - Container Management
- Caddy - Reverse Proxy with automatic HTTPS
- Glances - System Monitoring
- Dozzle - Log Viewer
- Guacamole - Remote Desktop Gateway
- Watchtower - Automatic Updates
- Socket Proxy - Secure Docker Socket Access
- Cloudflare Tunnel - Secure External Access

### Documentation
- Comprehensive README with deployment options
- Security setup guide
- Deployment guide for different scenarios
- Contributing guidelines
- Issue templates

### Security
- All secrets externalized to Docker secrets
- Comprehensive .gitignore
- Security validation scripts
- No hardcoded credentials

## [1.0.0] - 2025-07-09

### Added
- Initial stable release
- Production-ready configurations
- Multi-deployment support
- Security hardening
- Automated setup scripts

---

## Release Notes Template

When creating a new release, use this template:

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- New features and services

### Changed
- Changes to existing functionality

### Deprecated
- Features that will be removed in future versions

### Removed
- Features that have been removed

### Fixed
- Bug fixes

### Security
- Security improvements and fixes
```
