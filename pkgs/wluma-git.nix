{
  lib,
  fetchFromGitHub,
  makeWrapper,
  rustPlatform,
  marked-man,
  coreutils,
  vulkan-loader,
  wayland,
  pkg-config,
  udev,
  v4l-utils,
  dbus,
  pipewire,
}:

# To be honest I was tired and most of this file is vibe coded or at least heavily AI assisted.
# Will code this myself in other moment.
#
# The rest of the repo is mine, my code. Bad and beautiful spaghetti.

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "wluma";
  version = "4.11.1-unstable-2026-08-19";

  src = fetchFromGitHub {
    owner = "maximbaz";
    repo = "wluma";
    rev = "f543a2f9d53b0efa83499a22bb9293f51a01ff90";
    hash = "sha256-wTjU6t9Wa4CSXvpDlKB+uJ8oru01BsVDwbAb0bOLZk4=";
  };

  env.WLUMA_VERSION = finalAttrs.version;

  postPatch = ''
    # Needs chmod and chgrp
    substituteInPlace 90-wluma-backlight.rules --replace-fail \
      'RUN+="/bin/' 'RUN+="${coreutils}/bin/'

    substituteInPlace wluma.service --replace-fail \
      'ExecStart=/usr/bin/wluma' 'ExecStart=${placeholder "out"}/bin/wluma'

    # Neither of these is exposed in config.toml, and both defaults are tuned for
    # backlights with far fewer steps than this 65535-step amdgpu panel. Kept as
    # small a departure as fixes the twitchiness. `--replace-fail` is deliberate:
    # if a rev bump moves these constants the build breaks instead of silently
    # dropping the tuning.

    # Deadband before a new prediction is acted on, as max_brightness/STEPS.
    # 1000 means 0.1% (66 of 65535), so almost any luma flicker retriggers a
    # transition. 200 gives 0.5%.
    substituteInPlace src/brightness/backlight.rs --replace-fail \
      'const BRIGHTNESS_STEPS: u64 = 1000;' 'const BRIGHTNESS_STEPS: u64 = 200;'

    # Total ramp length. Steps are 16ms, so the 200ms default crosses a large
    # jump in ~13 visible chunks. 500ms gives ~32 and still lands quickly.
    substituteInPlace src/brightness/controller.rs --replace-fail \
      'const TRANSITION_MAX_MS: u64 = 200;' 'const TRANSITION_MAX_MS: u64 = 500;'
  '';

  cargoHash = "sha256-9TEC2+GcPXWfGTU/KTu6LSGbjAkWchPRBalmOkg9PI4=";

  # This test hardcodes step counts derived from the upstream TRANSITION_MAX_MS
  # (e.g. it expects a 413-unit jump to take 413.div_ceil(200) = 3 steps), so any
  # retuning of that constant above fails it. The other 147 tests still run.
  checkFlags = [
    "--skip=brightness::controller::tests::test_update_target_finds_minimal_step_that_reaches_target_within_transition_duration"
  ];

  nativeBuildInputs = [
    makeWrapper
    pkg-config
    rustPlatform.bindgenHook
    marked-man
  ];

  buildInputs = [
    udev
    v4l-utils
    vulkan-loader
    dbus
    pipewire
  ];

  postInstall = ''
    wrapProgram $out/bin/wluma \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ wayland ]}"
  '';

  meta = {
    description = "Automatic brightness adjustment based on screen contents and ALS";
    homepage = "https://github.com/maximbaz/wluma";
    license = lib.licenses.isc;
    platforms = lib.platforms.linux;
    mainProgram = "wluma";
  };
})
