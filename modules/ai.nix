{ config, pkgs, lib, ... }:

{
  # ---------------------------------------------------------------------------
  # AI Packages
  # ---------------------------------------------------------------------------

  environment.systemPackages = with pkgs; [

    # ── Chatbox ───────────────────────────────────────────────────────────────
    # Desktop AI client. Supports OpenAI, Claude, Gemini, Ollama, and any
    # OpenAI-compatible API (e.g. OpenRouter). All data stays local.
    chatbox

    # ── n8n ───────────────────────────────────────────────────────────────────
    # Workflow automation platform. Run on demand with: n8n start
    # Useful for chaining AI calls, threat intel feeds, and blog automation.
    n8n

  ];
}
