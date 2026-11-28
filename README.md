# flakebasic

NixOS for three computers. The hostname after `#` picks the computer.

```bash
sudo nixos-rebuild boot --flake github:jdnitrap/flakebasic#nixasus --impure
```

Use `#ilenovo` or `#inixos` on those machines. `--impure` is required because the flake reads `/etc/nixos/hardware-configuration.nix` from the computer being built. `boot` installs the generation and applies it on the next reboot.

A longer explanation is in `/home/John/flakebasic-guide.md` on nixasus. It is not part of this repository.

## Where to look

`flake.nix` only names the downloads (Nixpkgs, Flatpak, Hermes). Every other file is loaded automatically from `modules/`.

`modules/computers.nix` is the menu. A feature does nothing until a computer lists it.

`modules/features/` is one topic per file. The computer menu decides which files apply.

`AGENTS.md` says to keep this structure when editing the repository.

## What each computer uses

| Computer | Desktop | Extra features |
| --- | --- | --- |
| nixasus | GNOME, John signs in automatically | AdGuard, DNS lock, OpenSnitch, Ollama, Hermes, Grok, Claude, Podman, virtual machines, Bluetooth, OpenSSH, Tailscale SSH |
| ilenovo | GNOME | nothing else |
| inixos | Cinnamon, LightDM, John signs in automatically | Tailscale, Nextcloud, OnlyOffice, Bluetooth |

These files exist and are not on any computer until you add them in `modules/computers.nix`: AppArmor, Plasma, the Sunday update, and the account service.

`admin` and `John` can run `sudo` without a password on every computer. The rule is in `modules/features/users.nix`.

Disks stay in `/etc/nixos/hardware-configuration.nix` on each computer. Do not copy that file into this repository.
