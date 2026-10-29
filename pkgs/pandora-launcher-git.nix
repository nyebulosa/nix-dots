{
  fetchFromGitHub,
  pandora-launcher-unwrapped,
}:

#
# AI WARNING
# This, and all of the pandora launcher stuff, was made with the use of LLMs.
# It's just for testing and will probably get deleted later.
#

# Temporary: nixpkgs' pandora-launcher-unwrapped built from upstream master
# plus a patch that makes the bubblewrap sandbox usable on NixOS.
#
# Upstream only binds FHS paths (/usr, /lib, ...) into the sandbox and drops
# LD_LIBRARY_PATH, so on NixOS a sandboxed instance can't even start java
# (its glibc is in /nix/store) and has no GL/Vulkan drivers
# (/run/opengl-driver). See https://github.com/Moulberry/PandoraLauncher/issues/551
# and https://github.com/NixOS/nixpkgs/pull/565612.
#
# Drop this once nixpkgs ships a release containing a fix, or upstream merges
# something equivalent.
#
# Deliberately `import`ed rather than `callPackage`d from the overlay: the
# pandora-launcher wrapper calls `.override { msaClientID }` on this, which
# has to reach the original nixpkgs derivation's arguments, and callPackage
# would shadow that with this file's own (tiny) argument set.

pandora-launcher-unwrapped.overrideAttrs (old: {
  version = "6.0.0-unstable-2026-09-22";

  src = fetchFromGitHub {
    owner = "Moulberry";
    repo = "PandoraLauncher";
    rev = "2d83d6f22c43e804d9b544e8dc98d49d4874e3af";
    hash = "sha256-faDArowbvsWrK14e4qSOvAvGJKQPFAY4CEHiGIdUXls=";
  };

  patches = (old.patches or [ ]) ++ [ ./pandora-launcher-nixos-sandbox.patch ];

  # Only shows up in the "report a bug" template; makes it clear the build is
  # not the official one.
  env = (old.env or { }) // {
    PANDORA_DISTRIBUTION = "nixpkgs";
  };

  meta = old.meta // {
    changelog = "https://github.com/Moulberry/PandoraLauncher/commits/master";
  };
})
