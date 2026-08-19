{
  lib,
  fetchFromGitHub,
  cmake,
  vulkan-headers,
  llvmPackages,
}:

llvmPackages.stdenv.mkDerivation (finalAttrs: {
  pname = "lsfg-vk-experimental";
  version = "2.0.0-dev28-experimental.25";

  src = fetchFromGitHub {
    owner = "eugeniosegala";
    repo = "lsfg-vk-experimental";
    tag = "v${finalAttrs.version}";
    hash = "";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace VkLayer_LS_frame_generation.json \
      --replace-fail "liblsfg-vk.so" "$out/lib/liblsfg-vk.so"
  '';

  nativeBuildInputs = [
    llvmPackages.clang-tools
    llvmPackages.libllvm
    cmake
  ];

  buildInputs = [
    vulkan-headers
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
