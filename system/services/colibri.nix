{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.colibri;

  huggingfaceEnv = pkgs.python3.withPackages (ps: [
    ps.huggingface-hub
  ]);
in
{
  options.services.colibri = {
    enable = mkEnableOption "Colibri MoE inference service (GLM-5.2 via OpenAI-compatible API)";

    autoStart = mkOption {
      type = types.bool;
      default = true;
      description = "Start the service automatically at boot (false = start manually via systemctl).";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.colibri;
      description = "Colibri engine package (coli launcher + C engine).";
    };

    modelPath = mkOption {
      type = types.str;
      example = "/home/lauser/models/glm52_i4";
      description = "Path to the GLM-5.2 colibri int4 model container (~370 GB).";
    };

    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Bind address of the OpenAI-compatible API.";
    };

    port = mkOption {
      type = types.port;
      default = 8000;
      description = "Port of the OpenAI-compatible API.";
    };

    modelId = mkOption {
      type = types.str;
      default = "glm-5.2-colibri";
      description = "Model id reported by the API (used by JetBrains, curl, etc.).";
    };

    apiKey = mkOption {
      type = types.str;
      default = "local";
      description = "API key; the server accepts any non-empty value by default.";
    };

    user = mkOption {
      type = types.str;
      default = "colibri";
    };

    group = mkOption {
      type = types.str;
      default = "colibri";
    };

    contextLength = mkOption {
      type = types.ints.positive;
      default = 4096;
      description = "Maximum context length (tokens) the KV cache is sized for.";
    };

    kvQuant = mkOption {
      type = types.enum [ "kv8" "kv_tq" "off" ];
      default = "off";
      description = "KV cache quantization to shrink KV RAM (kv_tq ≈ 7.6x smaller than f32, kv8 ≈ 3.9x).";
    };

    maxNumParallel = mkOption {
      type = types.ints.positive;
      default = 1;
      description = "Number of independent KV conversation slots.";
    };

    extraEnv = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Additional KEY=VALUE environment variables for the service.";
    };
  };

  config = mkIf cfg.enable {
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
    };
    users.groups.${cfg.group} = { };

    systemd.services.colibri = {
      description = "Colibri MoE inference server (OpenAI-compatible API)";
      wantedBy = lib.optional cfg.autoStart "multi-user.target";
      after = [ "network.target" ];
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        Type = "simple";
        StateDirectory = "colibri";
        Environment = [
          "HOME=/var/lib/colibri"
          "COLI_MODEL=${cfg.modelPath}"
          "COLI_API_KEY=${cfg.apiKey}"
          "COLI_MODEL_ID=${cfg.modelId}"
          "CTX=${toString cfg.contextLength}"
          "KV_SLOTS=${toString cfg.maxNumParallel}"
        ] ++ lib.optional (cfg.kvQuant == "kv8") "KV8=1"
        ++ lib.optional (cfg.kvQuant == "kv_tq") "KV_TQ=4"
        ++ cfg.extraEnv;
        ExecStart =
          "${cfg.package}/bin/coli serve --host ${cfg.host} --port ${toString cfg.port}";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    environment.systemPackages = [
      cfg.package
      (pkgs.writeShellScriptBin "colibri-download-model" ''
        set -euo pipefail
        TARGET="''${1:-${cfg.modelPath}}"
        REPO="''${2:-mastouri/GLM-5.2-colibri-int4-g64-with-int8-mtp}"
        mkdir -p "$(dirname "$TARGET")"
        ${huggingfaceEnv}/bin/hf download "$REPO" --local-dir "$TARGET"
        chmod -R a+rX "$TARGET"
        echo "Model ready at $TARGET"
      '')
    ];
  };
}
