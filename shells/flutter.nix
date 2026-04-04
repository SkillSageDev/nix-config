{ pkgs }:

let
  androidEnv = pkgs.androidenv.override { licenseAccepted = true; };

  androidComposition = androidEnv.composeAndroidPackages {
    # ── Toolchain versions ────────────────────────────────────────────────────
    cmdLineToolsVersion = "8.0"; # keep ≤8.0; avdmanager breaks on newer
    platformToolsVersion = "36.0.2"; # latest stable in current nixpkgs pin
    buildToolsVersions = [
      "28.0.3" # aapt2 override canonical version (NixOS wiki); also flutter doctor req
      "33.0.2" # widely used baseline
      "34.0.0" # Flutter 3.x default compileSdk
      "35.0.0" # AGP 8.4+
      "36.0.0" # AGP 8.7+, required for compileSdk 36
    ];
    platformVersions = [
      "33"
      "34"
      "35"
      "36"
    ];
    # NOTE: due to nixpkgs bug #472561, "36" gets installed as android-36.1.
    # The shellHook below works around this with a symlink in the writable overlay.
    abiVersions = [ "x86_64" ];
    # On an ARM workstation replace "x86_64" with "arm64-v8a"

    # ── Emulator ──────────────────────────────────────────────────────────────
    includeEmulator = true;
    emulatorVersion = "36.3.10"; # matches current nixpkgs pin (was showing 36.3.10.0)
    includeSystemImages = true;
    systemImageTypes = [
      "google_apis"
      "google_apis_playstore"
    ];
    useGoogleAPIs = true;

    includeNDK = false;

    extraLicenses = [
      "android-googletv-license"
      "android-sdk-arm-dbt-license"
      "android-sdk-license"
      "android-sdk-preview-license"
      "google-gdk-license"
      "intel-android-extra-license"
      "intel-android-sysimage-license"
      "mips-android-sysimage-license"
    ];
  };

  androidSdk = androidComposition.androidsdk;

  # The aapt2 override path must match a version that IS in buildToolsVersions
  # above AND exists in your project's build.gradle as buildToolsVersion.
  # 35.0.0 is the safe default; change to 36.0.0 if your project targets SDK 36.
  aapt2BuildToolsVersion = "35.0.0";

in
pkgs.mkShell rec {

  # ── Environment variables ──────────────────────────────────────────────────

  # These initially point at the Nix store. The shellHook below overrides them
  # to point at a writable overlay directory.
  ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
  ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";

  CHROME_EXECUTABLE = "google-chrome-stable";
  JAVA_HOME = pkgs.jdk21.home;
  FLUTTER_ROOT = "${pkgs.flutter}";
  DART_ROOT = "${pkgs.flutter}/bin/cache/dart-sdk";

  # Force Gradle to use the Nix-store aapt2 binary instead of downloading one.
  # Without this, AGP tries to download aapt2, which fails because the Nix
  # sandbox has no internet access during builds.
  # NOTE: nixpkgs issue #402297 tracks that this approach has edge cases with
  # newer AGP versions. If you hit aapt2 errors, try changing the version below
  # to match your project's buildToolsVersion exactly.
  GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidSdk}/libexec/android-sdk/build-tools/${aapt2BuildToolsVersion}/aapt2";

  # Try Wayland first, fall back to X11 (xcb).
  # The emulator's bundled Qt doesn't support Wayland, so it always uses XWayland.
  QT_QPA_PLATFORM = "wayland;xcb";

  # ── Build inputs ───────────────────────────────────────────────────────────
  buildInputs = with pkgs; [
    androidSdk
    flutter
    gradle
    jdk21
    protobuf
    buf
    pandoc
    libsecret.dev
    gtk3.dev
    grpcurl
    google-chrome
    chromedriver
    pkg-config
    mesa-demos # provides eglinfo — fixes "Unable to access driver information"
  ];

  # Vulkan and OpenGL shared libs are required for the emulator's hardware decoding.
  LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (
    with pkgs;
    [
      vulkan-loader
      libGL
    ]
  );

  CMAKE_PREFIX_PATH = pkgs.lib.makeLibraryPath (
    with pkgs;
    [
      libsecret.dev
      gtk3.dev
    ]
  );

  # ── Shell hook ─────────────────────────────────────────────────────────────
  shellHook = ''
    # ── Writable SDK overlay ───────────────────────────────────────────────────
    # The Nix store is read-only, so two things break without this:
    #   1. `flutter doctor --android-licenses` cannot write to $ANDROID_HOME/licenses/
    #   2. The `android-36` platform directory is named `android-36.1` due to
    #      nixpkgs bug #472561, and Flutter/Gradle look for the name `android-36`.
    #
    # Solution: create a writable overlay directory that symlinks everything from
    # the Nix store SDK, except licenses/ (which is its own real writable dir),
    # and add a `android-36` symlink pointing at `android-36.1`.

    _NIX_ANDROID_SDK="${androidSdk}/libexec/android-sdk"
    _OVERLAY="$HOME/.android-sdk-nix"

    # Rebuild the overlay if the underlying Nix store path has changed
    # (i.e. after a nix flake update that changed the SDK derivation).
    if [ ! -f "$_OVERLAY/.nix-sdk-path" ] || \
       [ "$(cat "$_OVERLAY/.nix-sdk-path" 2>/dev/null)" != "$_NIX_ANDROID_SDK" ]; then

      echo "nix-flutter: rebuilding writable SDK overlay at $_OVERLAY ..."
      rm -rf "$_OVERLAY"
      mkdir -p "$_OVERLAY"

      # Symlink every top-level SDK item except licenses/
      for _item in "$_NIX_ANDROID_SDK"/*/; do
        _name="$(basename "$_item")"
        if [ "$_name" != "licenses" ]; then
          ln -sf "$_item" "$_OVERLAY/$_name"
        fi
      done

      # Create a real writable licenses directory, pre-seeded with the Nix-store
      # licenses (licenseAccepted = true already wrote them there).
      mkdir -p "$_OVERLAY/licenses"
      if [ -d "$_NIX_ANDROID_SDK/licenses" ]; then
        cp "$_NIX_ANDROID_SDK/licenses/"* "$_OVERLAY/licenses/" 2>/dev/null || true
      fi

      # Workaround for nixpkgs bug #472561:
      # platformVersions = ["36"] installs into android-36.1, not android-36.
      # Flutter and Gradle resolve the target by the directory name.
      if [ -d "$_OVERLAY/platforms/android-36.1" ] && \
         [ ! -e "$_OVERLAY/platforms/android-36" ]; then
        # platforms/ is a symlink into the Nix store (read-only), so we need
        # a real directory here too.
        _REAL_PLATFORMS="$_OVERLAY/platforms-rw"
        mkdir -p "$_REAL_PLATFORMS"
        for _p in "$_NIX_ANDROID_SDK/platforms"/*/; do
          ln -sf "$_p" "$_REAL_PLATFORMS/$(basename "$_p")"
        done
        # Add the missing android-36 alias
        ln -sf "$_REAL_PLATFORMS/android-36.1" "$_REAL_PLATFORMS/android-36"
        # Replace the platforms symlink with our real directory
        rm "$_OVERLAY/platforms"
        ln -sf "$_REAL_PLATFORMS" "$_OVERLAY/platforms"
      fi

      # Record which Nix store path this overlay was built from.
      echo "$_NIX_ANDROID_SDK" > "$_OVERLAY/.nix-sdk-path"
      echo "nix-flutter: overlay ready."
    fi

    # Point all Android tools at the writable overlay.
    export ANDROID_HOME="$_OVERLAY"
    export ANDROID_SDK_ROOT="$_OVERLAY"

    # Update GRADLE_OPTS to use the overlay path (aapt2 is still the Nix binary
    # via the symlink, but the path string must match ANDROID_HOME).
    export GRADLE_OPTS="-Dorg.gradle.project.android.aapt2FromMavenOverride=$ANDROID_HOME/build-tools/${aapt2BuildToolsVersion}/aapt2"

    # ── Dart pub global binaries ───────────────────────────────────────────────
    if [ -z "$PUB_CACHE" ]; then
      export PATH="$PATH:$HOME/.pub-cache/bin"
    else
      export PATH="$PATH:$PUB_CACHE/bin"
    fi

    # Install the protoc Dart plugin so `protoc --dart_out` works.
    dart pub global activate protoc_plugin

    # ── Accepting licenses ─────────────────────────────────────────────────────
    # licenseAccepted = true in androidenv.override pre-seeds known licenses, but
    # flutter doctor may still ask you to run:
    #
    #   yes | flutter doctor --android-licenses
    #
    # This now works because ANDROID_HOME points at the writable overlay.
  '';
}
