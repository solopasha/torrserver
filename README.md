# torrserver

Version MatriX.118

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
docker run -d --name=torrservermatrix --restart=unless-stopped -v ~/torrserver/db:/torrserver/db -v /etc/localtime:/etc/localtime:ro -p 8090:8090 solopasha/torrserver
```

*Optional:*
For DLNA and UPnP port forwarding you need ``` --net=host ```

### Usage

Open ```localhost:8090``` in your browser. Enjoy!

Torrent files(*.torrent*), placed in ~/torrserver/db will be added to torrserver automatically.
