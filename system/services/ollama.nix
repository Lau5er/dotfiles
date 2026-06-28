{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.ollama-custom;
  ollamaPkg = {
    rocm = pkgs.ollama-rocm;
    cuda = pkgs.ollama-cuda;
    cpu = pkgs.ollama;
  }.${cfg.backend};
in {
  options.services.ollama-custom = {
    enable = mkEnableOption "Ollama AI service";

    backend = mkOption {
      type = types.enum [ "rocm" "cuda" "cpu" ];
      default = "cpu";
      description = "Ollama backend: rocm (AMD), cuda (NVIDIA), or cpu";
    };

    contextLength = mkOption {
      type = types.int;
      default = 65536;
    };

    numParallel = mkOption {
      type = types.int;
      default = 1;
    };

    enableOpenWebUI = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Open WebUI for Ollama";
    };
  };

  config = mkIf cfg.enable {
    services.ollama = {
      enable = true;
      package = ollamaPkg;
      environmentVariables = {
        OLLAMA_CONTEXT_LENGTH = toString cfg.contextLength;
        OLLAMA_NUM_PARALLEL = toString cfg.numParallel;
      };
    };

    services.open-webui = mkIf cfg.enableOpenWebUI {
      enable = true;
    };
  };
}
