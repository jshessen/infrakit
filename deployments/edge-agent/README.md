# Edge Agent Deployment

Lightweight deployment for edge devices that connects back to the main IT management stack.

## Services Included
- **Portainer Agent** - Connects to main Portainer server
- **Watchtower** - Automatic container updates

## Quick Setup

1. **Configure connection to main server:**
   ```bash
   cp .env.example .env
   # Edit .env with your main server details
   ```

2. **Start services:**
   ```bash
   make up
   ```

## Configuration

Set these variables in `.env`:
- `PORTAINER_SERVER_URL` - URL of your main Portainer server
- `PORTAINER_AGENT_SECRET` - Shared secret for agent authentication
- `TZ` - Your timezone

## Usage

After setup, this device will appear in your main Portainer dashboard as a managed endpoint.

## Updating

Watchtower will automatically update containers. To manually update:
```bash
make update
```
