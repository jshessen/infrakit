# InfraKit Architecture Overview

This document provides a high-level overview of InfraKit's architecture, components, and design principles.

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        InfraKit Platform                        │
├─────────────────────────────────────────────────────────────────┤
│                         Edge Devices                           │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │   Raspberry Pi  │  │   IoT Device    │  │  Remote Server  │  │
│  │                 │  │                 │  │                 │  │
│  │ • Portainer     │  │ • Portainer     │  │ • Portainer     │  │
│  │   Agent         │  │   Agent         │  │   Agent         │  │
│  │ • Watchtower    │  │ • Watchtower    │  │ • Watchtower    │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
│           ▲                      ▲                      ▲       │
│           │                      │                      │       │
│           └──────────────────────┼──────────────────────┘       │
│                                  │                              │
├─────────────────────────────────────────────────────────────────┤
│                      Main Server (Full Stack)                   │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                    Identity & Security                      │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │ │
│  │  │   Authentik  │  │    Caddy     │  │ Socket Proxy │     │ │
│  │  │   (SSO/IdP)  │  │ (Rev. Proxy) │  │  (Security)  │     │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘     │ │
│  └─────────────────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                Container Management                         │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │ │
│  │  │  Portainer   │  │  Watchtower  │  │    Docker    │     │ │
│  │  │  (Web UI)    │  │ (Auto-Update)│  │   (Engine)   │     │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘     │ │
│  └─────────────────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │             Monitoring & Observability                     │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │ │
│  │  │   Glances    │  │    Dozzle    │  │  Performance │     │ │
│  │  │  (Metrics)   │  │   (Logs)     │  │  (Monitoring)│     │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘     │ │
│  └─────────────────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                   Remote Access                             │ │
│  │  ┌──────────────┐  ┌──────────────┐                       │ │
│  │  │  Guacamole   │  │  Cloudflare  │                       │ │
│  │  │ (RDP/VNC/SSH)│  │   Tunnel     │                       │ │
│  │  └──────────────┘  └──────────────┘                       │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## 🧩 Core Components

### Identity & Security Layer
- **Authentik**: OpenID Connect and SAML identity provider
- **Caddy**: Reverse proxy with automatic HTTPS
- **Socket Proxy**: Secure Docker socket access

### Container Management Layer
- **Portainer**: Web-based Docker management interface
- **Watchtower**: Automatic container updates
- **Docker**: Container runtime and orchestration

### Monitoring & Observability Layer
- **Glances**: System resource monitoring
- **Dozzle**: Real-time log aggregation and viewing
- **Performance Scripts**: Custom monitoring and health checks

### Remote Access Layer
- **Guacamole**: Clientless remote desktop gateway
- **Cloudflare Tunnel**: Secure external access without port forwarding

## 🎯 Design Principles

### 1. **Security First**
- All secrets externalized to Docker secrets
- No hardcoded credentials
- Secure by default configurations
- Regular security validation

### 2. **Modular Architecture**
- Profile-based service selection
- Independent service configurations
- Flexible deployment scenarios

### 3. **Production Ready**
- Comprehensive health checks
- Automated backup and recovery
- Safe update mechanisms
- Production validation scripts

### 4. **Edge-First Design**
- Lightweight edge deployments
- Centralized management
- Scalable architecture

## 🔄 Data Flow

### 1. **User Access**
```
User → Caddy (Reverse Proxy) → Authentik (Auth) → Service
```

### 2. **Container Management**
```
Portainer → Socket Proxy → Docker Engine → Containers
```

### 3. **Monitoring**
```
Services → Glances/Dozzle → Dashboards → Alerts
```

### 4. **Edge Communication**
```
Edge Agent → Main Portainer → Management Commands → Edge Containers
```

## 📁 Directory Structure

```
infrakit/
├── docs/                    # Documentation
│   ├── guides/             # User guides
│   ├── development/        # Development docs
│   └── releases/           # Release documentation
├── scripts/                # Automation scripts
├── assets/                 # Branding and static assets
├── deployments/            # Deployment configurations
│   └── edge-agent/        # Edge-specific deployment
├── services/               # Service configurations
│   ├── authentik/         # Identity provider
│   ├── caddy/             # Reverse proxy
│   ├── portainer/         # Container management
│   ├── glances/           # System monitoring
│   ├── dozzle/            # Log viewer
│   ├── guacamole/         # Remote access
│   ├── watchtower/        # Auto-updates
│   └── socket-proxy/      # Security proxy
└── secrets/                # Sensitive configuration
```

## 🔧 Configuration Management

### Environment Files
- `.env.example` - Template configuration
- `.env.production` - Production settings
- `.env.edge` - Edge device configuration
- `.env.monitoring` - Monitoring-only setup

### Docker Compose Profiles
- `container_management` - Portainer server
- `container_management_agent` - Portainer agent
- `observability` - Monitoring stack
- `identity` - Authentication services
- `remote_access` - Remote access tools
- `security` - Security services
- `auto_update` - Automatic updates

### Secrets Management
- Docker secrets for sensitive data
- File-based secret mounting
- Environment-specific configurations

## 🌐 Network Architecture

### Internal Networks
- `infrakit_default` - Main service network
- `proxy_network` - Reverse proxy network
- `monitoring_network` - Monitoring services

### External Connectivity
- Caddy handles all external traffic
- Cloudflare Tunnel for secure remote access
- No direct container exposure

## 🔐 Security Model

### Authentication Flow
1. User accesses service via Caddy
2. Caddy forwards to Authentik for authentication
3. Authentik validates credentials and returns token
4. Token used for subsequent service access

### Authorization
- Role-based access control via Authentik
- Service-level permissions
- Docker socket access via secure proxy

### Data Protection
- Secrets stored in Docker secrets
- TLS encryption for all communications
- Regular security validation

## 📈 Scalability

### Horizontal Scaling
- Multiple edge agents
- Load balancing via Caddy
- Distributed monitoring

### Vertical Scaling
- Resource limits in compose files
- Performance monitoring
- Capacity planning

## 🚀 Deployment Patterns

### Full Stack
Complete infrastructure management for main servers

### Edge Agent
Lightweight deployment for edge devices and IoT

### Monitoring Only
Dedicated monitoring nodes for specific environments

### Hybrid
Combination of patterns for complex infrastructures

---

This architecture provides a solid foundation for self-hosted infrastructure management with enterprise-grade security, monitoring, and scalability.
