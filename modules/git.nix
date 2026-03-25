{ osConfig, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "cat ${osConfig.sops.secrets.git_username.path}";
	email = "cat ${osConfig.sops.secrets.git_email.path}";
      };

      init.defaultBranch = "main";

    };

  };
}
