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
|domizhang/snell:latest (4.0.1)|


## environment variables

|name|value|
|---|---|
|SERVER_HOST|0.0.0.0|
|SERVER_PORT|8888|
|PSK|PSK, Leave blank to automatically generate|
|IPV6|false / true|
|ARGS|-|

***

### Pull the image

```bash
$ docker pull domizhang/snell:latest
```

### Start a container

```bash
$ docker run -p 8888:8888 -p 8888:8888/udp -d \
  --restart always --name=snell domizhang/snell:latest
```

### Display config

```bash
$ docker logs snell

[snell-server]
listen = 0.0.0.0:8888
psk = 05d80656cd67e1bec62d3366c13e6f11
ipv6 = false
2022-11-02 13:48:38.889197 [server_main] <NOTIFY> snell-server v4.0.0 (Nov  1 2022 20:07:09)
2022-11-02 13:48:38.889494 [server_main] <NOTIFY> Start snell server on 0.0.0.0:8888
2022-11-02 13:48:38.889580 [server_main] <NOTIFY> TCP Fast Open enabled
```

Add a proxy line in Surge

```
[Proxy]
Proxy = snell, [SERVER_IP], [SERVER_PORT], psk=05d80656cd67e1bec62d3366c13e6f11, version=4
```
