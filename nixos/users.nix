{ pkgs, ...}:

let 
  # TODO: Figure out better way to manage below.
  usersFile = if builtins.pathExists /tmp/users.json then /tmp/users.json else null;
  config = if isNull usersFile then [] else builtins.fromJSON (builtins.readFile usersFile);
  mkUserList = userConfig: builtins.map (n: {
    name = n;
    value = {
      isNormalUser = true;
      home = "/home/${n}";
      shell = pkgs.bash;
    };
  }) userConfig;

  mkUserAttrs = userList: builtins.listToAttrs userList;
in
{
  config = {
    users.users = mkUserAttrs (mkUserList config);
  };
}
