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

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "wluma";
  # Unreleased. Tracks upstream `main`, which is well ahead of the 4.11.1 in
  # nixpkgs: the adaptive predictor generalises across the whole ALS range
  # instead of matching one bucket exactly, config is auto-discovered, and
  # there is a real CLI. Bump `rev`/`hash`/`cargoHash` together to update.
  version = "4.11.1-unstable-2026-08-18";

  src = fetchFromGitHub {
    owner = "maximbaz";
    repo = "wluma";
    rev = "f29d5ef9d1b9d8fbd8f13d9cf444258362978a83";
    hash = "sha256-xFBmeJ2IiVZKXeV6RxThU/QwjnQlRppu67rxE/VI2Vs=";
  };

  # build.rs derives the version from `git describe`, which cannot work from a
  # source tarball, so hand it the version directly.
  env.WLUMA_VERSION = finalAttrs.version;

  postPatch = ''
    # Needs chmod and chgrp
    substituteInPlace 90-wluma-backlight.rules --replace-fail \
      'RUN+="/bin/' 'RUN+="${coreutils}/bin/'

    substituteInPlace wluma.service --replace-fail \
      'ExecStart=/usr/bin/wluma' 'ExecStart=${placeholder "out"}/bin/wluma'
  '';

  cargoHash = "sha256-9TEC2+GcPXWfGTU/KTu6LSGbjAkWchPRBalmOkg9PI4=";

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
