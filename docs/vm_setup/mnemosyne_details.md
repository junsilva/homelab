# Mnemosyne

I wanted a name related to memory and settled on this one.  I used this name before for my external HDD several years back.  

Eventually, this layer would be spun out into an actual physical NAS node.   But while I don't have the budget, I will just have to settle on an LXC and exposing folders via network shares.

I use a lot of refurbished drives as cost and value is a big concern.  To mitigate the risk of disk failure, I initially went with ZFS and target at least tolerating 2 disk failures.  With just 2 drives, I'll just do mirror setup for now.  

I have since learned about Unraid, and like its support for incremental growth.  With ZFS and ZFS pools, adding 1 or 2 drives to the pool will be time consuming and painful, unlike Unraid.  There is the matter of cost as Unraid doesn't come free.  But something to consider for next time.

---

## Folders

The storage layer will be shared by myself and hosted services.  

`shared` and `users` folder will host those personal files.  I wanted a shared location where we can share documents and a separate private folder for our personal files.  When Lakan grows up, I'll add another folder for his space.

`torrents`, `usenet` and `media` folders are for my Arr stack.  Right now, I'm heavily using torrents and haven't setup my usenet downloaders yet.  I would like to explore it sometime, but usenet requires memberships that I'm not willing to pay yet.  Maybe when I have more storage capacity and am looking for more rare files, I'll consider it.  For now, the folder acts as a stub and a reminder for me to set it up later.

`photos` is a separate folder for my Immich service.  

```text
/data/                                 
├── shared/                            # Family Network Share
├── users/                             # Individual Private network shares
│   ├── jun/                           
│   └── sarah/                         
├── media/                             # Media files
│   ├── movies/                        
│   ├── tv/                           
│   ├── music/                         
│   └── books/                         
│       ├── audiobooks/                
│       ├── ebooks/                    
│       ├── manga/                    
│       └── comics/                    
├── photos/                            # Photo share for Immich
├── torrents/                          # Torrents downloader dump
│   ├── incomplete/                    
│   └── complete/                      
└── usenet/                            # Usenet downloader dump
    ├── intermediate/                  
    └── completed/                     
```

## Users and Groups

I wanted to control access to my network shares and didn't want to grant full read access to the different folders.  User setup and management is still not centralized/managed.  Would need to research more on how to simplify this.

I also realised that one of the workarounds I used has caused some setup issues...  

I mounted the whole root folder `/data` to both my VMs as I wanted to ensure that services between `apollo` and `dionysus` will have access to the same paths and would hopefully make the configuration a bit more standard and easier to manage across the two VMs.  The problem is, `/data` also had the folders for the personal documents:  `shared` and `users`.  Trying to mount it then resulted in some errors in fstab on my VMs.  I worked around it by setting the `shared` and `users` folders to have group `users`, but the members of the `users` group is the service accounts.  Effectively giving read access to my service users to those personal documents.  

Now what?  For now, I'll live with this setup.  But I would need to fix this up.  One possible thing I can see is to add another layer inside `/data`.  Perhaps a `service` and `personal` subfolders to segregate folders.  That way, my VMs can just mount `service` instead of the whole `data` root folder.  But will have to read up on it and decide later.

### Account setup 
| Account Name | Numeric User Identifier (UID) | Group Assignment | Comment |
| :--- | :---: | :--- | :--- |
| jun_admin | `1000` | `1000` | Administrator |
| jun | `1001` | `1001` | Personal user account |
| sarah | `1002` | `1002` | Personal user account |
| apollo | `1003` | `1003` | Service account for `apollo` vm |
| dionysus | `1004` | `1004` | Service account for `dionysus` vm |

| Group Name | ID | Comment |
| :--- | :---: | :--- |
| admin | `1000` |  |
| media | `1101` | group for sharing access to media folders  |
| users | `100` | workaround for avoiding mount error.  grant read access to service accounts to `shared` and `users` folders |

### Permissions

| Targeted Linux System File Path | Owner User Identifier | Group Group Identifier | Numerical Permissions | Directory Inheritance Type |
| --- | --- | --- | --- | --- |
| `/data` | `100000` | `100000` | `0755` | Standard Root Inheritance |
| `/data/shared` | `1000` | `1101` | `2775` | **setgid** Bit Active | 
| `/data/users` | `101000` | `101101` | `0755` | Standard Directory Inheritance |
| `/data/users/jun` | `1001` | `100` | `0770` | Isolated User Flag | 
| `/data/users/sarah` | `1002` | `100` | `0770` | Isolated User Flag | 
| `/data/media` | `1000` | `1101` | `2775` | **setgid** Bit Active | 
| `/data/media/movies` | `1000` | `1101` | `2775` | **setgid** Bit Active | 
| `/data/media/tv` | `1000` | `1101` | `2775` | **setgid** Bit Active |  
| `/data/media/music` | `1000` | `1101` | `2775` | **setgid** Bit Active |  
| `/data/media/books` | `1000` | `1101` | `2775` | **setgid** Bit Active | 
| `/data/media/books/audiobooks` | `1000` | `1101` | `2775` | **setgid** Bit Active |  
| `/data/media/books/ebooks` | `1000` | `1101` | `2775` | **setgid** Bit Active | 
| `/data/media/books/manga` | `1000` | `1101` | `2775` | **setgid** Bit Active | 
| `/data/media/books/comics` | `1000` | `1101` | `2775` | **setgid** Bit Active |
| `/data/photos` | `1004` | `1101` | `2775` | **setgid** Bit Active |
| `/data/torrents` | `1003` | `1101` | `2775` | **setgid** Bit Active |
| `/data/torrents/incomplete` | `1003` | `1101` | `2775` | **setgid** Bit Active |
| `/data/torrents/complete` | `1003` | `1101` | `2775` | **setgid** Bit Active |
| `/data/usenet` | `1003` | `1101` | `2775` | **setgid** Bit Active |
| `/data/usenet/intermediate` | `1003` | `1101` | `2775` | **setgid** Bit Active |
| `/data/usenet/completed` | `1003` | `1101` | `2775` | **setgid** Bit Active |