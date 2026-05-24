{
  programs.bash = {
    enable = true;
    bashrcExtra = ''
      eval "$(direnv hook bash)"
      eval "$(devenv hook bash)"
    '';
  };
}
