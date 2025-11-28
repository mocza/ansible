# Homelab automation using Ansible
Automated configuration of homelab devices: servers, workstations, routers.

# Steps to get started with a brand new device 
- Run the preface.sh script as root right after fresh OS install on a new device: this will install ansible-pull prerequisites
```curl https://raw.githubusercontent.com/mocza/ansible/refs/heads/main/preface.sh | bash``` 
- Run ansible-pull as root to configure for the automated configuration of the new device
ansible-pull -U https://github.com/mocza/ansible.git --vault-id @prompt
- Now you can continue with execute and scheduling Ansible tasks from Semaphore UI
