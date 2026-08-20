{
  lib,
  fetchFromGitHub,
  stdenv,
  cmake,
  ninja,
  qt6,
  vulkan-headers,
}:
# So apparently the new UI is qt6 and c++ instead of rust and gtk4
# The UI is not a standalone cmake project, it's a subdirectory of the root
# one and links against lsfg-vk-common/lsfg-vk-backend, so configure from the
# repo root with LSFGVK_BUILD_UI on (it defaults to off).

stdenv.mkDerivation (finalAttrs: {
  pname = "lsfg-vk-ui-experimental";
  version = "2.0.0-dev28-experimental.25";

  src = fetchFromGitHub {
    owner = "eugeniosegala";
    repo = "lsfg-vk-experimental";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KuMP/qRpcLwLBJ03ZpLfK4ywyiDZISAskJ/r5iDOS2o=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
    vulkan-headers
  ];

  cmakeFlags = [
    (lib.cmakeBool "LSFGVK_BUILD_UI" true)
    (lib.cmakeBool "LSFGVK_BUILD_VK_LAYER" false)
    (lib.cmakeBool "LSFGVK_BUILD_CLI" false)
    # lsfg-vk-backend is only added to the build under this or BUILD_VK_LAYER
    (lib.cmakeBool "LSFGVK_INSTALL_DEVELOP" true)
    # left off so the xdg files can carry the -experimental suffix below
    (lib.cmakeBool "LSFGVK_INSTALL_XDG_FILES" false)
    (lib.cmakeBool "BUILD_TESTING" false)
  ];

  postInstall = ''
    # INSTALL_DEVELOP is only on to get lsfg-vk-backend built, drop its output
    rm -rf $out/lib $out/include

    install -Dm444 $src/lsfg-vk-ui/rsc/gay.pancake.lsfg-vk-ui.desktop $out/share/applications/gay.pancake.lsfg-vk-ui-experimental.desktop
    install -Dm444 $src/lsfg-vk-ui/rsc/gay.pancake.lsfg-vk-ui.png $out/share/icons/hicolor/256x256/apps/gay.pancake.lsfg-vk-ui-experimental.png

    # the icon got renamed above, point the desktop entry at the new name
    substituteInPlace $out/share/applications/gay.pancake.lsfg-vk-ui-experimental.desktop \
      --replace-fail "Icon=gay.pancake.lsfg-vk-ui" "Icon=gay.pancake.lsfg-vk-ui-experimental"
  '';

  meta = {
    description = "Graphical configuration interface for lsfg-vk-experimental";
    homepage = "https://github.com/eugeniosegala/lsfg-vk-experimental/";
    changelog = "https://github.com/eugeniosegala/lsfg-vk-experimental/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ nyebulosa ];
    mainProgram = "lsfg-vk-ui";
  };
})
