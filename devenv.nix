{
  pkgs,
  lib,
  config,
  ...
}:
{
  env = {
    INFOMANIAK_TOKEN = config.secretspec.secrets.INFOMANIAK_TOKEN or "";
    K3S_TOKEN = config.secretspec.secrets.K3S_TOKEN or "";
    MIKROTIK_USER = config.secretspec.secrets.MIKROTIK_USER or "";
    MIKROTIK_PASSWORD = config.secretspec.secrets.MIKROTIK_PASSWORD or "";
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
    pkgs.helmfile
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
