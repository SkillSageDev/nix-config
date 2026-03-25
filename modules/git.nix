{ config, osConfig, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      # FIXME: known bug, nixos fails to decrypt the secrets when rebuilding.
      user = {
        name = osConfig.sops.secrets.git_username.path;
	email = osConfig.sops.secrets.git_email.path;
      };

      init.defaultBranch = "main";

    };

  };
}
