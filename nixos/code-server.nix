{ config, pkgs, ... }:
{
  # Initially based on: https://github.com/NixOS/nixpkgs/pull/87258#issuecomment-642971699
  systemd.services.code-server = {
    enable = true;
    after = ["network.target"];
    wantedBy =["multi-user.target"];
    path = with pkgs; [ go git direnv ];

    serviceConfig = {
      Type = "simple";
      # Setting auth to none is fine for now since auth/access is done through the proxy anyway.
      ExecStart = "${pkgs.code-server}/bin/code-server --auth none";
      WorkingDirectory = "/home/mlieberman";
      NoNewPrivileges = "true";
      User = "mlieberman";
      Group = "users";
    };
  };

  environment.systemPackages = with pkgs; [
    code-server
  ];
}
