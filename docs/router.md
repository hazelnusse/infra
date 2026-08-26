# Router (ASUS RT-AX88U, Asuswrt-Merlin)

Not managed by this repo — the router's own settings live only on the
device itself, not as declarative config here. This doc exists so the
non-default settings (and why they're set that way) survive a factory
reset or a bad firmware update without having to be rediscovered from
scratch.

LAN: `192.168.50.0/24`, router at `192.168.50.1`. `pi4` (this repo's
Pi-hole host) is at `192.168.50.234`.

## Backups

`Administration → Restore/Save/Upload Setting → Save setting` downloads a
`.CFG` file with the full current config, including credentials (WiFi
passwords, admin password) — store it somewhere durable outside this repo
(`infra` is public). Take a fresh one before any firmware update, not just
once.

**If a future update breaks something:** don't assume restoring from a
backup is the safe fix. A corrupted/incompatible NVRAM state can survive a
restore — a factory reset (`Administration → Restore/Save/Upload Setting →
Restore`, with the "clear all content and data logs" checkbox) followed by
manually reconfiguring from the list below is more reliable than blindly
restoring the `.CFG` file.

## DHCP (`LAN → DHCP Server`)

- Manually Assigned IP: `pi4` (MAC `DC:A6:32:21:6F:04`) → `192.168.50.234`
- Manually Assigned IP: `p14s-personal` wifi (MAC `DC:56:7B:80:67:2D`) →
  `192.168.50.239`
- Manually Assigned IP: `p14s-personal` wired (MAC `18:3D:2D:86:66:76`) →
  `192.168.50.13`
- DNS Server 1: `192.168.50.234` (`pi4`)
- "Advertise router's IP in addition to user-specified DNS": **No** —
  otherwise clients get both the router and `pi4` as resolvers and can
  round-robin around Pi-hole

## WireGuard remote access (`WAN → DDNS`, `WAN → Virtual Server / Port Forwarding`)

The WireGuard _server_ runs on `pi4` (`modules/hosts/pi4-wireguard.nix`), not
the router — the router only needs two settings to make it reachable from
outside the LAN:

- DDNS: ASUS's own free DDNS service, enabled under `WAN → DDNS`. Needed
  because the home WAN IP isn't static; gives a stable hostname for
  clients to connect to instead of a raw IP that can change.
- Port forwarding: external UDP `51820` → `192.168.50.234:51820` (`pi4`'s
  WireGuard port), under `WAN → Virtual Server / Port Forwarding`.

No other router-side config is needed — `pi4` handles NAT for the VPN
subnet itself (see `modules/hosts/pi4-wireguard.nix`), so no LAN routing
table changes are required.

## DNS Director (`LAN → DNS Director`)

- Enable DNS Director: **On**
- Global Redirection: **User Defined 1** → `192.168.50.234`
- Client List: `pi4` (`DC:A6:32:21:6F:04`) → **No Redirection**

The client exception for `pi4` is load-bearing, not optional: without it,
`pi4`'s own outbound DNS queries (to whatever upstreams
`modules/pihole.nix` configures) get redirected back to `pi4` itself,
since it's just another LAN client from the router's point of view. This
caused every upstream query to come back `REFUSED` — confirmed live by
testing `9.9.9.9` and `8.8.8.8` directly from `pi4`, which resolved
correctly with the client exception in place and failed identically
without it.

## `pihole status` false negative on `pi4`

`pihole status` (and anything else in the CLI using `getFTLPID()`) always
reports "DNS service is NOT running" on this host, even when it's healthy.
It checks for a PID file at `/run/pihole-FTL.pid`, but NixOS runs FTL in
`no-daemon` mode directly under systemd (`Type=simple`), which never writes
one — systemd tracks the process itself. Trust `systemctl status
pihole-ftl` / `ss -tulnp | grep :53` instead.

## Wireless (`Wireless → General`)

Smart Connect: **Off** (separate SSIDs per band — `nami-2.4`, `nami-5.0`).

**2.4GHz**: Wireless Mode `Legacy`, Channel bandwidth `20 MHz`, Control
Channel `Auto`, WPA2-Personal/AES, Protected Management Frames
`Capable`.

**5GHz**: Wireless Mode `Auto`, 802.11ax/WiFi 6 `Enable`, Channel
bandwidth `20/40/80/160 MHz` with "Enable 160 MHz" checked, Control
Channel `Auto` with "Auto select channel including DFS channels" checked,
WPA2-Personal/AES, Protected Management Frames `Capable`.

The DFS channel allowance is required for the 160MHz setting to actually
take effect — the non-DFS range alone only supports up to 80MHz in most
regulatory domains. Trade-off: DFS channels need a brief silent
"Channel Availability Check" before transmitting, and the radio must
immediately vacate a channel if it detects what it thinks is radar —
rare, but a legitimate cost for the extra bandwidth.

## Known incidents

**2026-08-23/24 — a routine firmware update (3004.388.12_2) broke both
wireless radios.** 5GHz never came up as a kernel interface at all
(`request_irq failed for irq=36 (brcm_36) retval=-16` in `dmesg`); 2.4GHz
looked fully healthy at the driver level but radiated nothing. Reproduced
identically across a warm reboot, a hard power cycle, two full factory
resets, and a downgrade to 388.11_0 — ruling out settings, NVRAM, and (by
elimination) a version-specific firmware bug. Resolved by reflashing
388.12_2 again (the same version that originally broke) and reconfiguring
both bands' wireless settings from scratch; root cause never conclusively
identified, but the fix has held since.

**Same incident — DNS Director self-redirect loop**, see above.
