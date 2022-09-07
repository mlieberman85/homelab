{ pkgs, ... }:

{
  config = {
    services.teleport.enable = true;
    services.teleport.settings = {
      version = "v2";
      teleport = {
        nodename = "nixos";
        data_dir = "/var/lib/teleport";
        log = {
          output = "stderr";
          severity = "DEBUG";
          format = {
            output = "text";
          };
        };
        ca_pin = [ ];
        diag_addr = "";
      };
      auth_service = {
        enabled = "yes";
        listen_addr = "0.0.0.0:3025";
        proxy_listener_mode = "multiplex";
      };
      ssh_service = {
        enabled = "yes";
        labels = {
          env = "example";
        };
        commands = [
          {
            name = "hostname";
            command = [ "/run/current-system/sw/bin/hostname" ];
            period = "1m0s";
          }
        ];
        # FIXME: Teleport Nix package currently doesn't include PAM support 
        #pam = {
        #  enabled = true;
        #  service_name = "teleport";
        #};
      };
      proxy_service = {
        enabled = "yes";
        https_keypairs = [ ];
        acme = {
          enabled = "yes";
          email = "mlieberman85@gmail.com";
        };
        proxy_protocol = "on";
        web_listen_addr = "0.0.0.0:443";
        tunnel_listen_addr = "0.0.0.0:3024";
        public_addr = "dev.bonesquad.rodeo:443";
        #ssh_public_addr = "dev.bonesquad.rodeo:3023";
      };
      app_service.apps = [{
        labels = {
          group = "guac";
        };
        name = "guac-neo4j";
        uri = "http://localhost:7474";
      }];
    };
    systemd.services.manage-teleport-users = {
      enable = false;
      path = [ pkgs.bash pkgs.teleport pkgs.nixos-rebuild pkgs.gawk ];
      script = ''
        /home/mlieberman/Projects/homelab/scripts/get-teleport-users.sh > /tmp/users.json;
        nixos-rebuild switch -I nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos -I nixos-config=/home/mlieberman/Projects/homelab/nixos/configuration.nix
      '';

      wantedBy = [ "default.target" ];
    };

    systemd.timers.backup = {
      wantedBy = [ "timers.target" ];
      partOf = [ "manage-teleport-users.service" ];
      timerConfig = {
        Unit = "manage-teleport-users.service";
        OnCalendar = "*-*-* *:*:00";
      };
    };


    environment.systemPackages = [
      pkgs.teleport
    ];
  };
}
