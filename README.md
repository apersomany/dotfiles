# Workstation configuration

Declarative NixOS configuration for `workstation`.

## Osaka WARP bridge

Waywarp instance `0` (alias `osaka`) provides the `waywarp0` bridge link.
It bootstraps through Osaka Azure Mudfish relays and requires
`geo4=JP/Osaka+edge=KIX`: a public IPv4 address advertised in Osaka and a KIX
tunnel endpoint. This does not guarantee every destination exits through KIX
or that IPv6 is geolocated in Osaka.

Provide credentials outside the repository and Nix store:

```bash
sudo install -d -m 0700 /var/lib/secrets
sudo install -m 0600 -o root -g root /path/to/credentials.env /var/lib/secrets/waywarp-mudfish.env
```

The file uses systemd environment-file syntax:

```text
WAYWARP_MUDFISH_USERNAME='your username'
WAYWARP_MUDFISH_PASSWORD='your password'
```

Do not commit this file. Quote values according to systemd environment-file
syntax, especially passwords containing quotes or backslashes.

If the file is missing, systemd skips `waywarp-osaka.service` before starting
Waywarp. It does not fail the service or prevent boot. The bridge does not
replace the host's default route or DNS, and nothing on this machine is
configured to require it. Traffic explicitly routed through or bound to
`waywarp0` cannot use it while it is stopped. An existing but invalid credential
file can cause service startup to fail; it still does not make the service a
boot requirement.

After providing credentials, start the service manually; creating the file
alone does not trigger a start:

```bash
sudo systemctl start waywarp-osaka.service
sudo waywarp status 0
journalctl -u waywarp-osaka.service
sudo curl --interface waywarp0 https://www.cloudflare.com/cdn-cgi/trace
```

The service starts automatically on subsequent boots when the credential file
exists. Use interface-bound requests as above or add explicit destination routes
to reach WARP; no SOCKS5/HTTP proxy listener is provided in bridge mode.
The existing host Cloudflare WARP configuration is independent and unchanged.
