{ config, pkgs, lib, ... }:

{
  # ---------------------------------------------------------------------------
  # AI Services
  # ---------------------------------------------------------------------------

  # — Open WebUI ————————————————————————————————————————————————————————————
  # Self-hosted chat interface for AI models. Uses OpenRouter as the backend
  # instead of local Ollama — provides access to 300+ free and paid models
  # through a single OpenAI-compatible API. Accessible at localhost:8080
  services.open-webui = {
    enable = true;
    port = 8080;
    host = "127.0.0.1";    # localhost only — not exposed to the network
    environment = {
      ANONYMIZED_TELEMETRY          = "False";   # disable telemetry
      DO_NOT_TRACK                  = "True";    # disable usage tracking
      SCARF_NO_ANALYTICS            = "True";    # disable scarf analytics
      OPENAI_API_BASE_URL           = "https://openrouter.ai/api/v1";  # OpenRouter endpoint
      OPENAI_API_KEY                = "your-openrouter-api-key-here";  # WARNING: do not commit to public repo
      ENABLE_OLLAMA_API             = "False";   # no local Ollama — using OpenRouter exclusively
    };
  };

  # disable autostart of open-webui service
  systemd.services.open-webui.wantedBy = lib.mkForce [];

  # — n8n ———————————————————————————————————————————————————————————————————
  # Open source workflow automation platform. Used for chaining AI model
  # calls, automating blog image prompt generation, processing threat intel
  # feeds, and other research automation tasks. Accessible at localhost:5678
  services.n8n = {
    enable = true;
  };

  # disable autostart of n8n service
  systemd.services.n8n.wantedBy = lib.mkForce [];


  # — AI Service Aliases ————————————————————————————————————————————————————
  # Start and stop AI services on demand rather than running persistently.
  programs.fish.shellAliases = {
    ai-start = "sudo systemctl start open-webui n8n";
    ai-stop = "sudo systemctl stop open-webui n8n";
    ai-status = "sudo systemctl status open-webui n8n";
    webui-start = "sudo systemctl start open-webui";
    webui-stop = "sudo systemctl stop open-webui";
    n8n-start = "sudo systemctl start n8n";
    n8n-stop = "sudo systemctl stop n8n";
  };


  # — Nixpkgs allowlist —————————————————————————————————————————————————————
  # Open WebUI uses a modified BSD-3-Clause license that nixpkgs marks as
  # non-free. Allowlisted specifically rather than enabling allowUnfree globally.
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (pkgs.lib.getName pkg) [ "open-webui" ];
}
