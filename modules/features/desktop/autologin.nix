# Sign John in when the login screen starts. The greeter does not ask for a password.
{
  flake.modules.nixos."autologin" = {
    services.displayManager.autoLogin = {
      enable = true;
      user = "John";
    };
  };
}
