{
  # Disable systemd-oomd to prevent desktop crashes via sysc-greet
  systemd.oomd.enable = false;

  # 1. Enable and tune Earlyoom specifically for your Wayland/Niri stack
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5; # Kill individual apps when RAM hits 5% remaining
    freeSwapThreshold = 5; # Kill individual apps when Swap hits 5% remaining
    extraArgs = [
      "-g" # Kill the entire process group of the offender
      "--prefer '^(electron|chrome|firefox|discord|slack|vlc)$'" # Target browsers and heavy apps first
      "--avoid '^(niri|sysc-greet|Xwayland|systemd|dbus-daemon)$'" # PROTECT your compositor and greeter
    ];
  };

  # 2. Setup zRAM compression for faster memory handling
  zramSwap = {
    enable = true;
    memoryPercent = 50; # Compresses up to 50% of your RAM dynamically
    priority = 999; # Tells the kernel to favor zRAM over physical disk swap
  };

  # 3. Restrict Nix flake builds from eating 100% of your system RAM
  systemd.services.nix-daemon.serviceConfig = {
    MemoryHigh = "85%"; # Throttles the builder at 85% RAM usage
    MemoryMax = "90%"; # Kills the isolated build process if it crosses 90%
  };
}
