# OpenSSH for the local network. Passwords and keyboard-interactive logins are off.
# Tailscale SSH is the remote login.
{
  flake.modules.nixos."openssh" = {
    services.openssh.enable = true;
    services.openssh.settings.PasswordAuthentication = false;
    services.openssh.settings.KbdInteractiveAuthentication = false;
  };
}
