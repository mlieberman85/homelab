{ pkgs, lib, ... }:

let
  # TODO: Figure out better way to manage below.
  usersFile = if builtins.pathExists /tmp/users.json then /tmp/users.json else null;
  config = if isNull usersFile then [ ] else builtins.fromJSON (builtins.readFile usersFile);
  portList = lib.range 11000 (11000 + (lib.length config));
  zippedConfig = lib.zipLists config portList;
  mkUserList = userConfig: builtins.map
    (n: {
      user = {
        name = n.fst;
        value = {
          isNormalUser = true;
          home = "/home/${n.fst}";
          shell = pkgs.bash;
        };
      };

      code-server = {
        # Initially based on: https://github.com/NixOS/nixpkgs/pull/87258#issuecomment-642971699
        name = "code-server-${n.fst}";
        value = {
          enable = true;
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          path = with pkgs; [ go git direnv ];

          serviceConfig = {
            Type = "simple";
            # For now, auth none is fine because it's proxied behind teleport which handles auth/access.
            ExecStart = "${pkgs.code-server}/bin/code-server --auth none --bind-addr 127.0.0.1:${toString n.snd}";
            WorkingDirectory = "/home/${n.fst}";
            NoNewPrivileges = "true";
            User = n.fst;
            Group = "users";
          }; 
        };
      };
      teleport-app = {
        name = "code-server-${n.fst}";
        uri = "http://127.0.0.1:${toString n.snd}";
        labels = {
          user = n.fst;
        };
      };
    })
    zippedConfig;

  mkUserAttrs = userList: builtins.listToAttrs (builtins.map (x: x.user) userList);
  mkCodeServerAttrs = userList: builtins.listToAttrs (builtins.map (x: x.code-server) userList);
  mkTeleportApps = userList: builtins.map (x: x.teleport-app) userList;
  userList = mkUserList config;
in
{
  config = {
    users.users = mkUserAttrs userList;
    systemd.services = mkCodeServerAttrs userList;
    # This should very much not live here.
    services.teleport.settings = {
      app_service = {
        enabled = "yes";
        apps = mkTeleportApps userList;
      };
    };
  };
}
