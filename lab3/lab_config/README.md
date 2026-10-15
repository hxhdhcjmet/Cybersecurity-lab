# Generated topology

Run `docker compose up --build -d` in this directory.
When replacing an existing generated topology, run `docker compose down` first so Docker recreates the networks with the current driver options.
Use `docker compose ps` to inspect containers and `docker compose down` to stop them.

## Nodes

- `client-1`: attacker (client); container=`attacker`, hostname=`attacker`
- `router-1`: router (router); container=`router`, hostname=`router`
- `server-1`: server (server); container=`server`, hostname=`server`
- `switch-1`: 交换机 1 (switch)（Docker bridge 虚拟二层交换机，不创建容器）
- `client-2`: server2 (server); container=`server2`, hostname=`server2`
- `client-3`: server3 (server); container=`server3`, hostname=`server3`
- `client-4`: server1 (server); container=`server1`, hostname=`server1`
- `client-5`: user (client，GUI); container=`user`, hostname=`user`
- `server-2`: server0 (server); container=`server0`, hostname=`server0`

Every physical node container runs with `privileged: true`, allowing full container capabilities and device access for lab modifications. Switch nodes are Docker bridges and do not create containers.
Changes made only inside a running container are lost when that container is rebuilt; put persistent changes in its Dockerfile or a mounted volume.
Client/server images include Bash and common Linux tools such as ping, SSH, Telnet, FTP and netcat (`nc`); interactive Bash displays `root@hostname:~#`. Enter non-GUI containers with `docker exec -it <container-name> bash`.
Every server node runs Apache HTTP Server on container port 80; access it from the topology with `http://<server-ip>/`. Apache's document root is `/var/www/html`.
Every server also runs OpenSSH on port 22, BusyBox Telnet on port 23 and vsftpd on port 21. Sign in as `lab` with `SERVER_PASSWORD` from `.env`. FTP passive mode uses ports 30000–30009 inside the topology network.
For DNS-safe ASCII node names, the hostname matches the visible name; names containing Chinese, spaces or invalid hostname characters use the node ID as hostname. The container name uses the visible node name where Docker-safe; invalid characters are replaced by hyphens and names consisting entirely of non-ASCII characters fall back to the node ID. The original visible name is kept in the `topology.name` label.
OpenWrt router images retain the shells supplied by their rootfs (usually `sh`).

## Layer-2 networks

Each switch-connected domain (including interconnected switches) maps to one Docker bridge.
IP masquerading is disabled on every generated bridge, so packets leaving a bridge retain the container source address; external networks need an explicit return route.
All attached physical containers share the same subnet and can communicate without a router.
Switch ports have no IP or MAC; the bridge's first host IP is reserved for the Docker gateway.

- `net_link_link-1` `192.168.2.0/24`: client-1=192.168.2.100, router-1=192.168.2.10
- `net_sw_switch-1` `192.168.4.0/24`: router-1=192.168.4.10, client-4=192.168.4.61, server-1=192.168.4.105, client-2=192.168.4.67, client-3=192.168.4.68, server-2=192.168.4.106
- `net_link_link-7` `192.168.3.0/24`: router-1=192.168.3.10, client-5=192.168.3.100

## Links

- `client-1` ↔ `router-1`: `192.168.2.0/24`; 192.168.2.100 / 192.168.2.10
- `router-1` ↔ `switch-1`: `192.168.4.0/24`; 192.168.4.10 / switch port
- `switch-1` ↔ `client-4`: `192.168.4.0/24`; switch port / 192.168.4.61
- `server-1` ↔ `switch-1`: `192.168.4.0/24`; 192.168.4.105 / switch port
- `switch-1` ↔ `client-2`: `192.168.4.0/24`; switch port / 192.168.4.67
- `switch-1` ↔ `client-3`: `192.168.4.0/24`; switch port / 192.168.4.68
- `router-1` ↔ `client-5`: `192.168.3.0/24`; 192.168.3.10 / 192.168.3.100
- `switch-1` ↔ `server-2`: `192.168.4.0/24`; switch port / 192.168.4.106

## GUI access

Open the following local HTTPS URLs after starting Compose. Sign in as `kasm_user`; the password is `VNC_PW` in `.env`.

- `client-5`: https://localhost:6901

GUI containers use Kasm's standalone desktop image and need Docker Compose with `post_start` support (v2.30+).
They include ping, ip, curl, wget, SSH, Telnet, FTP, netcat (`nc`), traceroute, tcpdump, nmap and common terminal editors.
The web sign-in name is `kasm_user`; the Linux desktop account is `kasm-user`. Run `sudo -i` in the desktop terminal for a passwordless root shell inside the container.
The GUI server also runs Apache, OpenSSH, Telnet and vsftpd.

## Server access

All server nodes share the Linux username `lab` and the generated `SERVER_PASSWORD` stored in `.env`.

- SSH: `ssh lab@<server-ip>` (port 22)
- Telnet: `telnet <server-ip> 23`
- FTP: `ftp <server-ip>` (port 21; passive ports 30000–30009)
- HTTP: `http://<server-ip>/` (port 80)

## Router image

Router Dockerfiles unpack the bundled OpenWrt ARM64 rootfs. Run on ARM64 or a Docker host with ARM64 emulation.

## Traffic mirroring

Each configured OpenWrt router uses nftables to duplicate IPv4 packets in both directions between the selected endpoints. The receiver must be directly connected to that router; mirrored packets keep their original IP headers, so inspect them with tcpdump rather than expecting an application on the receiver to accept them.

- `router-1`: `server-1` ↔ `client-5` → `client-1`; capture with `docker exec -it attacker tcpdump -ni any`.
Inspect rule counters on a router with `docker exec -it <router-container> nft list table ip topology_mirror_<router-id-with-underscores>`.
