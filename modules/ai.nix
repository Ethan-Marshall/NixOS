{ config, pkgs, lib, ... }:

{
  # ---------------------------------------------------------------------------
  # AI Packages
  # ---------------------------------------------------------------------------

  environment.systemPackages = with pkgs; [

    # ── n8n ───────────────────────────────────────────────────────────────────
    # Workflow automation platform. Run on demand with: n8n start
    # Useful for chaining AI calls, threat intel feeds, and blog automation.
    n8n

  ];
}
