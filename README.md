# torrserver

Version 97a23caf56024e854bce3a63848d1d9d3a57c324

## Unofficial Docker Image for TorrServer

"TorrServer, stream torrent to http"

More info:

- <https://github.com/YouROK/TorrServer>
- <https://4pda.ru/forum/index.php?showtopic=889960>

### Requirements

- docker
- ~200 Mb RAM for caching (tunable)

### Installing

```shell
mkdir -p ~/torrserver/db
docker run -d --name=torrservermatrix \
            --restart=unless-stopped \
            -e PUID=1000 \
            -e PGID=1000 \
            -e TZ=Etc/UTC \
            -v ~/torrserver/db:/torrserver/db \
            -p 8090:8090 solopasha/torrserver
```

*Optional:*
For DLNA and UPnP port forwarding you need ``` --net=host ```

## Parameters

Container image is configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8090:8090` would expose port `8090` from inside the container to be accessible from the host's IP on port `8090` outside the container.

| Parameter | Function |
| :----: | --- |
| `-p 8090` | The port for the Torrserver webinterface |
| `-e PUID=1000` | for UserID - see below for explanation |
| `-e PGID=1000` | for GroupID - see below for explanation |
| `-e TZ=Etc/UTC` | specify a timezone to use, see this [list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List). |
| `-e TS_HTTPAUTH=1` | http auth on all requests, see this [Authorization](https://github.com/YouROK/TorrServer#authorization). |
| `-e TS_RDB=1` | start in a read-only DB mode. |
| `-e TS_DONTKILL=1` | don't kill server on signal. |

### Usage

Open ```localhost:8090``` in your browser. Enjoy!

Useful browser extension:
[TorrServer Adder(firefox)](https://addons.mozilla.org/en-US/firefox/addon/torrserver-adder/)
[TorrServer Adder(chrome)](https://chrome.google.com/webstore/detail/torrserver-adder/ihphookhabmjbgccflngglmidjloeefg?hl=en)

Torrent files(*.torrent*), placed in ~/torrserver/db will be added to torrserver automatically.

## User / Group Identifiers

When using volumes (`-v` flags) permissions issues can arise between the host OS and the container, we avoid this issue by allowing you to specify the user `PUID` and group `PGID`.

Ensure any volume directories on the host are owned by the same user you specify and any permissions issues will vanish like magic.

In this instance `PUID=1000` and `PGID=1000`, to find yours use `id user` as below:

```bash
  $ id username
    uid=1000(dockeruser) gid=1000(dockergroup) groups=1000(dockergroup)
```
