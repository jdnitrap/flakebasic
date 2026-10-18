#user-accounts.nix

{config, lib, pkgs, inputs, ... }:

{

users.users."nimda" = {
    isNormalUser = true;
    description = "nimda";
    extraGroups = [ "networkmanager" "wheel" "lp" "scanner" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };


}
