{ pkgs }:

let
  patchedFlutter = pkgs.flutter.overrideAttrs (prevAttrs: {
    passthru = prevAttrs.passthru // {
      sdk = patchedFlutter;
    };
  });

  androidEnv = pkgs.androidenv.override { licenseAccepted = true; };

  androidComposition = androidEnv.composeAndroidPackages {
    # ── Toolchain versions ────────────────────────────────────────────────────
    cmdLineToolsVersion = "8.0"; # keep ≤8.0; avdmanager breaks on newer
    platformToolsVersion = "36.0.1"; # latest stable in current nixpkgs pin
    buildToolsVersions = [
      "28.0.3" # aapt2 override canonical version (NixOS wiki); also flutter doctor req
      "33.0.2" # widely used baseline
      "34.0.0" # Flutter 3.x default compileSdk
      "35.0.0" # AGP 8.4+
      "36.0.0" # AGP 8.7+, required for compileSdk 36
    ];
    # error: The version 36.0.2 is missing in package platform-tools.
    #    The only available versions are 34.0.5, 35.0.1, 35.0.2, 36.0.0, 36.0.1.

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
    #     error: The version 36.3.10 is missing in package emulator.
    # The only available versions are 32.1.15, 33.1.20, 34.1.19, 34.1.9, 34.2.11, 34.2.16, 35.1.19, 35.1.2, 35.1.3, 35.1.4, 35.2.5, 35.3.11, 35.3.12, 35.4.8, 35.4.9, 35.5.10, 35.5.2, 35.5.3, 35.5.8, 35.6.2, 35.6.9, 36.1.2, 36.1.8, 36.1.9, 36.2.4.
    includeEmulator = true;
    emulatorVersion = "36.2.4"; # matches current nixpkgs pin (was showing 36.3.10.0)
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
  # FLUTTER_ROOT = "${patchedFlutter}"; # was pkgs.flutter
  FLUTTER_ROOT = "$HOME/.cache/flutter-writable-root"; # override the static one
  DART_ROOT = "${patchedFlutter}/bin/cache/dart-sdk"; # was pkgs.flutter
  # ── Environment variables ──────────────────────────────────────────────────

  # These initially point at the Nix store. The shellHook below overrides them
  # to point at a writable overlay directory.
  ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
  ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";

  CHROME_EXECUTABLE = "google-chrome-stable";
  # SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
  JAVA_HOME = pkgs.jdk17.home;
  # FLUTTER_ROOT = "${pkgs.flutter}";
  # DART_ROOT = "${pkgs.flutter}/bin/cache/dart-sdk";

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
    # flutter
    patchedFlutter
    gradle
    jdk17
    protobuf
    buf
    pandoc
    libsecret.dev
    gtk3.dev
    grpcurl
    google-chrome
    chromedriver
    pkg-config
    libsysprof-capture
    ninja
    pcre2
    util-linux.dev
    mesa-demos # provides eglinfo — fixes "Unable to access driver information"
    libselinux
    libsepol
    firebase-tools
    openssl
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
  shellHook = ''
    # ── Writable Flutter root ────────────────────────────────────────────────
    NIX_FLUTTER="${patchedFlutter}"
    WRITABLE_FLUTTER="$HOME/.cache/flutter-writable-root"

    if [ ! -d "$WRITABLE_FLUTTER/bin/cache" ]; then
      echo "Setting up writable Flutter root..."
      mkdir -p "$WRITABLE_FLUTTER"

      # Symlink everything except bin
      for item in "$NIX_FLUTTER"/*; do
        name=$(basename "$item")
        [ "$name" = "bin" ] && continue
        ln -sfn "$item" "$WRITABLE_FLUTTER/$name"
      done

      # Symlink bin contents except cache
      mkdir -p "$WRITABLE_FLUTTER/bin"
      for item in "$NIX_FLUTTER/bin"/*; do
        name=$(basename "$item")
        [ "$name" = "cache" ] && continue
        ln -sfn "$item" "$WRITABLE_FLUTTER/bin/$name"
      done

      # Writable cache — copy whatever nix pre-populated
      mkdir -p "$WRITABLE_FLUTTER/bin/cache"
      cp -rn "$NIX_FLUTTER/bin/cache/." "$WRITABLE_FLUTTER/bin/cache/" 2>/dev/null || true
    fi

    export FLUTTER_ROOT="$WRITABLE_FLUTTER"
    export DART_ROOT="$WRITABLE_FLUTTER/bin/cache/dart-sdk"
    export PATH="$WRITABLE_FLUTTER/bin:$PATH"

    # Populate engine artifacts into the writable cache
    flutter precache --android --suppress-analytics 2>/dev/null || true

    ulimit -c 0          # no more core dumps
    sudo sysctl -w vm.swappiness=10 2>/dev/null || true

    if [ -z "$PUB_CACHE" ]; then
      export PATH="$PATH:$HOME/.pub-cache/bin"
    else
      export PATH="$PATH:$PUB_CACHE/bin"
    fi

    dart pub global activate protoc_plugin
    dart pub global activate flutterfire_cli

    export SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt
    export NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt

    ln -sf /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-bundle.crt
  '';
}
