# udp2raw-server-docker-nonroot
Non-root `udp2raw` server in Docker.

Other Docker recipes I found use `network=host` and `root` user, which I wanted to avoid.

## Key points:
- Small Alpine image (~35 MB)
- Uses _normal_ Docker networking, i.e. `bridge` instead of `host`
- `udp2raw` is executed as a non-root user (via `su-exec`)

## How to use:
1. Clone this repository.
2. Edit parameters in `.env` file
   At the least, UDP2RAW_KEY must be defined.
   Parameters:
   - UDP2RAW_KEY:             used for authentication between server and client (`-k` parameter); `compose` throws an error if left undefined
   - UDP2RAW_PORT_IN:         published port at which udp2raw can be accessed externally; defaults to 41820
   - UDP2RAW_PORT_OUT:        port on host that udp2raw targets (`-r` parameter); defaults to Wireguard's 51820
   - UDP2RAW_USER:            udp2raw user id:group; defaults to "2000:2000"
3. (Optional) Edit udp2raw command line in `compose.yml`, e.g. raw-mode, cipher-mode and auth-mode.
   Current defaults are: faketcp / xor / md5, as my 1-core VPS cannot cope with much more and obfuscation isn't my main goal.
4. (Necessary if using firewall on host) Allow incoming connection from container to host on UDP2RAW_PORT_OUT.
5. `docker compose up -d`
6. set up client to connect to container's UDP2RAW_PORT_IN with same parameters

## Technical details:
- Uses alpine:latest, may want to pin that if you need consistency
- Uses latest udp2raw source, again, you may want to pin that
- udp2raw receives NET_RAW capability to work as non-root
- Container gets NET_ADMIN to be able to update iptables rules
- su-exec is used to downgrade to non-root

## Notes:
- No udp2raw client recipe
- When used with Wireguard, the overhead added by udp2raw can be significant on a weak system, even with `cipher-mode none` and `auth-mode none`.
