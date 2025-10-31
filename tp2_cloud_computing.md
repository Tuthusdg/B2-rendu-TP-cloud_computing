# TP2

## I. Un p'tit nom DNS

```bash
maybelater@debian:~$ az network public-ip update   --resource-group td_leo1.2   --name azure1.tp1.2PublicIP   --dns-name "az1meow"
maybelater@debian:~$ curl http://az1meow.francecentral.cloudapp.azure.com:8000/
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Purr Messages - Cat Message Board</title>
    <style>
        /* Modern CSS with cat-themed design */
        :root {

```
## II. cloud-init


```bash
az vm create   --resource-group td_leo1.2   --name azure3.tp1.2  --image ubuntu2204  --assign-identity   --ssh-key-values ~/.ssh/tp_cloud.pub   --public-ip-address ""   --size Standard_B1s --custom-data cloud-init.txt
```

```bash
maybelater@azure3:~$ sudo systemctl status cloud-init
● cloud-init.service - Cloud-init: Network Stage
     Loaded: loaded (/lib/systemd/system/cloud-init.service; enabled; vendor preset: enabled)
     Active: active (exited) since Fri 2025-10-31 07:16:19 UTC; 2min 40s ago
   Main PID: 498 (code=exited, status=0/SUCCESS)
        CPU: 1.452s

Oct 31 07:16:19 azure3 cloud-init[502]: |       .   .     |
Oct 31 07:16:19 azure3 cloud-init[502]: |      . . o      |
Oct 31 07:16:19 azure3 cloud-init[502]: |     . . =. o    |
Oct 31 07:16:19 azure3 cloud-init[502]: |    . o S .+ o   |
Oct 31 07:16:19 azure3 cloud-init[502]: |     * =ooo +    |
Oct 31 07:16:19 azure3 cloud-init[502]: |    o O.=B =     |
Oct 31 07:16:19 azure3 cloud-init[502]: |     . OO*E      |
Oct 31 07:16:19 azure3 cloud-init[502]: |      .+X#B.     |
Oct 31 07:16:19 azure3 cloud-init[502]: +----[SHA256]-----+
Oct 31 07:16:19 azure3 systemd[1]: Finished Cloud-init: Network Stage.
maybelater@azure3:~$ cloud-init status
status: done
maybelater@azure3:~$ ls -al /var/log/cloud-init*
-rw-r----- 1 root   adm   4410 Oct 31 07:16 /var/log/cloud-init-output.log
-rw-r----- 1 syslog adm 137815 Oct 31 07:16 /var/log/cloud-init.log
```


```bash
maybelater@azure1:~$ sudo ls -l /usr/local/bin/get_secrets.sh 
-rwxr-x--- 1 webapp maybelater 293 Oct 30 14:28 /usr/local/bin/get_secrets.sh
maybelater@azure1:~$ sudo chown webapp:webapp /usr/local/bin/get_secrets.sh 
maybelater@azure1:~$ sudo ls -l /usr/local/bin/get_secrets.sh 
-rwxr-x--- 1 webapp webapp 293 Oct 30 14:28 /usr/local/bin/get_secrets.sh
```
```bash
maybelater@azure3:~$ sudo mysql -e "SHOW DATABASES LIKE 'meow_database';"
+--------------------------+
| Database (meow_database) |
+--------------------------+
| meow_database            |
+--------------------------+
```
```bash
#cloud-config
disable_root: false
system_info:
  default_user:
    name: maybelater

users:
  - name: maybelater
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: sudo
    shell: /bin/bash
    ssh_authorized_keys:
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAYSk2iQxLueLP6RQ1Wm7yn3C74j+h555m6aYv37AkuJ
    lock_passwd: false
    plaint_text_passwd: hello

  - name: maybe
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: sudo
    shell: /bin/bash
    ssh_authorized_keys:
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAYSk2iQxLueLP6RQ1Wm7yn3C74j+h555m6aYv37AkuJ
    lock_passwd: false
    plaint_text_passwd: bonjour

package_update: true
packages:
  - mysql-server

write_files:
  - path: /tmp/init.sql
    content: |
      CREATE DATABASE meow_database;
      CREATE USER 'meow'@'%' IDENTIFIED WITH mysql_native_password BY 'meow';
      GRANT ALL ON meow_database.* TO 'meow'@'%';
      FLUSH PRIVILEGES;

runcmd:
  - systemctl enable --now mysql
  - 'while ! mysqladmin ping --silent; do sleep 1; done'
  - sudo mysql < /tmp/init.sql
```

```bash

maybelater@azure1:~$ sudo cat /opt/app/.env
# Flask Configuration
FLASK_SECRET_KEY=
FLASK_DEBUG=False
FLASK_HOST=0.0.0.0
FLASK_PORT=8000

# Database Configuration
DB_HOST=10.0.0.6
DB_PORT=3306
DB_NAME=meow_database
DB_USER=meow
DB_PASSWORD=meow
maybelater@azure1:~$ sudo systemctl restart webapp.service 
maybelater@azure1:~$ sudo cat /opt/app/.env
# Flask Configuration
FLASK_SECRET_KEY=ewnFw95H7qBeGiVvkQl9YmnJohW6Netpareilcbonilyestaussi
FLASK_DEBUG=False
FLASK_HOST=0.0.0.0
FLASK_PORT=8000

# Database Configuration
DB_HOST=10.0.0.6
DB_PORT=3306
DB_NAME=meow_database
DB_USER=meow
DB_PASSWORD=lui il y est
```

```bash
az storage account create --name storagecloudtp2 --resource-group td_leo1.2 --location francecentral 
```

```bash
az storage container create --account-name storagecloudtp2 --name tp2 --auth-mode login
```

```bash
az vm identity assign \
  --name azure2.tp1.2 \
  --resource-group td_leo1.2
az vm show \
  --name azure2.tp1.2 \
  --resource-group td_leo1.2 \
  --query "identity.principalId" \
  --output tsv
```

```bash
az role assignment create 
         --role "Storage Blob Data Contributor" 
         --assignee-object-id "bc94a5d2-2498-459a-8e92-ee09e4027398" 
         --scope "/subscriptions/bb6fbecb-87ee-4cd4-a595-0506b2542a43/resourceGroups/td_leo1.2/providers/Microsoft.Storage/storageAccounts/storagecloudtp2"
```

```bash
maybelater@debian:~$ az storage blob download \
    --account-name storagecloudtp2 \
    --container-name tp2 \
    --name meow.txt \
    --file "/tmp/meow_recupere.txt" \
    --auth-mode login
```


```bash
maybelater@azure2:~$ sudo systemctl status azbackup.service
○ azbackup.service - Sauvegarde MySQL et upload vers Azure Blob
     Loaded: loaded (/etc/systemd/system/azbackup.service; enabled; vendor preset: enabled)
     Active: inactive (dead) since Thu 2025-10-30 18:11:42 UTC; 9s ago
    Process: 8360 ExecStart=/usr/local/bin/backup.sh (code=exited, status=0/SUCCESS)
   Main PID: 8360 (code=exited, status=0/SUCCESS)
        CPU: 2.318s

Oct 30 18:11:40 azure2 systemd[1]: Starting Sauvegarde MySQL et upload vers Azure Blob...
Oct 30 18:11:42 azure2 systemd[1]: azbackup.service: Deactivated successfully.
Oct 30 18:11:42 azure2 systemd[1]: Finished Sauvegarde MySQL et upload vers Azure Blob.
Oct 30 18:11:42 azure2 systemd[1]: azbackup.service: Consumed 2.318s CPU time. 
```


```bash
maybelater@azure2:~$ sudo systemctl list-timers 
NEXT                        LEFT               LAST                        PASSED       UNIT                           ACTIVATES                       
Thu 2025-10-30 18:30:00 UTC 7min left          Thu 2025-10-30 18:20:18 UTC 2min 18s ago sysstat-collect.timer          sysstat-collect.service
Fri 2025-10-31 00:00:00 UTC 5h 37min left      n/a                         n/a          azbackup.timer                 azbackup.service
Fri 2025-10-31 00:00:00 UTC 5h 37min left      Thu 2025-10-30 00:00:13 UTC 18h ago      dpkg-db-backup.timer           dpkg-db-backup.service
Fri 2025-10-31 00:00:00 UTC 5h 37min left      Thu 2025-10-30 00:00:13 UTC 18h ago      logrotate.timer                logrotate.service
Fri 2025-10-31 00:07:00 UTC 5h 44min left      Thu 2025-10-30 00:07:28 UTC 18h ago      sysstat-summary.timer          sysstat-summary.service
Fri 2025-10-31 04:43:08 UTC 10h left           Thu 2025-10-30 12:05:18 UTC 6h ago       motd-news.timer                motd-news.service
Fri 2025-10-31 04:49:32 UTC 10h left           Thu 2025-10-30 16:12:13 UTC 2h 10min ago apt-daily.timer                apt-daily.service
Fri 2025-10-31 06:15:03 UTC 11h left           Thu 2025-10-30 06:41:28 UTC 11h ago      apt-daily-upgrade.timer        apt-daily-upgrade.service
Fri 2025-10-31 08:54:04 UTC 14h left           Thu 2025-10-30 04:21:28 UTC 14h ago      man-db.timer                   man-db.service
Fri 2025-10-31 17:50:18 UTC 23h left           Thu 2025-10-30 17:50:18 UTC 32min ago    update-notifier-download.timer update-notifier-download.service
Fri 2025-10-31 17:58:33 UTC 23h left     
```