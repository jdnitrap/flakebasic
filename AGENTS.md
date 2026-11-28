# Keep this structure

This file is for a person or an assistant editing the repository. Add a feature inside the layout below. Do not invent a second layout.

## How the repository is built

`flake.nix` names the downloads. It does not contain computer settings. `import-tree` loads every file under `modules/`.

`modules/computers.nix` is the menu. `everyComputer` is included on nixasus, ilenovo, and inixos. Each computer then adds only the feature names in its own list. The hostname is the name passed to `computer`.

`modules/features/` holds one topic per file. A file there does nothing until a computer lists it. The attribute name is the file name without `.nix`:

```nix
{
  flake.modules.nixos."printing" = { config, pkgs, lib, ... }: {
    services.printing.enable = true;
  };
}
```

List that feature as `features.printing`. A hyphen is part of the name. `features.dns-lock` and `features."dns-lock"` are the same name.

`modules/flake-output.nix` lets those feature files combine into one list. Leave that mechanism in place.

`plymouth/` is the boot splash. Leave those files there.

## When you add something

- A shared setting goes in a feature file, then into `everyComputer`, only when every computer should have it.
- A setting for one computer goes in a feature file, then into that computer's list only.
- Facts about one machine, such as an account id, go in a feature named for that computer, like `inixos-host`. Do not put them in a shared feature.
- Update the table in `README.md` when a computer's list changes.

## Leave these out of the repository

Disks stay in `/etc/nixos/hardware-configuration.nix` on the computer being built. A rebuild needs `--impure` to read that file. Do not copy it here.

Passwords and other secrets stay on the computer. The flake may name the path of a secret file. It must not contain the secret.
