{
  pkgs,
  lib,
  config,
  ...
}:
{
  env = {
    K3S_TOKEN = config.secretspec.secrets.K3S_TOKEN or "";
  };

  packages = [
    pkgs.secretspec
    pkgs.cairo # documentation
    pkgs.go-task
    pkgs.incus
    pkgs.gnupg
    pkgs.gnutar
    pkgs.openssl
    pkgs.butane
    pkgs.minijinja
    pkgs.kubectl
    pkgs.kubernetes-helm
    pkgs.fluxcd
  ];

  languages.python = {
    enable = true;
    version = lib.strings.trim (builtins.readFile ./.python-version);
    venv.enable = true;
    uv = {
      enable = true;
      sync = {
        enable = true;
        allExtras = true;
      };
    };
  };

  tasks = {
    "ansible-galaxy:install" = {
      exec = "uv run ansible-galaxy install -r ansible/requirements.yml";
      execIfModified = [
        "ansible/requirements.yml"
      ];
    };
  };
}
