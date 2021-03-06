{ pkgs, ... }:

let
  extensions = (with pkgs.vscode-extensions; [
      bbenoist.nix
      ms-python.python
      ms-azuretools.vscode-docker
      ms-vscode-remote.remote-ssh
    ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [{
      name = "remote-ssh-edit";
      publisher = "ms-vscode-remote";
      version = "0.47.2";
      sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
  }];
  vscode-with-extensions = pkgs.vscode-with-extensions.override {
      vscodeExtensions = extensions;
    };
in {
  config = {
    environment.systemPackages = [
      vscode-with-extensions
    ];
  };
}
