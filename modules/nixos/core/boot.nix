{
  lib,
  pkgs,
  config,
  ...
}:

#
# AI WARNING
#
# I'm not in the mood at all to learn and fix this myself, so Claude wrote this script that fixes
# PCR 7 on my amd desktop. Tho, considering my hardware, I'm probably vulnerable to that ryzen
# tpm vulnerability... so maybe I should just use password in thousandsunny and call it a day.
# I'm not really worried about an advanced attacker with physical access to my computer...
# but a password is not a big deal.
#
# Anyways yeah, that script is AI code and I did NOT write it, but I reviewed it and made sure
# to understand it. It's actually quite simple.
#
# So, to future me:
# TODO:
# [] MAKE YOUR OWN FIX WRITTEN BY YOURSELF
#

let
  pcrlock = "${config.systemd.package}/lib/systemd/systemd-pcrlock";

  fixScript =
    pkgs.writers.writePython3Bin "pcrlock-fix"
      {
        libraries = [ pkgs.python3Packages.pyyaml ];
      }
      ''
        import json, os, pathlib, subprocess, sys, yaml

        LOG = "/sys/kernel/security/tpm0/binary_bios_measurements"
        D = pathlib.Path("/var/lib/pcrlock.d")
        EARLY = D / "280-secureboot-authority.pcrlock.d" / "generated.pcrlock"
        LATE = D / "620-secureboot-authority.pcrlock.d" / "generated.pcrlock"

        if not os.path.exists(LOG) or not os.path.exists("/dev/tpmrm0"):
            print("pcrlock-fix: no TPM event log yet, skipping")
            sys.exit(0)

        out = subprocess.check_output(["${pkgs.tpm2-tools}/bin/tpm2_eventlog", LOG])
        events = yaml.safe_load(out)["events"]

        early, late, seen_sep = [], [], False
        for ev in events:
            if ev["PCRIndex"] != 7:
                continue
            if ev["EventType"] == "EV_SEPARATOR":
                seen_sep = True
                continue
            if ev["EventType"] != "EV_EFI_VARIABLE_AUTHORITY":
                continue
            digests = [{"hashAlg": d["AlgorithmId"], "digest": d["Digest"]}
                       for d in ev["Digests"] if d["AlgorithmId"] == "sha256"]
            (late if seen_sep else early).append({"pcr": 7, "digests": digests})

        def write(path, recs):
            if not recs:
                path.unlink(missing_ok=True)
                return
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(json.dumps({"records": recs}, indent=2) + "\n")

        write(EARLY, early)
        write(LATE, late)
        print(f"pcrlock-fix: {len(early)} early / {len(late)} late authority records")

        subprocess.run(["${pcrlock}", "make-policy"], check=True)
      '';
in
{
  boot = {
    plymouth = {
      enable = true;
      theme = "bgrt";
    };
    loader = {
      systemd-boot = {
        enable = lib.mkForce false;
        consoleMode = "max";
      };
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
      configurationLimit = 4;
      autoGenerateKeys.enable = true;
      measuredBoot = {
        enable = true;
        pcrs = [
          0
          2
          4
          7
        ];
      };
    };
    initrd = {
      systemd = {
        enable = lib.mkDefault true;
        tpm2.enable = true;
      };
      availableKernelModules = [
        "tpm_crb"
        "tpm_tis"
      ];
      kernelModules = [ "amdgpu" ];
      verbose = false;
    };

    consoleLogLevel = 3;
    kernelParams = [
      "quiet"
      "splash"
      "systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "vt.global_cursor_default=0"
    ];
  };

  system.activationScripts.pcrlock-fix = {
    deps = [ "var" ];
    text = "${fixScript}/bin/pcrlock-fix || echo 'pcrlock-fix failed' >&2";
  };

  environment.systemPackages = with pkgs; [
    tpm2-tss
    fixScript
  ];

  security.tpm2 = {
    enable = true;
  };
}
