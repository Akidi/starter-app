# Production Deployment Guide

This guide will walk you through deploying this application to a production server while maintaining the simple bootstrap experience for development.

## Quick Start (TL;DR)

For a production deployment on a fresh server:

```bash
# Clone the repository
git clone <your-repo-url> /opt/starter-app
cd /opt/starter-app

# Install PowerShell (if not already installed)
# See: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux

# Run bootstrap in production mode
pwsh setup/bootstrap.ps1 -Environment prod -AppName "myapp"

# Start the services
docker compose -f docker-compose.prod.yml up -d
```

**That's it!** The bootstrap script handles everything else automatically.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Production Bootstrap](#production-bootstrap)
4. [Reverse Proxy Setup](#reverse-proxy-setup)
5. [SSL/TLS Configuration](#ssltls-configuration)
6. [Post-Deployment](#post-deployment)
7. [Monitoring & Maintenance](#monitoring--maintenance)
8. [Backup & Restore](#backup--restore)
9. [Troubleshooting](#troubleshooting)
10. [Dev vs Production Differences](#dev-vs-production-differences)

---

## Prerequisites

### Server Requirements

- **OS:** Linux (Ubuntu 22.04+ recommended) or any Docker-capable OS
- **CPU:** 2+ cores recommended
- **RAM:** 4GB minimum, 8GB+ recommended
- **Disk:** 20GB+ free space
- **Docker:** 24.0.0+
- **Docker Compose:** 2.20.0+
- **PowerShell:** 7.2+ (for bootstrap script)
- **Network:**
  - Ports 80 and 443 open for web traffic
  - Domain name pointed to server IP

### Software Installation

#### Ubuntu/Debian:
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt install docker-compose-plugin

# Install PowerShell
wget -q https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt update
sudo apt install -y powershell

# Log out and back in for docker group to take effect
```

#### RHEL/CentOS/Fedora:
```bash
# Install Docker
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Install PowerShell
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
curl https://packages.microsoft.com/config/rhel/8/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo
sudo dnf install powershell
```

---

## Initial Setup

### 1. Clone the Repository

Choose a deployment directory (recommended: `/opt/starter-app`):

```bash
sudo mkdir -p /opt/starter-app
sudo chown $USER:$USER /opt/starter-app
cd /opt/starter-app
git clone <your-repo-url> .
```

### 2. Configure Domain

Ensure your domain points to the server's IP address:

```bash
# Test DNS resolution
nslookup your-domain.com
dig your-domain.com
```

---

## Production Bootstrap

### Running Bootstrap in Production Mode

The bootstrap script automatically configures everything for production:

```bash
cd /opt/starter-app

# Interactive mode (recommended for first-time setup)
pwsh setup/bootstrap.ps1 -Environment prod -AppName "myapp"

# Non-interactive mode (for automation)
pwsh setup/bootstrap.ps1 -Environment prod -AppName "myapp" -NonInteractive

# Dry run (see what would happen without making changes)
pwsh setup/bootstrap.ps1 -Environment prod -AppName "myapp" -DryRun
```

### What Bootstrap Does in Production Mode

1. ✅ **Generates cryptographically secure secrets** (32-64 characters each)
   - APP_SECRET (64 chars) - Session encryption
   - Database passwords (6 users + superuser)
   - Redis passwords (7 users)

2. ✅ **Creates production-specific files:**
   - `.env.prod` - Production environment variables
   - `docker-compose.prod.yml` - Production container configuration
   - `db/init.prod.sql` - Database initialization with secure roles
   - `redis.prod.conf` - Hardened Redis configuration
   - `redis.prod.acl` - Redis access control lists

3. ✅ **Configures production settings:**
   - Non-root container user (UID 1001)
   - Debug mode disabled
   - Secure cookie settings (HTTPS-only)
   - Resource limits enforced
   - Health checks enabled
   - Automatic restart policies

4. ✅ **Security hardening:**
   - Disables dangerous Redis commands
   - Creates least-privilege database users
   - Enforces schema-based access control
   - Enables PostgreSQL event triggers for ACL enforcement

### Important Bootstrap Options

```powershell
# Production with custom domain
pwsh setup/bootstrap.ps1 -Environment prod -AppName "myapp" -Domain "https://app.example.com"

# Production with custom port
pwsh setup/bootstrap.ps1 -Environment prod -AppName "myapp" -Port 8080

# Regenerate secrets only (if compromised)
pwsh setup/bootstrap.ps1 -Environment prod -Action passwords

# Add/update database schema
pwsh setup/bootstrap.ps1 -Environment prod -Action schema -Schema "newschema"
```

---

## Reverse Proxy Setup

**⚠️ IMPORTANT:** You **must** use a reverse proxy in production for:
- SSL/TLS termination
- Domain routing
- Security headers
- Rate limiting
- Static asset caching

**Quick Start for Nginx Proxy Manager Users**: See **[NPM-SETUP.md](NPM-SETUP.md)** for a streamlined 5-minute setup guide.

### Option 1: Caddy (Recommended - Automatic HTTPS)

Caddy automatically obtains and renews SSL certificates from Let's Encrypt.

**Install Caddy:**
```bash
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install caddy
```

**Configure Caddy:**

Use the provided template:
```bash
# Copy and edit the Caddy configuration
sudo cp templates/Caddyfile.template /etc/caddy/Caddyfile
sudo nano /etc/caddy/Caddyfile

# Update these values:
# - your-domain.com → your actual domain
# - localhost:5175 → your app's address

# Reload Caddy
sudo systemctl reload caddy
```

### Option 2: Nginx

**Install Nginx:**
```bash
sudo apt install nginx
```

**Configure Nginx:**
```bash
# Copy and edit the nginx configuration
sudo cp templates/nginx.conf.template /etc/nginx/sites-available/starter-app
sudo ln -s /etc/nginx/sites-available/starter-app /etc/nginx/sites-enabled/
sudo nano /etc/nginx/sites-available/starter-app

# Test configuration
sudo nginx -t

# Reload nginx
sudo systemctl reload nginx
```

### Option 3: Nginx Proxy Manager (Recommended for Docker Environments)

**Nginx Proxy Manager (NPM)** is a Docker-based reverse proxy with a web UI that makes SSL certificate management trivial.

#### Prerequisites

- NPM is already installed and running on your server
- You know the NPM container name (usually `nginx-proxy-manager` or similar)

#### Setup Steps

1. **Start your application** (this creates the isolated network):
   ```bash
   cd /opt/starter-app
   docker compose -f docker-compose.prod.yml up -d
   ```

2. **Connect NPM to your app's network**:

   First, find your NPM container name:
   ```bash
   docker ps | grep nginx-proxy-manager
   # Or: docker ps
   ```

   Then connect NPM to your app's network:
   ```bash
   # Replace 'nginx-proxy-manager' with your actual NPM container name
   # Replace 'myapp' with your actual app name
   docker network connect myapp nginx-proxy-manager
   ```

   Verify the connection:
   ```bash
   docker network inspect myapp
   # You should see both your app and NPM container listed
   ```

3. **Configure Proxy Host in NPM Web UI**:

   - Open NPM web interface (usually `http://your-server-ip:81`)
   - Go to **Proxy Hosts** → **Add Proxy Host**
   - **Details tab**:
     - Domain Names: `your-domain.com`
     - Scheme: `http`
     - Forward Hostname/IP: `myapp` (your container name)
     - Forward Port: `3000` (production internal port)
     - ✅ Enable "Cache Assets"
     - ✅ Enable "Block Common Exploits"
     - ✅ Enable "Websockets Support" (if needed)

   - **SSL tab**:
     - ✅ Enable "SSL"
     - SSL Certificate: "Request a new SSL Certificate"
     - ✅ "Force SSL"
     - ✅ "HTTP/2 Support"
     - Email: your-email@example.com
     - ✅ "I Agree to the Let's Encrypt Terms of Service"

   - Click **Save**

4. **Verify it works**:
   ```bash
   curl https://your-domain.com/health
   # Should return: {"status":"ok"}
   ```

#### NPM Network Architecture

```
Internet
    ↓
[Nginx Proxy Manager] ← On its own network + connected to app network
    ↓
[myapp network] ← Isolated internal network
    ├─ myapp (container) ← Port 3000 (internal only, no host exposure)
    ├─ db (PostgreSQL) ← Port 5432 (internal only)
    └─ redis ← Port 6379 (internal only)
```

#### Important Notes

- **No external ports**: The app doesn't expose any ports to the host (`localhost:5175` won't work)
- **Network isolation**: Database and Redis are only accessible within the Docker network
- **Container name**: NPM reaches your app as `http://myapp:3000`
- **Automatic SSL**: NPM handles Let's Encrypt certificates automatically
- **Multiple apps**: You can run multiple starter-app instances (with different names) and NPM can route to all of them

#### Troubleshooting NPM Setup

**App not reachable from NPM:**
```bash
# Check if NPM is connected to app network
docker network inspect myapp | grep nginx-proxy-manager

# If not listed, connect it:
docker network connect myapp nginx-proxy-manager

# Restart NPM to refresh network connections
docker restart nginx-proxy-manager
```

**Connection refused errors:**
- Verify container name matches: `docker ps --format '{{.Names}}'`
- Check app is running: `docker compose -f docker-compose.prod.yml ps`
- Verify internal port is 3000 (production): `docker compose -f docker-compose.prod.yml exec app env | grep PORT`

**SSL certificate issues:**
- Ensure domain points to your server's IP
- Check port 80 and 443 are open and accessible
- NPM needs ports 80 and 443 on the host to get Let's Encrypt certificates

---

## SSL/TLS Configuration

### Option 1: Caddy (Automatic)

Caddy handles SSL automatically. Just ensure:
1. Your domain points to the server
2. Ports 80 and 443 are open
3. Caddy can write to `/var/lib/caddy`

### Option 2: Let's Encrypt with Certbot (Manual)

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Obtain certificate (for Nginx)
sudo certbot --nginx -d your-domain.com

# Or for standalone (if not using Nginx)
sudo certbot certonly --standalone -d your-domain.com

# Test renewal
sudo certbot renew --dry-run

# Certbot auto-renewal is configured via systemd timer
sudo systemctl status certbot.timer
```

---

## Post-Deployment

### 1. Start the Application

```bash
cd /opt/starter-app

# Start all services
docker compose -f docker-compose.prod.yml up -d

# Check logs
docker compose -f docker-compose.prod.yml logs -f

# Check service health
docker compose -f docker-compose.prod.yml ps
```

### 2. Verify Health

```bash
# Check health endpoint
curl http://localhost:5175/health

# Should return: {"status":"ok"}
```

### 3. Test External Access

```bash
# From another machine or browser
curl https://your-domain.com/health
```

### 4. Setup Systemd Service (Optional)

For automatic startup on boot:

```bash
# Copy service file
sudo cp templates/starter-app.service /etc/systemd/system/

# Edit paths if needed
sudo nano /etc/systemd/system/starter-app.service

# Enable and start
sudo systemctl daemon-reload
sudo systemctl enable starter-app
sudo systemctl start starter-app

# Check status
sudo systemctl status starter-app
```

---

## Monitoring & Maintenance

### Health Checks

The application exposes a health endpoint at `/health`:

```bash
# Basic health check
curl http://localhost:5175/health

# Detailed check with database
curl http://localhost:5175/health?detailed=true
```

### Log Management

```bash
# View application logs
docker compose -f docker-compose.prod.yml logs app

# Follow logs in real-time
docker compose -f docker-compose.prod.yml logs -f app

# View database logs
docker compose -f docker-compose.prod.yml logs db

# View Redis logs
docker compose -f docker-compose.prod.yml logs redis
```

### Resource Monitoring

```bash
# Check container resource usage
docker stats

# Check disk usage
df -h
docker system df

# Clean up old images/containers
docker system prune -a
```

### Updates and Redeployment

```bash
cd /opt/starter-app

# Pull latest code
git pull origin main

# Rebuild application (if code changed)
docker compose -f docker-compose.prod.yml build app

# Restart with zero-downtime (if using orchestration)
docker compose -f docker-compose.prod.yml up -d --no-deps --build app

# Or full restart
docker compose -f docker-compose.prod.yml restart
```

---

## Backup & Restore

### Automated Backups

Use the provided backup script:

```bash
# Run manual backup
pwsh scripts/backup.ps1 -Environment prod

# Setup automated backups with cron
crontab -e

# Add this line for daily backups at 2 AM:
0 2 * * * /usr/bin/pwsh /opt/starter-app/scripts/backup.ps1 -Environment prod
```

### Manual Database Backup

```bash
# Backup PostgreSQL
docker compose -f docker-compose.prod.yml exec db pg_dump -U archon myapp > backup_$(date +%Y%m%d).sql

# Or use the archon user from outside container
docker compose -f docker-compose.prod.yml exec db pg_dump -U archon myapp | gzip > backup_$(date +%Y%m%d).sql.gz
```

### Manual Redis Backup

```bash
# Redis automatically saves to dump.rdb (configured in redis.prod.conf)
# Copy the dump file
docker compose -f docker-compose.prod.yml exec redis redis-cli --user archon -a <REDIS_ARCHON_PASSWORD> BGSAVE
docker compose -f docker-compose.prod.yml cp redis:/data/dump.rdb ./backups/redis_$(date +%Y%m%d).rdb
```

### Restore from Backup

```bash
# Restore PostgreSQL
docker compose -f docker-compose.prod.yml exec -T db psql -U archon myapp < backup_20250102.sql

# Restore Redis (stop redis first)
docker compose -f docker-compose.prod.yml stop redis
docker compose -f docker-compose.prod.yml cp ./backups/redis_20250102.rdb redis:/data/dump.rdb
docker compose -f docker-compose.prod.yml start redis
```

---

## Troubleshooting

### Application won't start

```bash
# Check logs
docker compose -f docker-compose.prod.yml logs app

# Common issues:
# 1. Database not ready - wait 30 seconds and check again
# 2. Missing environment variables - verify .env.prod exists
# 3. Port already in use - check with: sudo netstat -tlnp | grep 5175
```

### Database connection errors

```bash
# Check database is running
docker compose -f docker-compose.prod.yml ps db

# Test connection
docker compose -f docker-compose.prod.yml exec db psql -U archon myapp -c "SELECT 1"

# Check credentials in .env.prod
cat .env.prod | grep DATABASE_URL
```

### Redis connection errors

```bash
# Check Redis is running
docker compose -f docker-compose.prod.yml ps redis

# Test connection
docker compose -f docker-compose.prod.yml exec redis redis-cli --user tinkerer -a <password> PING

# Should return: PONG
```

### SSL certificate issues

```bash
# Caddy: Check logs
sudo journalctl -u caddy -f

# Let's Encrypt: Test renewal
sudo certbot renew --dry-run

# Check certificate expiry
echo | openssl s_client -servername your-domain.com -connect your-domain.com:443 2>/dev/null | openssl x509 -noout -dates
```

### Performance issues

```bash
# Check resource usage
docker stats

# Check database performance
docker compose -f docker-compose.prod.yml exec db psql -U archon myapp -c "SELECT * FROM pg_stat_activity"

# Check Redis memory
docker compose -f docker-compose.prod.yml exec redis redis-cli --user archon -a <password> INFO memory
```

---

## Dev vs Production Differences

### Development Mode

```bash
# Bootstrap for dev
pwsh setup/bootstrap.ps1 -Environment dev -AppName "myapp"

# Start dev environment
docker compose up -d

# Features:
# - Hot reload enabled (port 5173)
# - Debug logging
# - Dev tools installed (git, vim)
# - Database seeding enabled
# - Source code mounted as volume
# - Runs as root user
```

### Production Mode

```bash
# Bootstrap for prod
pwsh setup/bootstrap.ps1 -Environment prod -AppName "myapp"

# Start prod environment
docker compose -f docker-compose.prod.yml up -d

# Features:
# - Optimized build
# - Minimal image (non-root user)
# - No debug tools
# - Secure cookies (HTTPS-only)
# - No seeding
# - Automatic restarts
# - Resource limits enforced
```

### Key Differences Table

| Feature | Development | Production |
|---------|-------------|------------|
| **Port** | 5173 | 5175 |
| **Hot Reload** | ✅ Enabled | ❌ Disabled |
| **Debug Mode** | ✅ Enabled | ❌ Disabled |
| **Database Seeding** | ✅ Auto-seed | ❌ No seeding |
| **Container User** | root | sveltekit (UID 1001) |
| **Source Volumes** | ✅ Mounted | ❌ Copied into image |
| **HTTPS Cookies** | ❌ HTTP OK | ✅ HTTPS only |
| **Restart Policy** | no | unless-stopped |
| **Build Target** | development | production |
| **Log Level** | verbose | notice |

---

## Security Checklist

Before going live, ensure:

- [ ] `.env.prod` is not committed to git (it's gitignored)
- [ ] All secrets are unique and strong (generated by bootstrap)
- [ ] SSL/TLS is enabled with valid certificate
- [ ] Firewall is configured (only ports 80, 443, SSH open)
- [ ] Database backups are configured and tested
- [ ] Monitoring/alerting is set up
- [ ] Domain is correctly pointed to server
- [ ] Health checks are responding
- [ ] Logs are being collected
- [ ] Resource limits are appropriate for your workload
- [ ] Redis persistence is enabled (AOF + RDB)
- [ ] Database connection strings use SSL mode (for managed DBs)

---

## Production Checklist

Run the validation script before going live:

```bash
pwsh scripts/validate-production.ps1 -Environment prod
```

This checks:
- Required files exist
- Docker and Docker Compose installed
- Environment variables set correctly
- Secrets are not weak/default values
- Services are healthy
- SSL certificate is valid
- Domain resolves correctly

---

## Advanced Topics

### Using Managed Databases

If using AWS RDS, Azure Database, or Google Cloud SQL instead of Docker PostgreSQL:

1. **Skip database container:**
   ```bash
   docker compose -f docker-compose.prod.yml up -d app redis
   ```

2. **Update `.env.prod`:**
   ```bash
   DATABASE_URL=postgresql://user:pass@rds-host.region.rds.amazonaws.com:5432/dbname?sslmode=require
   WRITE_DATABASE_URL=postgresql://...
   READ_DATABASE_URL=postgresql://...  # Point to read replica
   ```

3. **Run migrations manually:**
   ```bash
   cd app
   pnpm install
   pnpm db:migrate
   ```

### Kubernetes Deployment

For Kubernetes:
1. Use the production Docker image as base
2. Store secrets in Kubernetes Secrets or external secret manager
3. Use ConfigMaps for non-sensitive config
4. Set up Ingress for SSL termination
5. Use StatefulSets for PostgreSQL/Redis if not using managed services
6. Configure liveness and readiness probes using `/health` endpoint

### CI/CD Integration

The repository includes GitHub Actions workflows. To deploy automatically:

1. **Add secrets to GitHub:**
   - `PROD_SERVER_HOST`
   - `PROD_SERVER_USER`
   - `PROD_SERVER_SSH_KEY`

2. **Create deployment workflow:**
   ```yaml
   # .github/workflows/deploy.yml
   name: Deploy to Production
   on:
     push:
       branches: [main]
   jobs:
     deploy:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
         - name: Deploy to server
           uses: appleboy/ssh-action@master
           with:
             host: ${{ secrets.PROD_SERVER_HOST }}
             username: ${{ secrets.PROD_SERVER_USER }}
             key: ${{ secrets.PROD_SERVER_SSH_KEY }}
             script: |
               cd /opt/starter-app
               git pull origin main
               docker compose -f docker-compose.prod.yml build app
               docker compose -f docker-compose.prod.yml up -d --no-deps app
   ```

---

## Getting Help

- **Documentation:** Check `docs/` directory
- **Health Check:** `curl http://localhost:5175/health`
- **Logs:** `docker compose -f docker-compose.prod.yml logs -f`
- **Issues:** Report at GitHub repository

---

## Summary

The bootstrap script makes deployment simple:

1. **Clone repo**
2. **Run bootstrap:** `pwsh setup/bootstrap.ps1 -Environment prod -AppName "myapp"`
3. **Setup reverse proxy** (Caddy recommended)
4. **Start services:** `docker compose -f docker-compose.prod.yml up -d`
5. **Done!**

The same bootstrap script works for dev (just use `-Environment dev`), so developers get the same simple experience without any production complexities.
