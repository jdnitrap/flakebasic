# flakebasic

NixOS configurations for three computers. The hostname picks the configuration. Disks stay on the computer.

```bash
sudo nixos-rebuild boot --flake github:jdnitrap/flakebasic#nixasus --impure
```

Use `#minilap` or `#inixos` on those machines. `--impure` is required because the flake reads `/etc/nixos/hardware.nix` from the computer being built. `boot` installs the generation and does not switch to it until the next reboot. Use `switch` instead of `boot` to apply it immediately.

## Layout

`flake.nix` lists the hosts and the pinned inputs. `configuration.nix` imports the modules that every host gets. `hosts/<name>.nix` is only that computer.

Every host gets AdGuard, printing, sound, laptop power, the `admin` and `John` accounts, the AppArmor window, Zen, and Firefox.

| Host | Desktop | Only on that host |
| --- | --- | --- |
| `nixasus` | GNOME, John signs in automatically | Tailscale SSH, OpenSSH with passwords off, DNS lock, OpenSnitch, Ollama, Hermes, Grok Build, Claude Code, Podman, Distrobox, virt-manager |
| `minilap` | GNOME | nothing else |
| `inixos` | Cinnamon, LightDM | Nextcloud, published with Tailscale Serve |

Hardware is not in this repository. On each computer:

```bash
sudo ln -sf /etc/nixos/hardware-configuration.nix /etc/nixos/hardware.nix
```

`nixos-generate-config` rewrites `hardware-configuration.nix`. The link is what the flake reads. Do not copy that file into the repository.

## Grok and Claude

Only `nixasus` installs these. They are in `hosts/nixasus.nix`:

- `pkgs.grok-build` provides the `grok` command.
- `pkgs.claude-code` provides the `claude` command.

Both are unfree. `system-packages.nix` already sets `nixpkgs.config.allowUnfree = true`, so the rebuild is allowed to install them. `minilap` and `inixos` do not get either package. A copy of Grok already in a home directory is separate from the system package.

## Change a setting

Edit the file, commit, and push. The Sunday 3 AM job builds `github:jdnitrap/flakebasic#<hostname>`. Until the push, that job still has the old files.

A setting for one computer goes in `hosts/<name>.nix`. A setting for all computers goes in a module imported by `configuration.nix`.

Shared files set some options with `mkDefault`, so a host file can replace them. `networking.nix` does this for OpenSSH and the reverse-path check. A host that sets the same option without `mkDefault` wins. Two plain assignments of different values make the build fail.

New files must be committed before Nix will see them. This directory is a git repo, and Nix copies only tracked files.

## Add a computer

1. Add the hostname to `hosts` in `flake.nix`.
2. Create `hosts/<name>.nix` with `networking.hostName` and the desktop import (`../gnome.nix` or `../cinnamon.nix`).
3. On that computer, create the `/etc/nixos/hardware.nix` link.
4. Commit, push, then rebuild with that hostname.

## Accounts

`admin` has no password in the flake. On a new computer run `sudo passwd admin`.

`John` is uid 1002. `initialPassword` is `changeme` only when the account is created. A rebuild does not replace a password that is already set.

## Updates and the lock

`flake.lock` pins Nixpkgs (`nixos-26.05`), nix-flatpak `v0.8.0`, `apparmor-gui`, and Hermes. The Sunday job does not move those pins.

`nixasus` does not pass `--refresh`, so it does not re-download inputs that are already on the machine. `minilap` and `inixos` still pass `--refresh`. None of the hosts write a new lock file during the Sunday job.

To move Nixpkgs, the Flatpak module, or `apparmor-gui` forward:

```bash
nix flake update nixpkgs
git add flake.lock
git commit -m "Update nixpkgs"
git push
```

Replace `nixpkgs` with `nix-flatpak` or `apparmor-gui` to move just that input. The next Sunday 3 AM run, or a manual rebuild, then downloads the new commit if it is not already present.

Hermes stays on the stable tag named in `flake.nix` (`v0.23.4`). A newer stable release is a new tag, not an update of the old one. Change the tag in `flake.nix`, then:

```bash
nix flake update hermes-agent
git add flake.nix flake.lock
git commit -m "Update Hermes"
git push
```

Do not point Hermes at `main`. That is not the stable release.

Hermes models `gpt-oss:20b` and `qwen3.5:9b` download only when `ollama show` says one is missing. A rebuild does not download them again.

## What does not belong here

Passwords, Tailscale auth keys, and `/etc/nixos/hardware.nix` stay on the computer. `~/.hermes` stays in John's home directory. The public `apparmor-gui` flake has no hostname and no username. This repo only turns that module on.
