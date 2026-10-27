#user-accounts.nix

{config, lib, pkgs, inputs, ... }:

{
  users.mutableUsers = true;

  users.users.admin = {
    isNormalUser = true;
    description = "Admin";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    hashedPassword = "$6$JiVWJ4fJSIVi/Leh$0YFnnQjyEKhxC.GqjBeBNzWnZmJKWLYzK.mLYjFoGP0yM60QZMDBRvEBJ3qLIJED0kO90A5Hyam5sryaAatVN/";
  };
}
