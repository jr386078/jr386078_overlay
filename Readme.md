# jr386078_overlay

## Short instruction

Create file:

    nano -w /etc/portage/repos.conf/jr386078_overlay.conf

Copy and paste:

```
[jr386078_overlay]

location = /usr/local/portage/jr386078_overlay
sync-type = git
sync-uri = https://github.com/jr386078/jr386078_overlay.git
priority = 50
auto-sync = yes
```

Sync repository:

    emaint sync --repo jr386078_overlay
