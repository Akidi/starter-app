# SSH Setup for 1Password on Windows with Git

This guide documents the working SSH configuration for using 1Password's SSH agent with Git on Windows.

## Problem
Git Bash's bundled SSH couldn't connect to 1Password's SSH agent, causing "Permission denied (publickey)" errors when pushing/pulling, even though `ssh -T git@github.com` worked in PowerShell.

## Root Cause
- **PowerShell** uses Windows OpenSSH (OpenSSH_for_Windows_9.5) which can access 1Password's agent
- **Git Bash** uses its own SSH (OpenSSH_10.0p2) which cannot find the agent at the Windows named pipe path

## Solution

### 1. Configure Git to use Windows SSH
```bash
git config --global core.sshCommand "C:/Windows/System32/OpenSSH/ssh.exe"
```

### 2. SSH Config (`~/.ssh/config`)
**Important:** Specific hosts must come FIRST, then `Host *` defaults at the bottom. SSH uses first-match-wins, unlike CSS.
```
Host github.com
  IdentitiesOnly no
  AddKeysToAgent yes

Host *
  User james
  PreferredAuthentications publickey
  PubkeyAuthentication yes
  StrictHostKeyChecking yes
  ForwardAgent no
  ForwardX11 no
  LogLevel VERBOSE
  ServerAliveInterval 60
  ServerAliveCountMax 3
  KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
  Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
  MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
```

### 3. 1Password Settings
Ensure 1Password SSH agent is enabled:
- 1Password → Settings → Developer
- ✅ "Use the SSH agent"
- ✅ "Display key names when authorizing connections"

### 4. Verify SSH Key is in 1Password
Your GitHub SSH public key should be stored in 1Password and added to GitHub at https://github.com/settings/keys

## Key Points
- **DO NOT** use `IdentitiesOnly yes` for GitHub - this prevents using agent keys
- **DO NOT** specify `IdentityAgent` path in config - Windows OpenSSH finds it automatically via `SSH_AUTH_SOCK`
- **DO NOT** add `.pub` files as `IdentityFile` - they're public keys, not private keys
- SSH config order matters: specific hosts first, `Host *` last

## Testing
```bash
# Should show "Hi <username>!"
ssh -T git@github.com

# Should list your 1Password SSH keys
ssh-add -L

# Verify Git is using Windows SSH
git config --get core.sshCommand
# Should output: C:/Windows/System32/OpenSSH/ssh.exe
```

## Troubleshooting
If you still get permission denied:
```bash
# Check verbose output
GIT_SSH_COMMAND="ssh -vvv" git push -u origin main

# Look for these lines:
# ✅ Good: "get_agent_identities: agent returned X keys"
# ❌ Bad: "get_agent_identities: No such file or directory"
# ❌ Bad: "agent refused operation"
```

If the agent refuses operations, you likely have `IdentitiesOnly yes` set somewhere in your config.

## Environment
- Windows 11
- Git Bash (MINGW64)
- 1Password (Windows desktop app)
- Windows OpenSSH (OpenSSH_for_Windows_9.5)