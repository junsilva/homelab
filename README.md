# Bahay Silva: Jun's Homelab

Tinker and play around with service hosting.

## Project Goals
* Host interesting services and keep subscription costs down.
* Learn more about the Systems Administration and Infrastructure side of things.
* Secure and own personal family data.

## Repository Directory Map

```text
homelab/
├── docs/                     
├── scripts/                  
├── templates/                 # Configuration templates
└── compose/                   # Docker compose files
```

## Details

### Setup Strategy
Start small and use a capable second hand workstation.  Build my way to multiple nodes eventually.  When I get the time and money, I'd like a separate NAS and a beefy one to hose local LLMs.  With RAM-pocalypse, will have to wait for a while...

### Physical Nodes
| Node Name | Role | OS | Model | CPU | Memory | Storage (SSD) | Storage (SATA) |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| olympus | Main compute node | Proxmox VE | HP Elitedesk 800 G6 SFF | Intel i7-10700 (8C/16T) | 32 GB | 1 TB NVMe | 2 x 8TB (WD Reds) |

### Virtual Environments (VMs/LXCs)
| Host | Name (ID) | Type | Role | OS | CPU | Memory | Storage |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| olympus | mnemosyne (100) | LXC | Manage network shares | Ubuntu | 2 Cores | 4 GB | 16 GB |
|  | apollo (101) | VM | Host *Arr Stack | Linux | 4 Cores | 10 GB | 64 GB |
|  | dionysus (102) | VM | Host media services | Linux | 4 Cores | 6 GB | 100 GB |  

### Application Services Directory

| Service | VM/LXC | Port |
| :--- | :--- | :---: |
| Samba Server | mnemosyne | `445` |
| Gluetun | apollo |  |
| qBittorrent | apollo |  |
| Sonarr | apollo | `8989` |
| Radarr | apollo | `7878` |
| Lidarr | apollo | `8686` |
| Prowlarr | apollo | `9696`|
| NZBGet | apollo | |
| Tdarr | dionysus | `8265` |
| Jellyfin | dionysus | `8096` |
| Immich | dionysus | `2283` |
| Audiobookshelf | dionysus | `8378` |
| Kavita | dionysus | `5000` |