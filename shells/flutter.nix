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
    libsysprof-capture
    ninja
    pcre2
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

}
