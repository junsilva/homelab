# Gluetun

Maintaining and ensuring privacy is a concern for me.  I decided to use [Gluetun](https://github.com/passteque/gluetun) to help keep my *Arr stack wired to a VPN instead of individually setting them up.  It worked quite nicely and am happy with the setup.

## Setup

### Execution Parameters
* **Container Name:** `gluetun`
* **Base Image:** `qmcgaw/gluetun:latest`
* **Local Storage:** `/srv/appdata/gluetun` 
* **Assigned Subnet IP:** `172.39.0.2` (Statically bound within the custom `servarrnetwork` bridge pool)

### Required Linux Privileges
To handle kernel-level routing tables, TUN interface creation, and stateful packet manipulation inside the guest Linux kernel, the container requires explicit host capability escalations:
* `cap_add: - NET_ADMIN`
* `devices: - /dev/net/tun:/dev/net/tun`

## Port Management & Downstream Exposure

I have put `qbittorrent`, `nzbget`, `prowlarr` and `flaresolverr` behind gluetun and ensure my traffic is not exposed.  

| External Port Mapping | Internal Target Service | Notes |
| :--- | :--- | :--- |
| `${QBITTORRENT_PORT}:${QBITTORRENT_PORT}` | `qbittorrent` |  |
| `${NZBGET_PORT}:${NZBGET_PORT}` | `nzbget` |  |
| `${PROWLARR_PORT}:${PROWLARR_PORT}` | `prowlarr` |  |
| `${FLARESOLVERR_PORT}:${FLARESOLVERR_PORT}` | `flaresolverr` | |

## Dynamic Ports

I didn't want to manually update config files whenever ProtonVPN changes ports when I restart my stack.  This hook helps ensure things will still wire up nicely after a restart.

```yaml
environment:
  - VPN_PORT_FORWARDING=on
  - PORT_FORWARD_ONLY=on
  - VPN_PORT_FORWARDING_UP_COMMAND=/bin/sh -c 'wget -O- --retry-connrefused --post-data "json={\"listen_port\":{{PORTS}}}" [http://127.0.0.1](http://127.0.0.1):${QBITTORRENT_PORT}/api/v2/app/setPreferences 2>&1'
```