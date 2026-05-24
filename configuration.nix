# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  nixpkgs,
  devenv,
  ...
}:

let
  locale = "en_US.UTF-8";
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  # services.gnome.gnome-keyring.enable = true;

  networking.nat = {
    enable = true;
    internalInterfaces = [ "virbr0" ];
    externalInterface = "wlp8s0"; # Your Wi-Fi card
    forwardPorts = [
      {
        sourcePort = 8080;
        destination = "192.168.122.32:80";
        proto = "tcp";
      }
    ];
  };

  networking.firewall = {
    enable = true;
    allowPing = true;
    allowedTCPPorts = [ 8080 ]; # Opens the "front door" on your PC
    trustedInterfaces = [ "virbr0" ];
    checkReversePath = false; # Fixes the "no response" packet drop
  };

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other.
    };
  };

  programs.localsend.enable = true;

  services.samba = {
    enable = true;
    securityType = "user";
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "smbnix";
        "netbios name" = "smbnix";
        "security" = "user";
        #"use sendfile" = "yes";
        #"max protocol" = "smb2";
        # note: localhost is the ipv6 localhost ::1
        "hosts allow" = "192.168.1. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      "public" = {
        "path" = "/home/skill_sage/Desktop/PSU/";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        # "force user" = "username";
        # "force group" = "groupname";
      };
      "private" = {
        "path" = "/home";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "skill_sage";
        # "force group" = "groupname";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  programs.dconf.enable = true;

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
      };
    };
    spiceUSBRedirection.enable = true;
  };

  services.spice-vdagentd.enable = true;
  programs.virt-manager.enable = true;

  # nix.package = pkgs.nixVersions.nix_2_34;

  security.polkit.enable = true;
  services.udisks2.enable = true;

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id.startsWith("org.freedesktop.udisks2.") &&
          subject.isInGroup("users")) {
        return polkit.Result.YES;
      }
    });
  '';

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ kdePackages.xdg-desktop-portal-kde ];
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.consoleMode = "max";
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-9dac2855-d74a-4d0d-8d41-c0e4088d46b2".device =
    "/dev/disk/by-uuid/9dac2855-d74a-4d0d-8d41-c0e4088d46b2";
  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Africa/Cairo";

  # Select internationalisation properties.
  i18n.defaultLocale = locale;

  i18n.extraLocales = [
    "en_US.UTF-8/UTF-8"
    "ar_SA.UTF-8/UTF-8"
  ];

  i18n.extraLocaleSettings = {
    LC_ADDRESS = locale;
    LC_IDENTIFICATION = locale;
    LC_MEASUREMENT = locale;
    LC_MONETARY = locale;
    LC_NAME = locale;
    LC_NUMERIC = locale;
    LC_PAPER = locale;
    LC_TELEPHONE = locale;
    LC_TIME = locale;
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  # services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Install niri
  services.displayManager.defaultSession = "niri";
  programs.xwayland.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us,ara";
    variant = "";
    options = "grp:alt_shift_toggle";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    wireplumber.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  hardware.bluetooth.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  fonts = {
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "JetBrainMono Nerd Font" ];
      };

    };

    packages = with pkgs; [
      font-awesome

      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      noto-fonts

      nerd-fonts.symbols-only
      nerd-fonts.jetbrains-mono
    ];

  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.skill_sage = {
    isNormalUser = true;
    description = "Skill Sage";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "samba"
      "podman"
    ];
    packages = with pkgs; [
      kdePackages.kate
      neovim
      #      (nerdfonts.override { fonts = [ "Noto" ]; })
      #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    trusted-public-keys = [
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    ];
    substituters = [
      "https://devenv.cachix.org"
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    btop
    fd
    xremap
    timeshift
    git
    sops
    age
    github-desktop
    eza
    obsidian
    godot
    libreoffice-qt-fresh
    hunspell
    qimgv
    zathura
    imv
    gparted-full
    gnome-disk-utility
    polkit_gnome
    obs-studio
    mpv
    handbrake
    dive
    podman-tui
    podman-compose
    unrar
    bat
    anki
    unzip
    devenv.packages.${pkgs.system}.default

    # niri required packages
    mako
    gnome-keyring
    xdg-desktop-portal-gtk
    xdg-desktop-portal-gnome
    fuzzel
    kdePackages.polkit-kde-agent-1
    xwayland-satellite
    alacritty
    nixfmt
    nixd
  ];

  # nixd, make sure it uses nixpkgs flake
  nix.nixPath = [ "nixpkgs=${nixpkgs}" ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  programs.ssh.startAgent = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
