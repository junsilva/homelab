# prowlarr

Github repo [here](https://github.com/prowlarr/prowlarr).  One of the first services in the *Arr stack that I read about and kick started my fascination with it. Its a service that helps manage the different sites/indexers where pointers to the file downloads are searched.  Aside from that, it has integration with other services in the *Arr stack and helps facilitate the communication between the services that specialise in finding files and attaching metadata to it, and the download clients.

Keeping track of all the sites/indexers is (was) such a pain.  It was easier back in the day when I can just google it or grab it from TPB.  I remember just doing a `filetype: torrent` search back then.  And it even showed me indexers that I am not across or aware of.  Having this layer to help manage syncing all the indexers to the different dependent services was cool.  

## Setup

### Execution Parameters
* **Container Name:** `prowlarr`
* **Base Image:** `lscr.io/linuxserver/prowlarr:latest`
* **Network Mode:** `service:gluetun` (Shares Gluetun's secure network namespace to encapsulate web indexer scraping requests)
* **Depends On:** `gluetun` (Enforces `condition: service_healthy` check before initialization)
* **Restart Policy:** `unless-stopped`

## Storage Footprint

All data for prowlarr will kept on fast storage.  By convention, it will be on `/srv/appdata` folder of the VM.

| Host Path | Container Target Path | Notes |
| :--- | :--- | :--- |
| `/srv/appdata/prowlarr` | `/config` | |

---

## Push-Sync Automation Architecture

```text
               ┌─── [Pushes Indexers Automatically] ───► Sonarr (Port 8989)
               ├─── [Pushes Indexers Automatically] ───► Radarr (Port 7878)
[ Prowlarr ] ──┼─── [Pushes Indexers Automatically] ───► Lidarr (Port 8686)
               └─── [Pushes Indexers Automatically] ───► Sonarr-Anime (Port 8990)
```
