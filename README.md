# NixOS configuration

Declarative NixOS configuration for every host under `hosts/`.

| Path | Contents |
| --- | --- |
| `hosts/<name>/` | Per-host configuration and hardware |
| `modules/` | Shared modules: `base`, `desktop`, `drivers`, `waywarp.nix` |
| `files/` | Plain application config files read by the modules |
| `secrets/` | sops-encrypted secrets |
| `patches/` | Patches for flake inputs |

Run `nix flake check` to lint, check formatting, and build every host, and
`nh os switch .` to activate the current host.

## Flake inputs

`flake.nix` declares sources and branches; exact revisions live only in
`flake.lock`. Don't put tags or revisions in input URLs. Inputs without a branch
follow the upstream default branch.

```bash
nix flake update herdr-nix   # one input
nix flake update             # all inputs
```

Review the lockfile diff, run `nix flake check`, and regenerate any patch whose
input changed.

Herdr comes from [herdr-nix](https://github.com/herdrdev/herdr-nix)'s
release binaries and its signed `https://herdr.cachix.org` cache. It tracks
stable releases. Keep herdr-nix's own `nixpkgs` pin so the package matches the
cached derivation.

## Secrets

Secrets under `secrets/` are encrypted with
[sops-nix](https://github.com/Mic92/sops-nix). `.sops.yaml` lists the
recipients:

- the admin age key, kept at `~/.config/sops/age/keys.txt` and backed up off
  this machine
- each host's SSH host key, converted to age

Hosts decrypt with `/etc/ssh/ssh_host_ed25519_key`, so the admin key is only
needed for editing. Use secrets only for optional services, so that a host that
can't decrypt them still boots.

To bootstrap a new or reinstalled host:

1. Install NixOS and switch to this flake. Secrets fail to decrypt and the
   services that need them are skipped.
2. On a machine with the admin key, add the host's age key to `.sops.yaml`,
   removing its old key after a reinstall, then re-encrypt, commit, and push:

   ```bash
   ssh-keyscan -t ed25519 <host> | ssh-to-age
   sops updatekeys secrets/*
   ```

3. Pull and run `nh os switch .` on the new host.

## Waywarp

[Waywarp](https://github.com/apersomany/waywarp) runs WARP instances as bridge
links. Neither instance changes the host's default route.

### `osaka` (both hosts)

Instance `0` provides `waywarp0`. It bootstraps through Osaka Azure Mudfish
relays and requires `geo4=JP/Osaka+edge=KIX`: a public IPv4 address advertised
in Osaka and a KIX tunnel endpoint. Some destinations or IPv6 traffic may still
exit elsewhere.

The Mudfish credentials are in `secrets/waywarp-mudfish.env` (edit with
`sops secrets/waywarp-mudfish.env`). They use systemd environment-file syntax,
so quote values that contain quotes or backslashes. They're decrypted to
`/run/secrets/waywarp-mudfish`. If the host can't decrypt them, the service is
skipped without affecting boot. The service restarts whenever the secret
changes.

Nothing routes through `waywarp0` by default. Bind to it or add routes, since
bridge mode has no proxy listener:

```bash
sudo waywarp status 0
journalctl -u waywarp-osaka.service
sudo curl --interface waywarp0 https://www.cloudflare.com/cdn-cgi/trace
```

**Brave (Waywarp)**, or `brave-waywarp`, runs Brave as your user inside the
namespace behind `waywarp0`, with WARP's DNS. It shares the regular Brave
profile, so close any regular Brave session first. It refuses to start if it
can't find the instance, rather than falling back to the host network.

### `zero-trust` (workstation)

Instance `1` replaces the official Cloudflare client on workstation;
scg-workstation still runs the official client. It uses a copy of the Zero Trust
registration, imported once with `sudo waywarp import 1`. At startup,
`files/waywarp/zero-trust` reads the registration's policy and sets up the
following on `waywarp1`:

- the split-tunnel routes
- Gateway DNS over TLS
- DNS delegates for fallback domains that have their own resolvers, such as
  `home.arpa`

systemd-resolved handles host DNS. Restart `waywarp-zero-trust.service` after
changing the device profile in the Cloudflare dashboard.

## KakaoTalk through Wine

Launch **KakaoTalk** from the application menu or run `kakaotalk`. The first
launch downloads Kakao's official Windows installer into a dedicated 64-bit Wine
prefix at `${XDG_DATA_HOME:-~/.local/share}/kakaotalk/wine`. Login and device
verification are manual. Wine is unofficial, so calls, Korean input, and future
updates may not work fully.

```bash
kakaotalk --install                            # install without launching
kakaotalk --install /path/to/KakaoTalk_Setup.exe
```

The launcher uses XWayland, Kime, `ko_KR.UTF-8`, and Freesentation font
substitutions. Wine's standalone tray window is disabled; tray icons still dock
in a compatible host tray. Registry changes apply after KakaoTalk and its Wine
session fully exit. The shared `~/.wine` prefix is untouched. Installers are
cached in `${XDG_CACHE_HOME:-~/.cache}/kakaotalk`. The launcher and Wine are
declarative; KakaoTalk itself installs and updates inside the prefix.
