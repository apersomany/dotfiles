# Workstation configuration

Declarative NixOS configuration for the hosts under `hosts/`.

## Flake input versions

Declare input sources and tracking branches in `flake.nix`; keep exact revision
pins exclusively in `flake.lock`. Do not embed release tags or commit revisions
in input URLs. Inputs without a branch follow the upstream default branch, so
updates are not restricted to stable releases.

Update one input with:

```bash
nix flake update herdr-nix
```

Use `nix flake update` to update all inputs. Review and commit the lockfile diff
after running the applicable validation gates in `AGENTS.md`. Regenerate patches
when their pinned inputs change.

Herdr uses the official [herdr-nix](https://github.com/herdrdev/herdr-nix)
release-binary package and its signed `https://herdr.cachix.org` cache. It tracks
stable releases rather than Herdr's development branch. Keep its upstream
`nixpkgs` pin so the package matches the published cached derivation.

## KakaoTalk through Wine

Launch **KakaoTalk** from the application menu or run `kakaotalk`. The first
launch downloads Kakao's official non-beta Windows installer and installs it
into a dedicated 64-bit Wine prefix at
`${XDG_DATA_HOME:-~/.local/share}/kakaotalk/wine`. Account login and mobile
device verification are manual. Wine is an unofficial compatibility layer;
calling, Korean input, and future KakaoTalk updates may have limitations.

To install without launching, or reinstall from a downloaded installer:

```bash
kakaotalk --install
kakaotalk --install /path/to/KakaoTalk_Setup.exe
```

The launcher uses XWayland with the session's existing Kime input method,
`ko_KR.UTF-8`, and Freesentation font substitutions. Wine's standalone tray
window is disabled; tray icons can still dock in a compatible host tray.
Registry changes take effect after fully exiting KakaoTalk and its Wine session.
It does not change the shared `~/.wine` prefix. Installer downloads are cached under
`${XDG_CACHE_HOME:-~/.cache}/kakaotalk`; account data stays outside the Nix store
and repository. The launcher and Wine version are declarative, but the Windows
application is installed and updated in the user-owned prefix.

## Osaka WARP bridge

Waywarp instance `0` (alias `osaka`) provides the `waywarp0` bridge link.
It bootstraps through Osaka Azure Mudfish relays and requires
`geo4=JP/Osaka+edge=KIX`: a public IPv4 address advertised in Osaka and a KIX
tunnel endpoint. This does not guarantee every destination exits through KIX
or that IPv6 is geolocated in Osaka.

The Mudfish credentials live in the sops-encrypted
`secrets/waywarp-mudfish.env` (systemd environment-file syntax) and are
decrypted to `/run/secrets/waywarp-mudfish` during activation. Edit them with
`sops secrets/waywarp-mudfish.env`; quote values according to systemd
environment-file syntax, especially passwords containing quotes or backslashes.

If the host cannot decrypt the secret, systemd skips `waywarp-osaka.service`
before starting Waywarp. It does not fail the service or prevent boot. The
bridge does not replace the host's default route or DNS, and nothing is
configured to require it. Traffic explicitly routed through or bound to
`waywarp0` cannot use it while it is stopped. The service restarts whenever the
secret changes. Check it with:

```bash
sudo waywarp status 0
journalctl -u waywarp-osaka.service
sudo curl --interface waywarp0 https://www.cloudflare.com/cdn-cgi/trace
```

Use interface-bound requests as above or add explicit destination routes to
reach WARP; no SOCKS5/HTTP proxy listener is provided in bridge mode. The
existing host Cloudflare WARP configuration is independent and unchanged.

## Secrets

Secrets under `secrets/` are encrypted with [sops-nix](https://github.com/Mic92/sops-nix).
`.sops.yaml` lists the recipients: the admin age key
(`~/.config/sops/age/keys.txt`, backed up outside this machine) and each host's
SSH host key converted to age. Hosts decrypt with
`/etc/ssh/ssh_host_ed25519_key`, so the admin key never needs to be on a host
that only consumes secrets. Secrets must only gate optional services.

To bootstrap a new or reinstalled host:

1. Install NixOS and switch to this flake. Secrets fail to decrypt, but the
   system boots and services that need them are skipped.
2. On a machine with the admin key, derive the host's age key and add it to
   `.sops.yaml`, then re-encrypt, commit, and push:

   ```bash
   ssh-keyscan -t ed25519 <host> | ssh-to-age
   sops updatekeys secrets/*
   ```

   Remove the host's previous key if it was reinstalled.
3. Pull and run `nh os switch .` on the new host.
