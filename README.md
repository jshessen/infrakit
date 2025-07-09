# IT Management Docker Stack

A comprehensive Docker-based IT management solution with identity management, monitoring, and security services.

## 🚀 Quick Start

### Option 1: Automated Installation
```bash
# Full stack (main server)
curl -sSL https://raw.githubusercontent.com/yourusername/it-management/main/install.sh | bash -s -- --type full

# Edge agent only (Raspberry Pi, etc.)
curl -sSL https://raw.githubusercontent.com/yourusername/it-management/main/install.sh | bash -s -- --type edge

# Monitoring only
curl -sSL https://raw.githubusercontent.com/yourusername/it-management/main/install.sh | bash -s -- --type monitor
```

### Option 2: Manual Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd it_management
   ```

2. **Set up environment files**
   ```bash
   ./setup_env.sh
   ```

3. **Configure secrets**
   ```bash
   # Follow the detailed guide
   cat SECRETS_SETUP.md
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
./setup_env.sh

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
./security_check.sh
```

## 🔄 Usage

### Make Commands
```bash
# Installation and setup
make install                  # Set up environment and guide through secrets
make setup                    # Initialize environment files only
make check                    # Run security and configuration checks

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
make update                   # Update all images and restart

# Cleanup
make clean                    # Remove containers, volumes, and networks
make rm                       # Remove containers only
```

### Utility Scripts
```bash
# Setup and configuration
./setup_env.sh               # Create .env files from examples
./security_check.sh          # Verify security configuration
./health_check.sh            # Check service health and status

# Backup and restore
./backup.sh                  # Create full backup
./restore.sh backup.tar.gz   # Restore from backup

# Installation options
./install.sh --type full     # Install full stack
./install.sh --type edge     # Install edge agent only
./install.sh --type monitor  # Install monitoring only
```

## 📂 Directory Structure

```
it_management/
├── .env.example              # Main configuration template
├── docker-compose.yml        # Main compose file
├── Makefile                  # Management commands
├── setup_env.sh             # Environment setup script
├── security_check.sh        # Security verification
├── SECRETS_SETUP.md         # Secrets configuration guide
├── SECURITY_SUMMARY.md      # Security overview
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
3. Test your changes with `./security_check.sh`
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

- Check the logs: `make logs <service>`
- Verify secrets: `cat SECRETS_SETUP.md`
- Run security check: `./security_check.sh`
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
