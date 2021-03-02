# Bootstrap sw com

## Nginx scripts

**You need a trusted SSL cert, with SAN extension. The key and crt files must
reside in `web-server/` named `server.key` and `server.crt`, respectively.**

### `nginx-conf.sh`

Writes the `nginx.conf` to `web-server/` from the template there.

### `server.sh`

Runs Go upstream, github.com/shwoodard/sw, and nginx.

