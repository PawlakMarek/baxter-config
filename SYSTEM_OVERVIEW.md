# Baxter System Overview

## System Identity
- **Hostname**: `baxter`
- **Domain**: `pixelkeepers.net`
- **FQDN**: `baxter.pixelkeepers.net`
- **Description**: NixOS Mail Server on Hetzner CX32
- **NixOS Version**: 25.05

## Hardware Configuration
- **Platform**: Hetzner Cloud CX32 (QEMU/KVM)
- **Architecture**: x86_64-linux
- **CPU**: Intel with microcode updates enabled
- **Storage**: `/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_101118637`

## Network Configuration
- **Primary Interface**: `en*` (matched by systemd-networkd)
- **DHCP**: IPv4 enabled
- **IPv6**: Accept RA enabled with privacy extensions
- **DNS**: 
  - Primary: `1.1.1.1#cloudflare-dns.com`
  - Secondary: `8.8.8.8#dns.google`
  - DoTLS: Enabled
  - DNSSEC: Enabled
- **Time Servers**: 
  - `ntp1.hetzner.de`
  - `ntp2.hetzner.de`
  - `ntp3.hetzner.de`

## Storage Architecture
### Disk Layout
- **Partition 1**: BIOS boot (1M, EF02)
- **Partition 2**: Boot partition (512M, ext4, label: `boot`)
- **Partition 3**: LUKS encrypted root (remaining space, label: `CRYPTROOT`)

### Encryption & LVM
- **LUKS**: Version 2 with AES-XTS-Plain64, SHA-512, Argon2id
- **Volume Group**: `vg0`
- **Logical Volumes**:
  - `root`: Primary filesystem (XFS, label: `root`)
  - `swap`: 2GB encrypted swap
  - `emergency`: 2GB emergency partition (ext4, noauto)

### Filesystem Options
- **Root (XFS)**: `noatime,nodiratime,largeio,inode64,allocsize=16m,logbsize=256k`
- **Boot (ext4)**: `defaults,noatime,nodiratime,errors=remount-ro`

## Authentication & Access
### SSH Configuration
- **Port**: 22
- **Allowed Users**: `h4wkeye`, `root`
- **Authentication**: Public key only (password auth disabled)
- **Root Access**: `prohibit-password` (key-only)
- **Connection Limits**: Max 10 sessions, max 10 startups

### SSH Keys
**Primary SSH Key** (Ed25519):
```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMGeqoInM+/Ia0qeAiFOLywjCo6bH5nJGYYMIPShxKT9
```

### User Accounts
- **h4wkeye**: Primary user, wheel group, declarative password hash
- **root**: Emergency access, declarative password hash

### InitRD SSH Unlock
- **Port**: 2222
- **Host Key**: `/boot/initrd-ssh-ed25519-key` (auto-generated)
- **Unlock Script**: `/bin/unlock-disk`
- **Authorized Keys**: Same as main system

## Security Configuration
### Firewall
- **Default**: Restrictive (deny all)
- **Allowed TCP**: 22 (SSH)
- **Rate Limiting**: SSH connections (4 attempts per 60 seconds)

### Fail2Ban
- **SSH Protection**: 3 attempts, 1 hour ban
- **Ban Time Increment**: Up to 1 week maximum
- **Log Path**: `/var/log/auth.log`

### Kernel Security
- **Features**: SLAB hardening, memory initialization, address randomization
- **Disabled**: VSyscalls, SMT
- **Mitigations**: Enabled with performance optimizations

## Boot Configuration
### GRUB
- **Version**: 2
- **Cryptodisk**: Enabled
- **Timeout**: 10 seconds
- **Configuration Limit**: 10 entries
- **Console**: Serial (ttyS0, 19200 baud)

### Kernel Parameters
- **Security**: `init_on_alloc=1`, `init_on_free=1`, `page_alloc.shuffle=1`
- **Performance**: `elevator=none`, `transparent_hugepage=never`
- **Network**: `net.ifnames=0`, BBR congestion control
- **Cloud**: Hetzner-specific optimizations

## Secrets Management (SOPS)
- **Key File**: `/var/lib/sops-nix/key.txt` (auto-generated)
- **Age Recipient**: `age1dr7wep27gem82xw0rehwefrw4ksmjnacaktkwd89ly0tff5d0pgqke6m8r`

### Managed Secrets
- `h4wkeye-password-hash`: User password hash
- `root-password-hash`: Root password hash
- `luks-password`: Disk encryption password
- `initrd-ssh-authorized-key`: SSH key for initrd unlock
- `storage-box-*`: Backup storage credentials
- `mail-admin-password`: Mail server admin password (null)
- `dkim-private-key`: Email DKIM key (null)

## System Services
### Core Services
- **SSH**: OpenSSH with hardened configuration
- **Fail2Ban**: Intrusion prevention
- **systemd-networkd**: Network management
- **systemd-resolved**: DNS resolution with DoTLS
- **systemd-timesyncd**: Time synchronization

### Optimization Services
- **fstrim**: Weekly SSD optimization
- **journald**: Log management (1GB max, 1-month retention)
- **logrotate**: Weekly log rotation

## Development & Deployment
### Deploy-rs Configuration
- **SSH User**: `h4wkeye`
- **Target User**: `root`
- **Remote Build**: Disabled (build locally)
- **Auto-rollback**: Enabled
- **Magic rollback**: Enabled
- **Confirmation Timeout**: 60 seconds

### Helper Scripts
Available in development shell:
- `baxter-deploy`: Deploy configuration
- `baxter-build`: Build configuration locally
- `baxter-check`: Validate configuration
- `baxter-secrets`: Edit encrypted secrets
- `baxter-ssh`: SSH to server
- `baxter-status`: Check system status
- `baxter-unlock`: Emergency SSH unlock
- `baxter-rollback`: Rollback deployment

## Package Management
### Nix Configuration
- **Experimental Features**: Flakes, nix-command
- **Auto-optimize**: Enabled
- **Garbage Collection**: Weekly, 30-day retention
- **Build Limits**: 2 max jobs, 4 cores
- **Trusted Users**: `root`, `h4wkeye`

### Substituters
- `cache.nixos.org`
- `nix-community.cachix.org`

## Installed Packages
### Essential Tools
- vim, git, curl, wget, rsync

### System Monitoring
- htop, iotop, lsof, tcpdump

### Network Tools
- dig, nmap, netcat, traceroute, whois

### File Tools
- tree, fd, ripgrep, file, unzip

### System Tools
- pciutils, usbutils, lshw, dmidecode

### Security Tools
- cryptsetup

### Development
- deploy-rs

## Environment Configuration
- **Editor**: vim
- **Browser**: curl
- **Pager**: less
- **Shell**: zsh with completion and colors
- **Timezone**: Europe/Warsaw
- **Locale**: en_US.UTF-8

## Status & Health
The system is configured for:
- Secure remote administration
- Automated deployments
- Comprehensive logging
- Hardware optimization for cloud environment
- Emergency recovery capabilities
