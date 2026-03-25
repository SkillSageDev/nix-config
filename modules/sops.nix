{ sops-nix, ... }:

{
  imports = [ sops-nix.nixosModules.default ];

  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    validateSopsFiles = false;

    age = {
      keyFile = "/home/skill_sage/.config/sops/age/key.txt";
      generateKey = true;
    };

    secrets = {
      git_username = {};
      git_email = {};
    };
  };
}
