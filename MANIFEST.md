# Repository File Manifest

This manifest lists all files in the repository for GitHub Actions purposes.

## Root Directory Files
- `config-example.yml`
- `config.yml`
- `run_playbooks.sh`
- `hosts`
- `hosts.example`
- `LICENSE`
- `README.md`
- `CONTRIBUTING.md`

## Images Directory
- `images/OB-logo-blue.png`
- `images/OB-logo-white.png`

## SecurityHardening Directory

### Authentication
- `SecurityHardening/authentication/configure_pam.yml`
- `SecurityHardening/authentication/password_policies.yml`
- `SecurityHardening/authentication/rollback_pam.sh`
- `SecurityHardening/authentication/rollback_pam_remote.yml`
- `SecurityHardening/authentication/secure_ssh.yml`

#### Authentication Templates
- `SecurityHardening/authentication/templates/access.conf.j2`
- `SecurityHardening/authentication/templates/common-account.j2`
- `SecurityHardening/authentication/templates/common-auth.j2`
- `SecurityHardening/authentication/templates/common-password.j2`
- `SecurityHardening/authentication/templates/common-session.j2`
- `SecurityHardening/authentication/templates/enforce_password_policy.sh.j2`
- `SecurityHardening/authentication/templates/login.defs.j2`
- `SecurityHardening/authentication/templates/login.j2`
- `SecurityHardening/authentication/templates/passwd.j2`
- `SecurityHardening/authentication/templates/pwquality.conf.j2`
- `SecurityHardening/authentication/templates/reset_password_date.sh.j2`
- `SecurityHardening/authentication/templates/ssh_config.j2`
- `SecurityHardening/authentication/templates/sshd.j2`
- `SecurityHardening/authentication/templates/sshd_config.j2`
- `SecurityHardening/authentication/templates/time.conf.j2`
- `SecurityHardening/authentication/templates/useradd.j2`

#### Authentication Handlers
- `SecurityHardening/authentication/handlers/main.yml`

### Filesystem
- `SecurityHardening/filesystem/configure_partitions.yml`
- `SecurityHardening/filesystem/disable_unnecessary_kernel_modules.yml`
- `SecurityHardening/filesystem/filesystem_integrity.yml`

#### Filesystem Templates
- `SecurityHardening/filesystem/templates/aide.conf.j2`
- `SecurityHardening/filesystem/templates/aidecheck.service.j2`
- `SecurityHardening/filesystem/templates/aidecheck.sh.j2`

### Network
- `SecurityHardening/network/configure_firewall_tasks.yml`
- `SecurityHardening/network/configure_network_security.yml`
- `SecurityHardening/network/disable_unnecessary_services.yml`
- `SecurityHardening/network/interactive_firewall_tasks.yml`
- `SecurityHardening/network/minimal_firewall_tasks.yml`
- `SecurityHardening/network/scan_active_services.yml`
- `SecurityHardening/network/standard_firewall_tasks.yml`

#### Network Templates
- `SecurityHardening/network/templates/dynamic-log-scan.conf.j2`
- `SecurityHardening/network/templates/fail2ban.conf.j2`
- `SecurityHardening/network/templates/network-interface-security-systemd.conf.j2`
- `SecurityHardening/network/templates/network-interface-security.conf.j2`
- `SecurityHardening/network/templates/network-security.conf.j2`
- `SecurityHardening/network/templates/nftables.conf.j2`

#### Network Handlers
- `SecurityHardening/network/handlers/main.yml`

### Boot
- `SecurityHardening/boot/apparmor_configuration.yml`

## Total File Count
This manifest includes **60 files** across the repository structure. 