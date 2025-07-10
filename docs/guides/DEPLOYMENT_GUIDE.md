# InfraKit Deployment Guide

<div align="center">

![InfraKit Icon](assets/logo/infrakit-logo-icon.svg)

</div>

This guide covers different deployment scenarios for the InfraKit infrastructure toolkit.

## 🏗️ Deployment Architecture

```
┌─────────────────────┐    ┌──────────────────┐    ┌──────────────────┐
│   Main Server       │    │   Edge Device    │    │  Monitoring Node │
│  (Full Stack)       │    │  (Lightweight)   │    │   (Monitor Only) │
├─────────────────────┤    ├──────────────────┤    ├──────────────────┤
│ • Authentik         │    │ • Portainer      │    │ • Glances        │
│ • Portainer Server  │◄──►│   Agent          │    │ • Watchtower     │
│ • Glances           │    │ • Watchtower     │    │                  │
│ • Dozzle            │    │                  │    │                  │
│ • Guacamole         │    │                  │    │                  │
│ • Caddy             │    │                  │    │                  │
│ • Socket Proxy      │    │                  │    │                  │
│ • Watchtower        │    │                  │    │                  │
└─────────────────────┘    └──────────────────┘    └──────────────────┘
```

## 🖥️ Full Stack Deployment

### Use Case
- Primary server with complete management capabilities
- Central authentication and monitoring
- Reverse proxy and security services

### Installation
```bash
# Automated
curl -sSL https://raw.githubusercontent.com/jshessen/infrakit/main/scripts/install.sh | bash -s -- --type full

# Manual
git clone https://github.com/jshessen/infrakit.git
cd infrakit
./scripts/setup_env.sh
# Configure secrets per docs/guides/SECRETS_SETUP.md
make up
```

### Services Included
- **Authentik**: Identity provider and SSO
- **Portainer**: Container management server
- **Glances**: System monitoring
- **Dozzle**: Log aggregation
- **Guacamole**: Remote desktop gateway
- **Caddy**: Reverse proxy with automatic HTTPS
- **Socket Proxy**: Secure Docker socket access
- **Watchtower**: Automatic updates

## 🔗 Edge Agent Deployment

### Use Case
- Raspberry Pi devices
- Remote servers
- IoT devices
- Branch office systems

### Installation
```bash
# Automated
curl -sSL https://raw.githubusercontent.com/jshessen/infrakit/main/scripts/install.sh | bash -s -- --type edge

# Manual
git clone https://github.com/jshessen/infrakit.git
cd infrakit/deployments/edge-agent
make setup
# Edit .env with main server details
make up
```

### Configuration
Edit `.env` file:
```bash
PORTAINER_SERVER_URL=https://your-main-server.domain.com:9443
PORTAINER_AGENT_SECRET=your_shared_secret
TZ=America/Chicago
```

### Services Included
- **Portainer Agent**: Connects to main Portainer server
- **Watchtower**: Automatic container updates

## 📊 Monitoring Only Deployment

### Use Case
- Dedicated monitoring nodes
- Lightweight monitoring for specific servers
- Remote system monitoring

### Installation
```bash
# Automated
curl -sSL https://raw.githubusercontent.com/jshessen/infrakit/main/scripts/install.sh | bash -s -- --type monitor

# Manual
git clone https://github.com/jshessen/infrakit.git
cd infrakit
cp .env.monitoring .env
./scripts/setup_env.sh
make up
```

### Services Included
- **Glances**: System monitoring with web interface
- **Watchtower**: Automatic container updates

## 🔄 Profile-Based Deployment

You can also use Docker Compose profiles for custom deployments:

### Available Profiles
- `container_management`: Portainer server
- `container_management_agent`: Portainer agent
- `observability`: Glances, Dozzle
- `identity`: Authentik
- `remote_access`: Guacamole, Cloudflare Tunnel
- `security`: Caddy, Socket Proxy
- `auto_update`: Watchtower

### Custom Profile Examples
```bash
# Edge device with monitoring
COMPOSE_PROFILES=container_management_agent,observability,auto_update

# Security-focused deployment
COMPOSE_PROFILES=container_management,security,auto_update

# Monitoring and remote access
COMPOSE_PROFILES=observability,remote_access,auto_update
```

## 🌐 Multi-Node Setup

### Scenario: Main Server + Edge Devices

1. **Main Server Setup**
   ```bash
   # Install full stack
   curl -sSL https://raw.githubusercontent.com/jshessen/infrakit/main/scripts/install.sh | bash -s -- --type full
   
   # Configure and start
   cd infrakit
   # Edit .env files and create secrets
   make up
   ```

2. **Edge Device Setup**
   ```bash
   # Install edge agent
   curl -sSL https://raw.githubusercontent.com/jshessen/infrakit/main/scripts/install.sh | bash -s -- --type edge
   
   # Configure connection to main server
   cd infrakit
   # Edit .env with main server details
   make up
   ```

3. **Portainer Configuration**
   - Access main Portainer at `https://your-server:9443`
   - Add edge device as endpoint
   - Use agent URL: `edge-device-ip:9001`

## 🔧 Configuration Tips

### Environment Variables
Create environment-specific `.env` files:
- `.env.production` - Production settings
- `.env.staging` - Staging environment
- `.env.development` - Development setup

### Port Management
Avoid port conflicts across deployments:
- Main server: Default ports (9000, 8080, etc.)
- Edge devices: Offset ports (+1000, +2000, etc.)
- Monitoring nodes: Dedicated port ranges

### Security Considerations
- Use different secrets for each environment
- Implement network segmentation
- Use TLS for inter-node communication
- Regular security updates via Watchtower

## 🚀 Scaling Strategies

### Horizontal Scaling
- Deploy multiple edge agents
- Use load balancers for web services
- Implement service discovery

### Vertical Scaling
- Increase resource limits in compose files
- Use Docker Swarm for orchestration
- Implement auto-scaling policies

## 📋 Maintenance

### Updates
```bash
# Update all services
make update

# Update specific service
make update portainer

# Check for updates
docker-compose pull
```

### Monitoring
- Use Portainer for container management
- Monitor logs via Dozzle
- System metrics via Glances

### Backups
- Backup Docker volumes
- Export Portainer configuration
- Document custom configurations

## 🆘 Troubleshooting

### Common Issues
1. **Port conflicts**: Adjust ports in `.env` files
2. **Network connectivity**: Check firewall rules
3. **Agent connection**: Verify shared secrets
4. **Resource limits**: Monitor system resources

### Debug Commands
```bash
# Check service status
make logs

# Test connectivity
docker-compose exec portainer-agent ping main-server

# Resource usage
docker stats

# Network inspection
docker network ls
docker network inspect <network-name>
```
