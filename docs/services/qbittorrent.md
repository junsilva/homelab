# qbittorrent

Apparently, this is now the recommended torrent client.  I used to use utorrent back in the days but looks like it has fallen out of favor since then.

## Setup

### Execution Parameters
* **Container Name:** `qbittorrent`
* **Base Image:** `lscr.io/linuxserver/qbittorrent:4.6.7`
* **Network Mode:** `service:gluetun` (Shares Gluetun's secure network namespace)
* **Depends On:** `gluetun` (Enforces `condition: service_healthy` check before initialization)
* **Restart Policy:** `unless-stopped`

## Storage

| Host Path | Container Target Path | Notes |
| :--- | :--- | :--- |
| `/srv/appdata/qbittorrent` | `/config` |  |
| `/mnt/nas` | `/data` | share from `mnemosyne` |

### Config

Application configuration will be set on fast storage mount.  To help keep things tidy, it will be set on its own folder within `apollo`.  Some of the configuration have been set manually via the UI.  A copy of the config for it can be seen [here](/config/qbittorrent/qbittorrent.conf.example)

### Data
Downloads will be stored over the share provided by `mnemosyne`. 

* **Protocol:** SMB / CIFS
* **Network Target:** `mnemosyne/data`
* **Local Mount Path:** `/mnt/nas`
* **FSTAB Options Blueprint:** `iocharset=utf8,noperm,nounix,file_mode=0775,dir_mode=0775`

#### Hardlink & Atomic Move Optimization
To prevent multiple wasteful writes when files are moved around by qbittorrent and the different *Arr services, hardlinks are used.   This was also one of my headaches and the one that drove me to just mount everything as a single folder in `apollo`.  

## Excluded Files

To help keep my *Arr stack from downloading anything silly and potentially harmful, following are set as exclusions and would not be downloaded:

* **`.exe`, `.scr`:** Prevents arbitrary x86 executable binary delivery.
* **`.lnk`:** Neutralizes hidden shortcut targets designed to trigger remote malicious command injection loops.
* **`.iso`:** Disallows thick virtual disk containers that slip past basic file system scanners.
* **`.zipx`, `.arj`, `.lzh`, `.uue`:** Blocks obfuscated, rare compression schemas used to smuggle payloads.
