# tp1 cloud computing: Azure fist 

## Prérequis: 

https://cyber.gouv.fr/sites/default/files/2014/01/NT_OpenSSH.pdf

Ce Document dit que l'aglorithme ecdsa doit être préféré a rsa quand cela est possible.

https://www.ssldragon.com/fr/blog/ecdsa-vs-rsa/

cette page dis mot pour mot "Le principal avantage de l'ECDSA est l'efficacité de la clé. Une clé ECDSA de 256 bits offre une sécurité à peu près équivalente à une clé RSA de 3072 bits.".

Nous allons donc choisir pour une question de logique une clé ecdsa 

```bash
ssh-keygen -ted25519 -b 256
```

!!!! Azure ne prend cependant pas les cles ecdsa donc nous allons faire une cle ed25519

```bash
maybelater@debian:~/Documents/efrei/B2/cloud_computing$ ssh-keygen -ted25519 -b 256 -f ~/.ssh/tp_cloud
```

```bash
maybelater@debian:~/Documents/efrei/B2/cloud_computing$ ls ~/.ssh/
known_hosts  known_hosts.old  tp_cloud  tp_cloud.pub
```


### C. agent SSH

```bash
maybelater@debian:~/Documents/efrei/B2/cloud_computing$ ssh-add ~/.ssh/tp_cloud
Enter passphrase for /home/maybelater/.ssh/tp_cloud: 
Identity added: /home/maybelater/.ssh/tp_cloud (maybelater@debian)
```


### Depuis la webui

```bash
maybelater@debian:~$ ssh maybelater@51.103.122.207
The authenticity of host '51.103.122.207 (51.103.122.207)' can't be established.
ED25519 key fingerprint is SHA256:QZurEwRKDiINUvk/YEPGWrg6ybEB2tdIVDC5S0bNt4M.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '51.103.122.207' (ED25519) to the list of known hosts.
```

### 2. az a problematic aapproach


``` bash
export MY_RESOURCE_GROUP_NAME="td_leo1.2"
export REGION=francecentral
az group create --name $MY_RESOURCE_GROUP_NAME --location $REGION
```
```bash
maybelater@debian:~$ export MY_VM_NAME="azure1.tp1"
export MY_USERNAME=maybelater
export MY_VM_IMAGE=Ubuntu2204
az vm create \
  --resource-group $MY_RESOURCE_GROUP_NAME \
  --name $MY_VM_NAME \
  --image $MY_VM_IMAGE \
  --admin-username $MY_USERNAME \
  --assign-identity \
  --ssh-key-values ~/.ssh/tp_cloud.pub \
  --public-ip-sku Standard \
  --size Standard_B1s

```


```bash
ResourceGroup    PowerState    PublicIpAddress    Fqdns    PrivateIpAddress    MacAddress         Location
---------------  ------------  -----------------  -------  ------------------  -----------------  -------------
td_leo1.2        VM running    20.19.209.244               10.0.0.4            60-45-BD-1A-FE-A6  francecentral
```


```bash
maybelater@debian:~$ ssh maybelater@20.19.209.244
The authenticity of host '20.19.209.244 (20.19.209.244)' can't be established.
ED25519 key fingerprint is SHA256:eIaBymTuUxLPpoLKiWEmNbLIkxlooJnapnWHz4IPQ7Y.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '20.19.209.244' (ED25519) to the list of known hosts.
Welcome to Ubuntu 22.04.5 LTS (GNU/Linux 6.8.0-1041-azure x86_64)
```

🌞 Une fois connecté, prouvez la présence...
```bash
maybelater@azure1:~$ systemctl --type=service --state=active list-units | grep "walinuxagent"
  walinuxagent.service                                  loaded active running Azure Linux Agent

  
maybelater@azure1:~$ systemctl --type=service --state=active list-units | grep "cloud-init.service"
  cloud-init.service                                    loaded active exited  Cloud-init: Network Stage

```

🌞 Créez une deuxième VM : azure2.tp1

```bash
az vm create \
  --resource-group td_leo1.2 \
  --name azure2.tp1\
  --image ubuntu2204 \
  --admin-username maybelater \
  --assign-identity \
  --ssh-key-values ~/.ssh/tp_cloud.pub \
  --public-ip-address "" \
  --size Standard_B1s
```

🌞 Affichez des infos au sujet de vos deux VMs

```bash
maybelater@debian:~$ az vm list-ip-addresses
VirtualMachine    PublicIPAddresses    PrivateIPAddresses
----------------  -------------------  --------------------
azure1.tp1        51.103.65.53         172.16.0.5
azure2.tp1                             172.16.0.6
azure1.tp1.2      20.19.209.244        10.0.0.4
azure2.tp1.2                           10.0.0.6
```



🌞 Configuration SSH client pour les deux machines
```bash
maybelater@debian:~$ cat .ssh/config 
### Bastion
Host az1
Hostname 20.19.208.244
User maybelater
IdentityFile ~/.ssh/tp_cloud

### Cible
Host az2
Hostname 10.0.0.6
User maybelater
IdentityFile ~/.ssh/tp_cloud
ProxyJump az1
```

## III.Déployer et configurer un machin

🌞 Installer MySQL/MariaDB sur azure2.tp1
```bash
sudo apt install mariadb-server
```
🌞 Démarrer le service MySQL/MariaDB sur azure2.tp1

```bash
sudo systemctl start mariadb
sudo systemctl enable mariadb
```


```bash
maybelater@azure2:~$ sudo mysql
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 35
Server version: 10.6.22-MariaDB-0ubuntu0.22.04.1 Ubuntu 22.04

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> CREATE DATABASE meow_database;
Query OK, 1 row affected (0.000 sec)

MariaDB [(none)]> CREATE USER 'meow'@'%' IDENTIFIED BY 'meow';
Query OK, 0 rows affected (0.006 sec)

MariaDB [(none)]> GRANT ALL ON meow_database.* TO 'meow'@'%';
Query OK, 0 rows affected (0.004 sec)

MariaDB [(none)]> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.001 sec)
```


```bash
maybelater@azure2:~$ netstat -lntp
(Not all processes could be identified, non-owned process info
 will not be shown, you would have to be root to see it all.)
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 172.16.0.6:3306         0.0.0.0:*               LISTEN      -                   
tcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN      -                   
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      -                   
tcp6       0      0 :::22                   :::*                    LISTEN      -                   
```

ouvrir le port 3306 et modifier le fichier de conf de mariadb pourqu'il écoute sur son ip privé et pas en localhost.

```bash
sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf
maybelater@azure2:~$ sudo firewall-cmd --permanent --add-port=3306/tcp
``` 

```bash
maybelater@azure1:~$ sudo chown -R webapp /opt/meow/app/
maybelater@azure1:~$ ls -l /opt/meow/app/
total 12
-rw-rw-r-- 1 webapp maybelater 3827 Oct 29 11:49 app.py
-rw-rw-r-- 1 webapp maybelater 1403 Oct 29 11:36 requirements.txt
drwxrwxr-x 2 webapp maybelater 4096 Oct 29 11:30 templates
maybelater@azure1:~$ sudo chown -R webapp:webapp /opt/meow/app/
maybelater@azure1:~$ ls -l /opt/meow/app/
total 12
-rw-rw-r-- 1 webapp webapp 3827 Oct 29 11:49 app.py
-rw-rw-r-- 1 webapp webapp 1403 Oct 29 11:36 requirements.txt
drwxrwxr-x 2 webapp webapp 4096 Oct 29 11:30 templates
maybelater@azure1:~$ ls -l /opt/meow/
total 20
drwxrwxr-x 3 webapp webapp 4096 Oct 29 11:49 app
drwxr-xr-x 2 root   root   4096 Oct 29 11:21 bin
drwxr-xr-x 2 root   root   4096 Oct 29 11:21 include
drwxr-xr-x 3 root   root   4096 Oct 29 11:21 lib
lrwxrwxrwx 1 root   root      3 Oct 29 11:21 lib64 -> lib
-rw-r--r-- 1 root   root     71 Oct 29 11:21 pyvenv.cfg
```


```bash
maybelater@azure1:~$ sudo chmod -R 750 /opt/meow/app/
```


```bash
(app) maybelater@azure1:/opt/app$ sudo ls -l
total 28
-rwxr-x--- 1 webapp webapp 3827 Oct 29 18:05 app.py
drwxr-x--- 2 webapp webapp 4096 Oct 29 18:09 bin
drwxr-x--- 3 webapp webapp 4096 Oct 29 18:09 include
drwxr-x--- 3 webapp webapp 4096 Oct 29 18:06 lib
lrwxrwxrwx 1 webapp webapp    3 Oct 29 18:06 lib64 -> lib
-rwxr-x--- 1 webapp webapp   71 Oct 29 18:07 pyvenv.cfg
-rwxr-x--- 1 webapp webapp   58 Oct 29 18:05 requirements.txt
drwxr-x--- 2 webapp webapp 4096 Oct 29 18:05 templates
```


```bash
(app) maybelater@azure1:/opt/app$ sudo firewall-cmd --permanent --add-port=3306/tcp
success
```


```bash
maybelater@debian:~$ curl http://20.19.209.244:8000/
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