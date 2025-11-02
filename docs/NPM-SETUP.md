# Nginx Proxy Manager (NPM) Quick Setup Guide

This guide is for deploying the starter-app behind Nginx Proxy Manager on the same Docker host.

## Prerequisites

- Nginx Proxy Manager is already installed and running
- Docker and Docker Compose installed
- PowerShell 7.2+ installed
- Domain name pointed to your server

## Architecture Overview

```
Internet (80/443)
    ↓
[Nginx Proxy Manager Container]
    ├─ Own network (with internet access)
    └─ Connected to app network via: docker network connect
           ↓
    [App Network: myapp] ← Isolated, no internet access
        ├─ myapp (SvelteKit app) ← Port 3000 internal only
        ├─ db (PostgreSQL) ← Port 5432 internal only
        └─ redis (Redis) ← Port 6379 internal only
```

**Key Points:**
- App network is isolated from the internet
- NPM attaches to app network to reach the app
- No ports are exposed to the host (no `localhost:5175`)
- Database and Redis are internal only

## Quick Setup (5 minutes)

### 1. Bootstrap the Application

```bash
# Clone repository
git clone <your-repo-url> /opt/starter-app
cd /opt/starter-app

# Run production bootstrap
pwsh setup/bootstrap.ps1 -Environment prod -AppName "myapp"

# Update ORIGIN in .env.prod
nano .env.prod
# Change: ORIGIN=https://your-domain.com
```

### 2. Start the Application

```bash
# Start all services (creates the 'myapp' network)
docker compose -f docker-compose.prod.yml up -d

# Verify services are running
docker compose -f docker-compose.prod.yml ps
```

### 3. Connect NPM to App Network

```bash
# Find your NPM container name
docker ps | grep nginx

# Connect NPM to your app's network
docker network connect myapp <npm-container-name>

# Example:
# docker network connect myapp nginx-proxy-manager

# Verify the connection
docker network inspect myapp
# You should see your NPM container listed under "Containers"
```

### 4. Configure Proxy in NPM Web UI

1. **Open NPM**: Navigate to `http://your-server-ip:81`
   - Default login: `admin@example.com` / `changeme`

2. **Add Proxy Host**: Go to **Hosts** → **Proxy Hosts** → **Add Proxy Host**

3. **Details Tab**:
   - **Domain Names**: `your-domain.com` (press Enter to add)
   - **Scheme**: `http`
   - **Forward Hostname/IP**: `myapp` ← Your container name
   - **Forward Port**: `3000` ← Production internal port
   - **Cache Assets**: ✅ Enabled
   - **Block Common Exploits**: ✅ Enabled
   - **Websockets Support**: ✅ Enabled

4. **SSL Tab**:
   - **SSL Certificate**: Select "Request a new SSL Certificate"
   - **Force SSL**: ✅ Enabled
   - **HTTP/2 Support**: ✅ Enabled
   - **HSTS Enabled**: ✅ Enabled (optional but recommended)
   - **Email Address**: `your-email@example.com`
   - **I Agree to the Let's Encrypt Terms of Service**: ✅

5. **Click Save**

NPM will automatically:
- Request SSL certificate from Let's Encrypt
- Configure automatic HTTPS redirect
- Enable HTTP/2

### 5. Verify Deployment

```bash
# Test health endpoint
curl https://your-domain.com/health

# Expected output:
# {"status":"ok"}

# Check certificate
echo | openssl s_client -servername your-domain.com -connect your-domain.com:443 2>/dev/null | openssl x509 -noout -dates

# View app logs
docker compose -f docker-compose.prod.yml logs -f app
```

## Configuration Details

### Container Names

The bootstrap creates these containers:
- **App**: `myapp` (your app name)
- **Database**: `myapp.db.prod`
- **Redis**: `myapp.redis.prod`

NPM connects to: `http://myapp:3000`

### Network Name

Network is named after your app: `myapp`

### Internal Ports

- **Development**: 5173 (Vite dev server)
- **Production**: 3000 (Node.js build)

Always use port **3000** in NPM for production deployments.

### No Host Port Exposure

In production, the app does **NOT** expose ports to the host:
- ❌ `localhost:5175` will NOT work
- ❌ `localhost:3000` will NOT work
- ✅ Only accessible via NPM through Docker network

This is intentional for security and isolation.

## Troubleshooting

### Issue: "502 Bad Gateway" in NPM

**Cause**: NPM cannot reach the app container.

**Solution**:
```bash
# 1. Verify app is running
docker compose -f docker-compose.prod.yml ps

# 2. Check NPM is connected to app network
docker network inspect myapp | grep -i nginx

# 3. If not connected, connect it
docker network connect myapp <npm-container-name>

# 4. Restart NPM to refresh connections
docker restart <npm-container-name>

# 5. Check NPM can resolve container name
docker exec <npm-container-name> ping -c 2 myapp
```

### Issue: Container name not found

**Cause**: Wrong container name in NPM configuration.

**Solution**:
```bash
# Get exact container name
docker ps --format '{{.Names}}' | grep myapp

# Use that exact name in NPM (usually just 'myapp')
```

### Issue: "Connection refused" on port 3000

**Cause**: Using wrong internal port or app not ready.

**Solution**:
```bash
# Verify app is listening on port 3000
docker compose -f docker-compose.prod.yml exec app netstat -tln | grep 3000

# Check app logs for errors
docker compose -f docker-compose.prod.yml logs app

# Verify PORT environment variable
docker compose -f docker-compose.prod.yml exec app env | grep PORT
# Should show: PORT=3000
```

### Issue: SSL certificate request fails

**Cause**: Domain not pointing to server or ports not accessible.

**Solution**:
```bash
# 1. Verify DNS
nslookup your-domain.com
dig your-domain.com

# 2. Check ports 80 and 443 are accessible from internet
# From external machine:
curl http://your-server-ip
curl https://your-server-ip

# 3. Ensure firewall allows ports 80 and 443
sudo ufw status
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

### Issue: App works but database connection fails

**Cause**: Database not ready or credentials wrong.

**Solution**:
```bash
# Check database is running
docker compose -f docker-compose.prod.yml ps db

# View database logs
docker compose -f docker-compose.prod.yml logs db

# Test database connection
docker compose -f docker-compose.prod.yml exec db psql -U archon myapp -c "SELECT 1"

# Verify DATABASE_URL in .env.prod
cat .env.prod | grep DATABASE_URL
```

## Multiple Applications

You can run multiple starter-app instances on the same server:

```bash
# App 1
pwsh setup/bootstrap.ps1 -Environment prod -AppName "app1"
docker compose -f docker-compose.prod.yml up -d
docker network connect app1 nginx-proxy-manager

# App 2
pwsh setup/bootstrap.ps1 -Environment prod -AppName "app2"
docker compose -f docker-compose.prod.yml up -d
docker network connect app2 nginx-proxy-manager
```

In NPM, create proxy hosts:
- `app1.example.com` → `http://app1:3000`
- `app2.example.com` → `http://app2:3000`

Each app has its own isolated network.

## Maintenance

### Viewing Logs

```bash
# All services
docker compose -f docker-compose.prod.yml logs -f

# Just app
docker compose -f docker-compose.prod.yml logs -f app

# Just database
docker compose -f docker-compose.prod.yml logs -f db
```

### Restarting Services

```bash
# Restart just the app (zero-downtime)
docker compose -f docker-compose.prod.yml restart app

# Restart everything
docker compose -f docker-compose.prod.yml restart
```

### Updating the App

```bash
cd /opt/starter-app

# Pull latest code
git pull origin main

# Rebuild and restart
docker compose -f docker-compose.prod.yml build app
docker compose -f docker-compose.prod.yml up -d --no-deps app

# Verify health
curl https://your-domain.com/health
```

### Backups

```bash
# Manual backup
pwsh scripts/backup.ps1 -Environment prod -Compress

# Setup automated daily backups
crontab -e
# Add: 0 2 * * * /usr/bin/pwsh /opt/starter-app/scripts/backup.ps1 -Environment prod -Compress
```

## Security Checklist

- [x] App network is isolated (no internet access)
- [x] No ports exposed to host
- [x] Database and Redis are internal only
- [x] HTTPS with valid SSL certificate
- [x] Force HTTPS redirect enabled
- [x] Secure secrets generated (32-64 chars)
- [x] Non-root container user (UID 1001)
- [x] ORIGIN set to HTTPS domain (not localhost)

## Next Steps

- ✅ Setup automated backups (see Maintenance section)
- ✅ Configure monitoring (health endpoint: `/health`)
- ✅ Review logs regularly
- ✅ Test restore procedure
- ✅ Document any custom configurations

## Support

For issues specific to:
- **NPM**: https://nginxproxymanager.com/
- **Starter App**: See main deployment guide at `docs/DEPLOYMENT.md`
- **Docker**: https://docs.docker.com/
