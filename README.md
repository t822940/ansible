# Ansible Bootstrap

This directory contains tools and utilities for bootstrapping Ansible on minimal Linux systems, particularly for environments where Ansible isn't readily available through package managers.

## Files

- **`install_ansible.sh`** - Bootstrap script for installing Ansible on RHEL/EL9 systems
- **`.gitignore`** - Git ignore rules for Ansible and related sensitive files

## Quick Start

### Installing Ansible

Run the bootstrap script as root or with sudo:

```bash
sudo bash install_ansible.sh
```

This script will:
- Install Python3 and curl prerequisites
- Bootstrap pip using the official installer
- Install ansible-core in user space
- Install the community.general collection
- Configure PATH for ansible commands

### Post-Installation

After installation, you may need to reload your shell:

```bash
# Reload shell or manually export PATH
export PATH=$HOME/.local/bin:$PATH

# Verify installation
ansible --version
ansible-playbook --version
```

## What Gets Installed

- **ansible-core** - Core Ansible engine
- **community.general** - Essential community collection
- **pip and wheel** - Python package management tools

All components are installed in user space (`~/.local/bin`) to avoid system-wide package conflicts.

## Use Cases

This bootstrap approach is ideal for:
- Minimal Linux installations without registered repositories
- Container environments needing Ansible
- Systems where package managers don't have recent Ansible versions
- Environments requiring user-space installations

## Orchestration Playbook

The `deploy.yml` playbook provides centralized deployment orchestration for all components:

### Usage Examples

Deploy all components:
```bash
ansible-playbook deploy.yml -e 'deploy_components=["k3s","awx","ipam"]'
```

Deploy only K3s:
```bash
ansible-playbook deploy.yml -e 'deploy_components=["k3s"]'
```

Deploy K3s and AWX:
```bash
ansible-playbook deploy.yml -e 'deploy_components=["k3s","awx"]'
```

### Supported Components

- **`k3s`** - Deploys single-node Kubernetes cluster
- **`awx`** - Deploys AWX automation platform (requires K3s)
- **`ipam`** - Deploys phpIPAM network management (requires K3s)

### Deployment Logic

The playbook intelligently handles deployments by:
- **Prioritizing local files** - Uses deployment files from parent directories when available
- **Remote repository fallback** - Only attempts git cloning if local files not found AND repo URLs configured
- **Dependency management** - Ensures proper order (K3s before AWX/IPAM)
- **Service readiness** - Waits for services to be ready before proceeding
- **Access information** - Provides credentials and URLs after deployment

### Remote Repository Configuration

If you need to use remote repositories, set them via extra-vars:

```bash
ansible-playbook deploy.yml \
  -e 'deploy_components=["k3s","awx"]' \
  -e 'k3s_repo=https://github.com/your-org/k3s-deployment.git' \
  -e 'awx_repo=https://github.com/your-org/awx-deployment.git'
```

**Note**: The playbook is designed to work primarily with local files. Remote repository URLs are intentionally empty by default to prevent authentication errors.

## Integration

This Ansible installation can be used with other deployments in this repository:
- K3s cluster management
- AWX deployment automation
- IPAM system configuration

## Notes

- Installs in user space to avoid system conflicts
- Requires internet connectivity for downloading packages
- Tested primarily on RHEL/EL9 distributions
- PATH configuration is automatically added to `.bashrc`