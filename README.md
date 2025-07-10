# InfraKit

<div align="center">

![InfraKit Logo](assets/logo/infrakit-logo-full.svg)

![InfraKit](https://img.shields.io/badge/InfraKit-Infrastructure%20Toolkit-blue?style=for-the-badge&logo=docker&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Ready-blue?style=for-the-badge&logo=docker)
![Security](https://img.shields.io/badge/Security-Hardened-green?style=for-the-badge&logo=shield)
![Monitoring](https://img.shields.io/badge/Monitoring-Enabled-orange?style=for-the-badge&logo=grafana)

```ascii
  ╔══════════════════════════════════════╗
  ║   🏗️  📦  🔐  📊  ⚙️   InfraKit    ║
  ║                                      ║
  ║     Self-Hosted Infrastructure       ║
  ║           Toolkit                    ║
  ╚══════════════════════════════════════╝
```

**Docker • Security • Monitoring • Automation**

</div>

---

A comprehensive, secure, and production-ready self-hosted infrastructure toolkit built on Docker. Features identity management, container orchestration, monitoring, remote access, and automated security - everything you need to manage your infrastructure from a single, powerful platform.

## 🛠️ Requirements

- **Docker**: 20.10+ or Docker Desktop
- **Docker Compose**: V1 (docker-compose) or V2 (docker compose) 
- **Operating System**: Linux, macOS, or Windows with WSL2

> **Note**: This project automatically detects and uses the correct Docker Compose command (`docker-compose` or `docker compose`)

## 🚀 Quick Start

### Prerequisites Check
```bash
# Check Docker Compose compatibility
./scripts/check-docker-compose.sh
```

### Option 1: Automated Installation
```bash
# Full stack (main server)
curl -sSL https://raw.githubusercontent.com/jshessen/infrakit/main/scripts/install.sh | bash -s -- --type full

# Edge agent only (Raspberry Pi, etc.)
curl -sSL https://raw.githubusercontent.com/jshessen/infrakit/main/scripts/install.sh | bash -s -- --type edge

# Monitoring only
curl -sSL https://raw.githubusercontent.com/jshessen/infrakit/main/scripts/install.sh | bash -s -- --type monitor
```

### Option 2: Manual Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/jshessen/infrakit.git
   cd infrakit
   ```

2. **Set up environment files**
   ```bash
   ./scripts/setup_env.sh
   ```

3. **Configure secrets**
   ```bash
   # Follow the detailed guide
   cat docs/guides/SECRETS_SETUP.md
   ```

4. **Start the services**
   ```bash
   make up
   ```

## 📦 Deployment Options

### 🖥️ Full Stack (Main Server)
Complete IT management solution with all services:
- Identity management (Authentik)
- Container management (Portainer)
- Monitoring (Glances, Dozzle)
- Remote access (Guacamole)
- Security (Caddy, Socket Proxy)

### 🔗 Edge Agent (Lightweight)
Minimal deployment for edge devices:
- Portainer Agent (connects to main server)
- Watchtower (auto-updates)

Perfect for Raspberry Pi, IoT devices, or remote servers.

### 📊 Monitoring Only
Monitoring-focused deployment:
- Glances (system monitoring)
- Watchtower (auto-updates)

Great for dedicated monitoring nodes.

## 📋 Services Included

### 🔐 Identity & Security
- **Authentik** - Identity Provider & SSO
- **Caddy** - Reverse Proxy with automatic HTTPS
- **Socket Proxy** - Secure Docker socket access

### 📊 Monitoring & Management
- **Portainer** - Container management interface
- **Glances** - System monitoring
- **Dozzle** - Log viewer
- **Watchtower** - Automatic container updates

### 🌐 Remote Access
- **Guacamole** - Remote desktop gateway
- **Cloudflare Tunnel** - Secure external access

## 🔧 Configuration

### Environment Files
Each service has its own `.env.example` file that you can copy to `.env`:

```bash
# Automated setup
./scripts/setup_env.sh

# Manual setup
cp .env.example .env
cp authentik/.env.example authentik/.env
cp caddy/.env.example caddy/.env
# ... etc
```

### Port Configuration
Default ports can be customized in each service's `.env` file:

- **Authentik**: 9000 (HTTP), 9443 (HTTPS)
- **Portainer**: 9000
- **Caddy**: 8080 (HTTP), 8443 (HTTPS)
- **Dozzle**: 8080
- **Glances**: 61208
- **Guacamole**: 8080

### Service Profiles
Services are organized into profiles that can be enabled/disabled:

```bash
# In main .env file
COMPOSE_PROFILES=container_management,observability,identity,remote_access,security
```

## 🛡️ Security

### Secrets Management
All sensitive data is stored in `secrets/` directories using Docker secrets:

```bash
# Generate database passwords
openssl rand -base64 32 > authentik/secrets/authentik_db_password

# Generate API keys
openssl rand -base64 32 > caddy/secrets/caddy_jwt_token_key
```

### Security Check
Run the security check to verify your setup:

```bash
./scripts/security_check.sh
```

## 🔄 Usage

### Make Commands
```bash
# Installation and setup
make install                  # Set up environment and guide through secrets
make setup                    # Initialize environment files only
make check                    # Run security and configuration checks
make docker-check             # Check Docker Compose compatibility

# Service management
make up                       # Start all services
make up portainer dozzle      # Start specific services
make down                     # Stop all services
make restart                  # Restart all services
make stop                     # Stop without removing containers

# Monitoring and maintenance
make logs                     # Show all logs
make logs portainer           # Show specific service logs
make status                   # Show service status
make health                   # Run health checks
make performance              # Monitor system and container performance
make production-check         # Validate production readiness

# Updates
make update                   # Quick update (pull images and restart)
make update-safe              # Safe update with backup and rollback capabilities
make update-check             # Check for available updates without applying

# Cleanup
make clean                    # Remove containers, volumes, and networks
make rm                       # Remove containers only
```

### Utility Scripts
```bash
# Setup and configuration
./scripts/setup_env.sh       # Create .env files from examples
./scripts/setup_gpg.sh       # Configure GPG for commit signing
./scripts/security_check.sh  # Verify security configuration
./scripts/health_check.sh    # Check service health and status

# Updates and maintenance
./scripts/update.sh          # Safe update with backup and rollback
./scripts/update.sh --check-only     # Check for updates
./scripts/update.sh --rollback       # Rollback to previous version
./scripts/update.sh --list-backups   # List available backups

# Backup and restore
./scripts/backup.sh          # Create full backup
./scripts/restore.sh backup.tar.gz   # Restore from backup

# Installation options
./scripts/install.sh --type full     # Install full stack
./scripts/install.sh --type edge     # Install edge agent only
./scripts/install.sh --type monitor  # Install monitoring only
```

## 📂 Directory Structure

```
infrakit/
├── .env.example              # Main configuration template
├── docker-compose.yml        # Main compose file
├── Makefile                  # Management commands
├── docs/                     # Documentation
│   ├── guides/              # User guides (deployment, security, branding)
│   ├── development/         # Development documentation
│   ├── releases/            # Release notes and history
│   └── templates/           # Templates for future releases
├── scripts/                  # Utility scripts
│   ├── setup_env.sh         # Environment setup script
│   ├── security_check.sh    # Security verification
│   ├── health_check.sh      # Health monitoring
│   ├── backup.sh            # Backup functionality
│   └── install.sh           # Installation automation
├── deployments/             # Deployment configurations
│   └── edge-agent/         # Edge device deployment
├── assets/                  # Branding and static assets
└── services/
    ├── authentik/
    │   ├── .env.example
    │   ├── docker-compose.yml
    │   └── secrets/
    ├── caddy/
    │   ├── .env.example
    │   ├── docker-compose.yml
    │   └── secrets/
    └── ... (other services)
```

## 🔍 Troubleshooting

### Common Issues

1. **Port conflicts**: Adjust ports in service `.env` files
2. **Permission issues**: Check Docker daemon permissions
3. **Secret errors**: Verify all required secrets are created
4. **Network issues**: Ensure Docker networks are available

### Logs and Debugging
```bash
# View service logs
make logs <service_name>

# Check container status
docker-compose ps

# Restart problematic services
make restart <service_name>
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Set up GPG signing (optional but recommended): `./scripts/setup_gpg.sh`
4. Test your changes with `./scripts/security_check.sh`
5. Submit a pull request

See our [Contributing Guide](docs/development/CONTRIBUTING.md) for detailed guidelines.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🎨 Branding Assets

InfraKit includes various branding assets organized by purpose and optimized for different use cases:

| Asset | Purpose | File | Size |
|-------|---------|------|------|
| ![InfraKit Logo](assets/logo/infrakit-logo-icon.svg) | **Main Logo** | `assets/logo/infrakit-logo-icon.svg` | Web-optimized |
| ![InfraKit Wordmark](assets/logo/infrakit-wordmark.svg) | **Wordmark Only** | `assets/logo/infrakit-wordmark.svg` | Web-optimized |
| **Full Logo** | **Complete Wordmark** | `assets/logo/infrakit-logo-full.svg` | Web-optimized |
| **Optimized Icons** | **Size Variants** | `assets/optimized/icon-*.png` | 7-61KB |
| **Favicon** | **Browser Icon** | `assets/favicon/favicon.ico` | 27KB |
| **Social Media** | **Open Graph/Twitter** | `assets/social/og-image.png` | 284KB |

### Usage Guidelines
- Use `infrakit-logo-full.svg` for headers and main documentation (SVG recommended)
- Use `infrakit-logo-icon.svg` for avatars and compact spaces (SVG recommended)
- Use `infrakit-wordmark.svg` for text-based branding and footers
- Use PNG fallbacks (`assets/logo/*-optimized.png`) for legacy browser support
- Use optimized variants (`assets/optimized/`) for specific size requirements
- All assets are optimized for both light and dark backgrounds

## 🆘 Support

- Check the logs: `make logs <service>`
- Verify secrets: `cat docs/guides/SECRETS_SETUP.md`
- Run security check: `./scripts/security_check.sh`
- Review configuration: Check `.env` files

## 🔗 Service URLs

After starting, services are available at:

- **Authentik**: http://localhost:9000
- **Portainer**: http://localhost:9000
- **Caddy**: http://localhost:8080
- **Dozzle**: http://localhost:8080
- **Glances**: http://localhost:61208
- **Guacamole**: http://localhost:8080

*Note: Actual URLs depend on your port configuration in `.env` files*

## 📋 Releases

- **Latest Release**: [v1.1.0](docs/releases/RELEASE_NOTES_v1.1.0.md) - Production-Ready Infrastructure Toolkit
- **All Releases**: See [docs/releases/](docs/releases/) for complete release history and documentation
