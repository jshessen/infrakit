# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Preparing for next release...

## [1.1.0] - 2025-07-10

### Added
- **🎨 Complete branding integration**: Web-optimized SVG logos and PNG fallbacks
  - `infrakit-logo-full.svg` - Full logo with wordmark (web-optimized)
  - `infrakit-logo-icon.svg` - Clean icon for avatars and compact spaces (web-optimized)
  - `infrakit-wordmark.svg` - Wordmark only for text-based branding (web-optimized)
  - `*-optimized.png` - PNG fallbacks for legacy browser support
  - `infrakit-logo.svg` - Legacy compatibility SVG
  - `infrakit-social.svg` - Social media optimized SVG
  - `favicon/favicon.svg` - Modern browser favicon support
- **📚 Comprehensive branding guide**: `BRANDING_GUIDE.md` with SVG-first approach
- **🎯 Enhanced documentation**: Updated README with modern SVG logo integration
- **🖼️ Visual identity**: Consistent branding across all documentation
- **📝 Asset documentation**: Complete guide in `assets/README.md`
- **🎨 Makefile branding**: Enhanced help output with InfraKit styling
- **📋 Template updates**: GitHub issue templates with branding
- **🧹 Asset cleanup**: Removed redundant files, streamlined structure
- **🎯 Favicon updates**: Recreated all favicon files using new logo design
  - Updated `favicon.ico` (15KB, down from 27KB)
  - Updated `favicon-16x16.png`, `favicon-32x32.png`, `favicon-48x48.png`
  - All favicons now use the new clean icon design
- **🔄 Safe update system**: Added comprehensive update script with backup and rollback
  - `scripts/update.sh` - Safe updates with automatic backup creation
  - `make update-safe` - Run safe update with backup and rollback capabilities
  - `make update-check` - Check for available updates without applying
  - Rollback functionality if updates fail
  - Health checks after updates
- **🚀 Production deployment features**: Enhanced production readiness
  - `scripts/production_check.sh` - Comprehensive production validation
  - `scripts/pre_commit_check.sh` - Pre-commit validation system
  - `scripts/deploy.sh` - Interactive deployment with environment support
  - Multi-environment configuration support (dev/staging/production)
- **🔧 Enhanced automation**: Improved management and deployment
  - Automated installation scripts for different deployment types
  - Docker Compose compatibility detection and handling
  - Profile-based service management
  - Comprehensive Makefile with production targets

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
