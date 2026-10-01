# Workstation configuration

Declarative NixOS configuration for `workstation`.

## Hong Kong WARP proxy

Waywarp instance `0` (alias `hkg`) serves SOCKS5 and HTTP CONNECT at
`127.0.0.1:1080`. It bootstraps through Hong Kong Mudfish relays and requires
`geo4=HK+edge=HKG`: a public IPv4 address advertised in Hong Kong and an HKG
tunnel endpoint. This does not guarantee every destination exits through HKG
or that IPv6 is geolocated in Hong Kong.

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

If the file is missing, systemd skips `waywarp-hkg.service` before starting
Waywarp. It does not fail the service or prevent boot. The proxy does not
replace host routes or DNS, and nothing on this machine is configured to
require it. Applications explicitly using the proxy cannot use it while it
is stopped. An existing but invalid credential file can cause service startup
to fail; it still does not make the service a boot requirement.

After providing credentials, start the service manually; creating the file
alone does not trigger a start:

```bash
sudo systemctl start waywarp-hkg.service
sudo waywarp status 0
journalctl -u waywarp-hkg.service
curl --proxy socks5h://127.0.0.1:1080 https://www.cloudflare.com/cdn-cgi/trace
```

The service starts automatically on subsequent boots when the credential file
exists. The loopback proxy has no authentication; any local user can use it.
The existing host Cloudflare WARP configuration is independent and unchanged.
