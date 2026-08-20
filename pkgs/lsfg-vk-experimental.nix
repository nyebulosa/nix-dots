{
  lib,
  fetchFromGitHub,
  cmake,
  vulkan-headers,
  vulkan-loader,
  llvmPackages,
  libx11,
  qt6,
}:

llvmPackages.stdenv.mkDerivation (finalAttrs: {
  pname = "lsfg-vk-experimental";
  version = "2.0.0-dev28-experimental.25";

  src = fetchFromGitHub {
    owner = "eugeniosegala";
    repo = "lsfg-vk-experimental";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KuMP/qRpcLwLBJ03ZpLfK4ywyiDZISAskJ/r5iDOS2o=";
  };

  nativeBuildInputs = [
    llvmPackages.clang-tools
    llvmPackages.libllvm
    cmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
    vulkan-headers
    vulkan-loader
    libx11
  ];

  qtWrapperArgs =
    let
      runtimeLibs = [
        vulkan-loader
      ];
    in
    [
      "--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs}"
    ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DLSFGVK_BUILD_UI=On"
    "-DLSFGVK_INSTALL_XDG_FILES=On"
    "-DLSFGVK_LAYER_LIBRARY_PATH=${placeholder "out"}/lib/liblsfg-vk-layer.so"
  ];

  meta = {
    description = "Vulkan layer for frame generation (Requires owning Lossless Scaling)";
    homepage = "https://github.com/eugeniosegala/lsfg-vk-experimental";
    changelog = "https://github.com/eugeniosegala/lsfg-vk-experimental/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ nyebulosa ];
  };
})
