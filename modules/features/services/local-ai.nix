# Ollama on the graphics chip, Hermes, and the two local models.
{
  flake.modules.nixos."local-ai" =
  # Local AI: Ollama with the Vulkan backend so the Radeon 840M iGPU does the work.
  # Hermes Agent needs at least 64K tokens of context, so the server default is raised.

  { config, pkgs, lib, hermes-agent, ... }:

  {
    environment.systemPackages = [
      hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    services.ollama = {
      enable = true;
      package = pkgs.ollama-vulkan;
      environmentVariables = {
        OLLAMA_CONTEXT_LENGTH = "65536";
        OLLAMA_KEEP_ALIVE = "30m";
        # Ollama skips integrated GPUs unless told otherwise; the 840M is the only GPU here.
        OLLAMA_IGPU_ENABLE = "1";
      };
    };

    # GPU render node access for John (video is already in user-accounts.nix).
    users.users.John.extraGroups = [ "render" ];

    # Pull only a missing Hermes model. An update does not download one that is already installed.
    systemd.services.ollama-hermes-models = {
      description = "Install Hermes models if they are missing";
      wantedBy = [ "multi-user.target" ];
      after = [ "ollama.service" "network-online.target" ];
      wants = [ "ollama.service" ];
      serviceConfig = {
        Type = "oneshot";
        # The ollama command panics when HOME is unset.
        Environment = "HOME=/root";
      };
      script = ''
        export OLLAMA_HOST=127.0.0.1:11434
        for model in gpt-oss:20b qwen3.5:9b; do
          if ! ${pkgs.ollama-vulkan}/bin/ollama show "$model" >/dev/null 2>&1; then
            ${pkgs.ollama-vulkan}/bin/ollama pull "$model"
          fi
        done
      '';
    };
  }
;
}
