# Olympus

I decided on a naming convention where places will mean physical hosts and persons/heroes/gods will be the VMs living or hosted in it.  Olympus is my first node in this homelab of mine.

I actually forgot how much I got it for.  I think it was around 500 aud.  It may not be a huge steal, but I liked the power it had.  Spent a lot of time reading up on what a good baseline spec for a homelab should be and had to learn how to read those intel model names and know their generations.  It was easy enough to know.  I still get lost with AMD and since I'm more familiar with intel, it was easier to skim through FB listings.

It initially came with 16 GB ram.  Before the RAM-pocalypse, I managed to buy a 2x16 GB kit from Amazon and upgraded its memory.  For around 120 AUD.  Man, I miss those days.

## Details

### Specs 

| Model | CPU | Memory | Storage (SSD) | Storage (SATA) |
| :--- | :--- | :--- | :--- | :--- |
| HP Elitedesk 800 G6 SFF | Intel i7-10700 (8C/16T) | 32 GB | 1 TB NVMe | 2 x 8TB (WD Reds) |

### OS

I chose Proxmox VE as my hypervisor.  Because of a YT video that showed me step by step instructions on how to set it up.  Yep, its as simple as that.

There were some stability issues encountered when I initially spun up my services.  Some eventually got attributed to a memory mismatch as I initially ran with 48 GB and it looks like there may be some mismatch on the RAM sticks causing my server to randomly crash every now and then.  When I removed the old 16GB card and just used my 2x16 GB RAMs, things stabilised a bit.  

With the help of AI, I came upon some more tuning on the configuration.  I used to turn off iGPU passthrough as that affected stability.  But with the other stability fixes that I put, things got a bit better that I decided to turn it back on. 

| Infrastructure Tuning Category | Targeted Configuration File Path | Exact Operational Value Set | Primary Architectural Purpose & Impact |
| :--- | :--- | :--- | :--- |
| Network Interface Buffer Tuning | `/etc/network/interfaces` | `rx 4096 tx 4096` | Applied directly to physical interface `eno1` under bridge `vmbr0` to maximize hardware-level ring buffers, entirely preventing packet drops during high-throughput ingestion spikes |
| Network Offloading Deactivation | `/etc/network/interfaces` | `tso off gso off gro off` | Explicitly deactivates TCP Segmentation Offloading, Generic Segmentation Offloading, and Generic Receive Offloading to completely bypass buggy hardware interface firmware and prevent link freezes. |
| iGPU Compute Passthrough | `/etc/pve/qemu-server/102.conf` | `hostpci0: 0000:00:02`[cite: 6] | Maps the physical Intel UHD 630 Graphics core directly to the guest virtualization layer, exposing the computational rendering nodes cleanly at `/dev/dri/renderD128`. |

### Networking

I used a static IPs within my local network to help facilitate configuring the different services that I will be hosting.  As a security precaution, may not be worth adding those network IP address details to this document.  

I want to expand this section later when I eventually get to segment my network and implement VLANs

### Storage setup

I chose ZFS for my filesystem as resiliency is a concern.  I am using primarily second hand components so drive failure is a question of when and not if.  

I liked how I can setup a pool in ZFS and have a RAID setup where I can tolerate drive failures.  For now, I can only fit in 2 drives in my machine so its in mirror mode.  

I also chose to use ZFS for my SSD not for the resiliency,but for the additional features it gives me. 


| ZFS Pool Identifier | Underlying Physical Hard Drives | Array Topology Type | Logical Dataset Pathway | Dataset Mount Point Location | Configured ZFS Properties | Role |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| rpool | 1 TB SSD | Single Disk Non-Redundant Volume | `rpool/local-zfs` | `/` | `compression=lz4`<br>`atime=off`<br>`recordsize=128K` | House hypervisor, host configuration tools, and fast storage for the different VMs |
| tank | 2 x 8 TB WD Reds | Mirror-0 Dual-Drive Redundant Array | `tank/data` | `/tank/data` | `compression=lz4`<br>`atime=off`<br>`recordsize=128K` | Centralized high-capacity storage. |