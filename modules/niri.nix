{ niri, osConfig, ... }:

{
  imports = [ niri.homeModules.niri ];

  programs.niri = {
    enable = true;

    settings = import ./niri-settings.nix;

	#    settings = {
	#      spawn-at-startup = [
	#        { sh =  "qs -c noctalia-shell"; }
	#      ];
	#
	#      input = {
	#        keyboard.numlock = true;
	#
	# touchpad.tap = true;
	# touchpad.natural-scroll = true;
	#
	#      };
	#
	#      layout = {
	#        gaps = 16;
	#      };
	#    };
	#
  };
}
