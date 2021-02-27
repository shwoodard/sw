# Bootstrap sw com

## Nginx scripts

**You need a trusted SSL cert. The key and crt files must reside in
`web-server/` named `server.key` and `server.crt`, respectively.**

### `nginx.sh`

Generate `nginx.conf` from template and use it to run nginx.

### `nginx-conf.sh`

Writes the `nginx.conf` to `web-server/` from the template there.

### `nginx-run.sh`

Runs nginx with `nginx.conf` in `web-server/`.
