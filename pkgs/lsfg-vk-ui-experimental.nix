{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  glib,
  pango,
  gdk-pixbuf,
  gtk4,
  libadwaita,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "lsfg-vk-ui-experimental";
  version = "2.0.0-dev28-experimental.25";

  src = fetchFromGitHub {
    owner = "eugeniosegala";
    repo = "lsfg-vk-experimental";
    tag = "v${finalAttrs.version}";
    hash = "";
  };

  cargoHash = "";

  sourceRoot = "source/ui";

  nativeBuildInputs = [
    pkg-config
    glib
  ];

  buildInputs = [
    pango
    gdk-pixbuf
    gtk4
    libadwaita
  ];

  postInstall = ''
    install -Dm444 $src/ui/rsc/gay.pancake.lsfg-vk-ui.desktop $out/share/applications/gay.pancake.lsfg-vk-ui-experimental.desktop
    install -Dm444 $src/ui/rsc/icon.png $out/share/icons/hicolor/256x256/apps/gay.pancake.lsfg-vk-ui-experimental.png
  '';

  meta = {
    description = "Graphical configuration interface for lsfg-vk-experimental";
    homepage = "https://github.com/eugeniosegala/lsfg-vk-experimental/";
    changelog = "https://github.com/eugeniosegala/lsfg-vk-experimental/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ nyebulosa ];
    mainProgram = "lsfg-vk-ui-experimental";
  };
})
