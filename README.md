<p align="center">
<a href="https://hub.docker.com/r/domizhang/snell">
<img src="https://theme.zdassets.com/theme_assets/2123378/a7dc51ceadb6f150167ee53d78bc00408da16d4f.png" width="200px"/>
</a>
</p>

<h1 align="center">snell</h1>

<p align="center">an encrypted proxy service program.</p>

<p align=center>
<a href="https://hub.docker.com/r/domizhang/snell">Docker Hub</a> | 
<a href="https://manual.nssurge.com/others/snell.html">Project Source</a>
</p>

## latest version

|version|
|---|
|domizhang/snell:latest (5.0.0)|


## environment variables

|name|value|
|---|---|
|SERVER_HOST|0.0.0.0|
|SERVER_PORT|6333|
|PSK|PSK, Leave blank to automatically generate|
|IPV6|false / true|
|DNS|1.1.1.1, 8.8.8.8, 2001:4860:4860::8888|
|ARGS|-|

***

### Pull the image

```bash
$ docker pull domizhang/snell:latest
```

### Start a container

```bash
$ docker run -p 6333:6333 -p 6333:6333/udp -d \
  --restart always --name=snell domizhang/snell:latest
```

### Display config

```bash
$ docker logs snell

[snell-server]
listen = 0.0.0.0:6333
psk = 05d80656cd67e1bec62d3366c13e6f11
ipv6 = false
2025-08-12 20:13:13.673990 [server_main] <NOTIFY> snell-server v5.0.0 (Jul  7 2025 17:38:28)
2025-08-12 20:13:13.674400 [server_main] <NOTIFY> Effective IPv4 DNS: 8.8.8.8
2025-08-12 20:13:13.674413 [server_main] <NOTIFY> Effective IPv4 DNS: 8.8.4.4
2025-08-12 20:13:13.674565 [server_main] <NOTIFY> Start snell server on 0.0.0.0:6333
2025-08-12 20:13:13.674682 [server_main] <NOTIFY> TCP Fast Open enabled
2025-08-12 20:13:13.674730 [server_main] <NOTIFY> Start snell quic proxy server. Please confirm that both TCP and UDP inbound to port 6333 has been enabled.
```

Add a proxy line in Surge

```
[Proxy]
Proxy = snell, [SERVER_IP], [SERVER_PORT], psk=05d80656cd67e1bec62d3366c13e6f11, version=5
```
