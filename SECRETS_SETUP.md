# Secrets Setup Guide

This document explains how to set up the required secrets for the IT Management stack.

## Required Secrets

### Authentik Secrets

Create the following files in `authentik/secrets/`:

1. **authentik_db_password** - Database password for PostgreSQL
   ```bash
   echo "your_secure_database_password" > authentik/secrets/authentik_db_password
   ```

2. **authentik_secret_key** - Authentik secret key (generate randomly)
   ```bash
   openssl rand -base64 32 > authentik/secrets/authentik_secret_key
   ```

3. **email_user** - SMTP username for email sending
   ```bash
   echo "your_email@domain.com" > authentik/secrets/email_user
   ```

4. **email_password** - SMTP password for email sending
   ```bash
   echo "your_email_password" > authentik/secrets/email_password
   ```

5. **email_from** - From email address
   ```bash
   echo "noreply@yourdomain.com" > authentik/secrets/email_from
   ```

6. **geoip_account** - MaxMind GeoIP account ID
   ```bash
   echo "your_geoip_account_id" > authentik/secrets/geoip_account
   ```

7. **geoip_license** - MaxMind GeoIP license key
   ```bash
   echo "your_geoip_license_key" > authentik/secrets/geoip_license
   ```

### Other Service Secrets

#### Cloudflare Tunnel
Create `cloudflared/secrets/tunnel_token`:
```bash
echo "your_cloudflare_tunnel_token" > cloudflared/secrets/tunnel_token
```

#### Caddy JWT
Create `caddy/secrets/caddy_jwt_token_key`:
```bash
openssl rand -base64 32 > caddy/secrets/caddy_jwt_token_key
```

#### Guacamole
Create the following in `guacamole/secrets/`:
```bash
echo "your_guacamole_db_password" > guacamole/secrets/guacamole_db_password
echo "your_ldap_password" > guacamole/secrets/guacamole_ldap_password
```

## Security Notes

- All secrets files are automatically ignored by git
- Use strong, randomly generated passwords
- Store secrets securely and never commit them to version control
- Consider using a password manager for generating and storing secrets

## Verification

Run the security check script to verify your setup:
```bash
./scripts/security_check.sh
```

This will check for any accidentally exposed secrets or insecure configurations.

## Security Check Results

When you run `./scripts/security_check.sh`, you may see some warnings that are actually **safe and expected**:

### ✅ **Safe/Expected Items:**
- **PostgreSQL config defaults** - Lines like `#krb_server_keyfile = 'FILE:${sysconfdir}/krb5.keytab'` are commented defaults
- **Certificate files in data/ directories** - These are runtime-generated and already ignored by git
- **Backup directories in data/ folders** - These are runtime data, not source code
- **Docker secrets references** - Lines like `file:///run/secrets/secret_name` are secure patterns

### ⚠️ **Items to Address:**
- **Hardcoded passwords/secrets** in configuration files
- **Certificates in source directories** (not data/ directories)
- **Backup files tracked in git**
- **Actual secrets in .env files** (not references to secrets)

### 🔍 **Understanding the Output:**
The improved security check filters out false positives and focuses on real security issues. A clean result means your setup is secure for GitHub upload.
