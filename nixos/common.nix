{lib, ...}:
with lib;
{
  options = {
    common = mkOption {
        default = {
        domain = "dev.bonesquad.rodeo";
        tailscale = {
          # single use key so doesn't really matter if it ends up in the store
          authkey = "tskey-REPLACE-ME"; 
        };
        type = types.attrset;
      };
    };
  };
}
