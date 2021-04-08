# torrserver
### Unofficial Docker Image for TorrServer

This is unofficial dockerized precompiled TorrServer. (~30MB)

"TorrServer, stream torrent to http"

More info:
- https://github.com/YouROK/TorrServer
- https://4pda.ru/forum/index.php?showtopic=889960

### Requirements

* docker
* ~200 Mb RAM(caching)

### Installing

- сreate "~/torrserver/db" directory (for example) on your host
```
docker run -d --name=torrservermatrix --restart=always -v ~/torrserver/db:/torrserver/db -v /etc/localtime:/etc/localtime:ro -p 8090:8090 solopasha/torrserver
>>>>>>> d77af2032d661d2397d0844e1995362eef7861fd
```
