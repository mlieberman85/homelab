# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs,... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./common.nix
      ./vscode.nix
      ./teleport.nix
      ./tailscale.nix 
      ./code-server.nix
      ./users.nix
    ];
  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.networkmanager.enable = true;

  networking.useDHCP = false;
  networking.interfaces.enp6s0.useDHCP = true;
  networking.interfaces.wlp5s0.useDHCP = true;

  # Having GNOME is useful for debugging when I do have to physically access the server
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  
  environment.systemPackages = with pkgs; [
     vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
     wget
     firefox
     home-manager
     pinentry-curses
   ];
  
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  system.stateVersion = "21.11"; # Did you read the comment?
    # make the tailscale command usable to users

  
  networking.firewall = {
    # enable the firewall,
    enable = true;

    # always allow traffic from your Tailscale network
    trustedInterfaces = [ "tailscale0" ];

    # allow the Tailscale UDP port through the firewall
    allowedUDPPorts = [ config.services.tailscale.port ];

    # allow you to SSH in over the public internet
    allowedTCPPorts = [ 22 80 443 25565 3022 3023 3024 3025 3080 3026 3027 3028 3036 8080 ];
  };

  # Most users should be coming through teleport but if that is failing, need a local user to fix stuff.
  users.users.mlieberman = {
    isNormalUser = true;
    home = "/home/mlieberman";
    description = "Mike Lieberman";
    extraGroups = [ "wheel" "networkmanager" "tss" ];
    shell = pkgs.bash;
  };

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
  services.nginx.enable = true;
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "mlieberman85@gmail.com";  
  security.tpm2 = {
    enable = true;
    abrmd.enable = true;
  };

  services.pcscd.enable = true;
  programs.gnupg.agent = {
   enable = true;
   pinentryFlavor = "curses";
   enableSSHSupport = true;
 };
}

