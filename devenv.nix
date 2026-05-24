{
  pkgs,
  lib,
  config,
  ...
}:
{
  packages = [
    pkgs.cairo
    pkgs.go-task
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
