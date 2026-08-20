{
  lib,
  fetchFromGitHub,
  cmake,
  vulkan-headers,
  llvmPackages,
  libx11,
  # qt6,
}:

llvmPackages.stdenv.mkDerivation (finalAttrs: {
  pname = "lsfg-vk-experimental";
  version = "2.0.0-dev28-experimental.25";

  src = fetchFromGitHub {
    owner = "eugeniosegala";
    repo = "lsfg-vk-experimental";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KuMP/qRpcLwLBJ03ZpLfK4ywyiDZISAskJ/r5iDOS2o=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace dist/local/layer_json.json \
      --replace-fail "liblsfg-vk-layer.so" "$out/lib/liblsfg-vk-layer.so"
  '';

  nativeBuildInputs = [
    llvmPackages.clang-tools
    llvmPackages.libllvm
    cmake
    libx11
    # qt6.wrapQtAppsHook
  ];

  buildInputs = [
    vulkan-headers
    # qt6.qtBase
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_CXX_COMPILER=clang++"
    "-DLSFGVK_BUILD_UI=On"
    "-DLSFGVK_INSTALL_XDG_FILES=On"
  ];

  postInstall = ''
    install -Dm444 $src/lsfg-vk-ui/rsc/gay.pancake.lsfg-vk-ui.desktop $out/share/applications/gay.pancake.lsfg-vk-ui-experimental.desktop
    install -Dm444 $src/lsfg-vk-ui/rsc/gay.pancake.lsfg-vk-ui.png $out/share/icons/hicolor/256x256/apps/gay.pancake.lsfg-vk-ui-experimental.png
  '';

  meta = {
    description = "Vulkan layer for frame generation (Requires owning Lossless Scaling)";
    homepage = "https://github.com/eugeniosegala/lsfg-vk-experimental";
    changelog = "https://github.com/eugeniosegala/lsfg-vk-experimental/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ nyebulosa ];
  };
})
