# Apollo

God of music and the Arts.  I thought it was a fitting name for my VM that will be housing services that will be heavily involved with trying to retrieve it.  

This VM will have access to two types of storage.  Fast local storage which is baked into this VMs setup, and Network storage which it will mount into using fstab. Technically, the network storage is in the same physical host, its just in `mnemosyne`.  But I wanted to setup this VM in such a way that it is ready for when I extract out the NAS into a separate physical node.

---

## Setup

Proxmox setup details for the VM

| Attribute | Value |
| :--- | :--- |
| VM Identifier | 101 |
| Compute | 4 vCPU Cores |
| Memory | 10 GB |
| SSD Storage | 64 GB |

## Docker

Docker compose file for services hosted by apollo is [here](/docker/apollo/docker-compose.yml).  I still haven't decided if I want to break things up into separate smaller docker files for each service to help keep things a bit more modular.  But so far, leaned more into simplifying things.  Not much benefit at the moment to break things off into smaller files.

## Mounts

### App Mount
Docker compose, .env config files, local application files and container metadata will use high speed storage.  I haven't done fine grained setup / permissioning for it and decided to make things accessible to a shared admin user for all VMs.  I will be using docker for all my apps and will avoid having to install anything outside it.

* **Host Path:** Local Proxmox Virtual Disk (`rpool`)
* **Guest Path:** `/srv/appdata`
* **Ownership:** `jun_admin` (UID `1000`)

### Data Mount
Bulk storage for anything that the services need to process.  Will use the slower storage exposed by `mnemosyne`.  I have had issues trying to wire up the services together and instead of manually mounting individual folders, I have decided to simplify things and mount the root directory and just go from there.  In the future, will be separating out service specific folders from the user share directories.   

I also wanted to try to harden the mount and store creds as separate credential files.  So far it has been working.

* **Protocol:** SMB / CIFS
* **Network Target:** `mnemosyne/data`
* **Local Mount Path:** `/mnt/nas`
* **Credentials Secret File:** `/etc/samba/creds_apollo`
* **FSTAB Options Blueprint:** `iocharset=utf8,noperm,nounix,file_mode=0775,dir_mode=0775`
* **Active Mount Identity:** Enforced via UID `1000` (`jun_admin`) and primary GID `1101` (`media`) to guarantee write persistence across services.

## Core Container Manifest

| Container Name | Web UI Port | Volume | Notes |
| :--- | :--- | :--- | :--- |
| [gluetun](/docs/services/gluetun.md#gluetun) | — | — | Outbound wireguard stack handler |
| [qbittorrent](/docs/services/qbittorrent.md) | `8080` | `/torrents` | Networked via Gluetun |
| [nzbget](/docs/services/nzbget.md) | `6789` | `/usenet` | Networked via Gluetun |
| [prowlarr](/docs/services/prowlarr.md) | `9696` | — | |
| **sonarr** | `8989` | `/media/tv` | |
| **sonarr-anime**| `8990` | `/media/anime` | |
| **radarr** | `7878` | `/media/movies` | |
| **lidarr** | `8686` | `/media/music` | |
| **mylar3** | `8090` | `/media/books/comics` |  |
| **lazylibrarian**| `5299` | `/media/books` |  |
| **bazarr** | `6767` | `/media` | |
| **jellyseerr** | `5055` | — | |