# Config review — applied changes (2026-07-29)

Changes applied from the full flake review. Verified by evaluating and building
`nixosConfigurations.goingmerry`: no failed assertions, no new warnings, build
succeeds. Only pre-existing warning left is the `home.pointerCursor` deprecation
from the catppuccin cursor block.

Items marked **skipped** were deliberately left alone at your request.

---

## A1 — Automatic screen locking

**Problem.** `goingmerry` unlocks LUKS from the TPM, so there is no boot
passphrase. That makes the lock screen the only barrier between someone opening
the lid and a live session. There was a manual bind (`Super+Alt+L`) and nothing
else: no idle timeout, no lock on suspend, no lock entry in the power menu.

**Changes.**

- `home.nix` — added `services.swayidle`:
  - 300s idle → `swaylock -f`
  - 360s idle → `niri msg action power-off-monitors`
  - `before-sleep` and `lock` events → `swaylock -f`
  - Each command is guarded by `pgrep -x swaylock ||` so idle-then-suspend
    doesn't stack two lockers.
  - `niri` is called through `/run/current-system/sw/bin/niri` on purpose — that
    is the patched `niri-fixed` build from `features/niri.nix`. Using
    `${pkgs.niri}` would have pulled a second, unpatched niri into the store.
- `home/nwg-bar/bar.json` — **deleted**, now generated in `home.nix` instead.
  The old file pointed every icon at `/usr/share/nwg-bar/images/*.svg`, which
  does not exist on NixOS, so all icons were broken. Generating it lets the paths
  resolve to `${pkgs.nwg-bar}/share/nwg-bar/images/`. A `Lock` entry was added.
- `home/niri.kdl` — added `Super+Alt+P` for the power menu. `nwg-bar`'s main
  `bar.json` had no keybind at all before, so the menu was unreachable; the only
  bound nwg-bar was the screen-recording one on `Mod+Shift+G`.

Lid close is covered because logind's default `HandleLidSwitch=suspend` fires
`before-sleep`.

**Note:** `home/hypr/replay/nwg-bar/bar.json` still has the same broken
`/usr/share` icon paths. Left alone since it's a separate feature and you said
the `hypr/` tree is work-in-progress.

---

## A2 — sshd disabled

**Problem.** `sshd` could not authenticate anyone. `authorizedKeys.keys` and
`.keyFiles` were both empty, `PasswordAuthentication = false`, and
`AuthenticationMethods = "publickey"`. On top of that `openFirewall = false` and
`trustedInterfaces` did not include `tailscale0`, so port 22 was unreachable on
every interface anyway.

Your working remote access is `services.tailscale.extraSetFlags = ["--ssh"]`,
which is **tailscaled's own SSH server**. It never touched `sshd` and ignores
every setting in that block — access policy is entirely your tailnet ACLs.

**Change.** `configuration.nix` — replaced the whole `services.openssh` block
with `openssh.enable = false;` plus a comment recording what re-enabling needs.

**Worth doing next:** since the tailnet ACLs are now the only thing gating remote
root-capable access, they're worth a read.

---

## A3 — Steam ports closed on the laptop

**Problem.** `my.gaming.enable` defaults to `true` for both hosts, and
`gaming.nix` set `remotePlay.openFirewall` and `dedicatedServer.openFirewall`
unconditionally. That opened TCP 27015/27036/27037 and UDP
10400/10401/27015/27036 on `goingmerry` — on every network it joins, including
public wifi.

**Changes.**

- `modules/nixos/features/gaming.nix` — new `my.gaming.openFirewall` option
  (`bool`, default `true`) controlling both Steam firewall settings.
- `hosts/goingmerry/goingmerry.nix` — `my.gaming.openFirewall = false`.

Verified: `goingmerry`'s `allowedTCPPorts` and `allowedUDPPorts` are now both
empty. `thousandsunny` is unchanged.

---

## A6 — Impermanence persist paths

**Problem.** State that needs to survive the btrfs rollback wasn't listed.

**Change.** `modules/nixos/core/impermanence.nix` — added:

| Path | Why |
|---|---|
| `/var/lib/systemd` | Random seed, timer stamps, `pcrlock.json` |
| `/var/lib/flatpak` | `services.flatpak.enable = true`; installed flatpaks were vanishing each boot |
| `/var/lib/fwupd` | fwupd enabled on goingmerry |
| `/var/lib/power-profiles-daemon`, `/var/lib/upower` | Power profile + battery history |
| `/var/lib/coolercontrold` | `programs.coolercontrol.enable = true`; fan curves |
| `/var/lib/AccountsService` | Avatar / session prefs |

All seven directory mounts activated cleanly.

### `/etc/machine-id` — tried, failed, reverted

I initially added `/etc/machine-id` to `files`. It **broke activation** and has
been reverted; the config is back to what you had for this one item.

The failure:

```
A file already exists at /etc/machine-id!
Activation script snippet 'persist-files' failed (1)
× persist-persist-etc-machine\x2did.service - failed (exit-code 1)
```

Cause is in impermanence's `mount-file.bash`. The checks run in order, and the
`-s` (file exists and is non-empty) test at line 36 fires **before** the
`/etc/machine-id` special case at line 42:

```bash
elif [[ -s $mountPoint ]]; then
    echo "A file already exists at $mountPoint!" >&2
    exit 1
elif [[ $method == "auto" && -e $targetFile ]]; then
    ...
elif [[ $method == "auto" && $mountPoint == "/etc/machine-id" ]]; then
    # the special case never reached on a running system
```

So the special case only helps when `/etc/machine-id` is absent or empty. On a
running system it always exists and is non-empty, so activation aborts. It's a
bootstrap problem, not a config error — it needs `/persist/etc/machine-id` seeded
and the live `/etc/machine-id` cleared, which isn't something to do mid-activation.

Left for you to handle, as you asked. The rest of A6 is applied and working.

`/etc/ssh` was in the original recommendation but is **not** included, since A2
removed sshd and there are no host keys to preserve. Tailscale's node key lives
in `/var/lib/tailscale`, which was already persisted.

---

## A7 — illuminanced no longer reads a root config from `$HOME`

**Problem.** The unit ran as root with
`-c /home/leonillo/.config/illuminanced/illuminanced.toml` — a root service
taking its configuration from a path the unprivileged user can rewrite. (That
file doesn't exist on this machine, so the service would have failed to start
anyway had it ever been enabled.)

**Changes.** `modules/nixos/features/illuminanced.nix`:

- New `my.illuminanced.configFile` option, defaulting to
  `${pkgs.illuminanced}/share/illuminanced/illuminanced.toml` — the config the
  package already ships, so no schema was invented. Override it with a
  `pkgs.writeText` or an `/etc` path when you actually set this up.
- Added systemd hardening: `ProtectHome`, `ProtectSystem=strict`, `PrivateTmp`,
  `PrivateNetwork`, `NoNewPrivileges`, `RestrictNamespaces`, `RestrictRealtime`,
  `LockPersonality`, `SystemCallArchitectures=native`.
  `ProtectSystem=strict` leaves `/sys` writable, so the backlight write still
  works. Deliberately left out `CapabilityBoundingSet=""`, `SystemCallFilter`
  and `MemoryDenyWriteExecute` — plausible but untestable while the service is
  disabled, and the failure mode would be a daemon that silently won't start.
- Dropped `after = [ "systemd-udev-settle.service" ]`, which referenced a unit
  that `core/systemd.nix` disables.

Still `enable = false` on both hosts; this is a latent fix.

---

## C1 — Duplicate kernel parameters on goingmerry

**Problem.** The resolved cmdline contained `amd_pstate=active` twice, and
`amdgpu.dcdebugmask` twice with conflicting values.

`amd_pstate=active` comes from nixos-hardware's
`common/cpu/amd/pstate.nix` (confirmed by grepping the input), so the host's own
copy was redundant.

`amdgpu.dcdebugmask=0x10` comes from nixos-hardware's
`framework/13-inch/common/amd.nix`, which sets it to **disable Panel Self
Refresh** as a workaround for a known flicker bug. Your `0x0` re-enables PSR.
That override was working, but only because it happened to land later in the
list.

**Change.** `hosts/goingmerry/goingmerry.nix` — dropped the redundant
`amd_pstate=active`, and wrapped the remaining params in `lib.mkAfter` so the
`dcdebugmask` override wins by explicit ordering rather than by luck.

Your `0x0` value was kept as-is — that's your lag fix, not something I changed.

---

## C4 — scx scheduler flags

**Problem.** The desktop ran `scx_lavd --autopilot` (a laptop-oriented adaptive
mode) while the laptop ran `scx_bpfland` with `--autopower` commented out.

**Important finding:** `--autopower` **does not exist on `scx_bpfland`**. I
checked `--help` on scx 1.1.2 — bpfland has `-m/--primary-domain`
(`auto`/`performance`/`powersave`) and `-f/--cpufreq`, but no `--autopower`.
Only `scx_lavd` has `--autopower`, `--autopilot`, `--performance`, `--powersave`.
Had you uncommented that line as written, the service would have failed to start.

**Changes.**

- `hosts/thousandsunny/thousandsunny.nix` — `scx_lavd`, `--autopilot` →
  `--performance` (desktop is always on AC).
- `hosts/goingmerry/goingmerry.nix` — `scx_bpfland` → `scx_lavd` with
  `--autopower`, which is the power-adaptive behaviour you were reaching for.

**This is the one change here that alters behaviour you might have chosen
deliberately.** If you prefer bpfland's interactivity on the laptop, revert to
`scheduler = "scx_bpfland"` and use `extraArgs = [ "--cpufreq" ]` instead — but
note that may fight `amd_pstate=active` + power-profiles-daemon over EPP.

Verified in the built unit: `SCX_SCHEDULER=scx_lavd`, `SCX_FLAGS=--autopower`.

---

## C6 + D1 — Store GC and `nh`

**Problem.** `nh` was installed as a bare package but `programs.nh.enable` was
`false`, so there was no `NH_FLAKE` and no clean integration.
`nix.gc.automatic` and `nix.optimise.automatic` were both `false`, and
`/nix/store` had grown to **53 GB** across 13 system generations.
`auto-optimise-store = true` was also hardlinking on every single build.

**Changes.** `modules/nixos/core/nix.nix`:

- `programs.nh` enabled, `flake = "/home/leonillo/nixos-conf"`,
  `clean.enable = true` with `--keep-since 30d --keep 5`.
- `auto-optimise-store = false` and `nix.optimise.automatic = true` — same
  hardlinking work, done on a timer instead of in the middle of every rebuild.
- `nix.gc.automatic` deliberately left off, since `nh clean` covers it and
  running both is redundant.
- `configuration.nix` — removed the now-duplicate `nh` from `systemPackages`.

`nh clean` will reclaim a large chunk of that 53 GB on its first run.

---

## D2 — CLAUDE.md commands

`CLAUDE.md` documented `sudo nixos-rebuild switch --flake .`, but
`core/hardening.nix` sets `security.sudo.enable = lib.mkForce false`. Every
documented rebuild command was unrunnable.

Rewrote the Commands section around `nh os switch` / `nh os test` and
`run0 nixos-rebuild`, with an explicit note that there is no `sudo`. Added a note
about the GC setup from C6.

---

## D3 — User groups

**Problem.** Three groups in `extraGroups` don't exist on these systems
(confirmed by evaluating `users.groups`), which produces activation warnings:

- `docker` — you use `podman.dockerCompat`, which provides the CLI shim but no
  `docker` group.
- `libvirtd` — `virtualisation.libvirtd` is commented out in `configuration.nix`.
- `games` — no module creates it.

**Changes.** `configuration.nix`:

- `docker` → `podman` (which does exist)
- removed `libvirtd` and `games`
- commented out `firewall.trustedInterfaces = [ "virbr0" ]`, since virbr0 only
  exists with libvirtd; the comment records that they get re-enabled together
- **kept** `audio`, against the original recommendation: your
  `core/performance.nix` deliberately assigns `cpu_dma_latency`, `rtc0` and
  `hpet` to `GROUP="audio"`, so dropping it would have undone your own low-latency
  udev rules. Added a comment noting the dependency.
- **kept** `input` / `uinput` — needed for via/vial.

`programs.virt-manager.enable = true` was left alone; it's inert without libvirtd
but harmless, and re-enabling libvirtd is your call.

---

## D4 — Package cleanup

- **Browsers** — removed `vivaldi` (with its Widevine/proprietary-codecs
  override), `floorp-bin` and `firefox` from `home.nix`. Kept `librewolf` and
  `zen-browser`.
- **gcc — not changed.** Originally I planned to move it off the global PATH and
  give neovim its own toolchain via a wrapper. I built and tested that wrapper
  (nvim saw `cc`/`gcc`/`make` while the bare PATH did not), but you said you may
  do C work, so `gcc` stays in `systemPackages` as-is. The wrapper was discarded.
- **Java — not touched**, as you asked.
- **Duplicates removed:**
  - `htop` package from `systemPackages` (`programs.htop.enable` provides it)
  - `nh` from `systemPackages` (now from `programs.nh`)
  - `sbctl` from `goingmerry.nix` (already in shared `configuration.nix`, and
    both hosts use lanzaboote)
  - `ffmpegthumbnailer` from `features/niri.nix` (already in `configuration.nix`)
  - `kitty` from `home.packages` (`programs.kitty` provides it; the copy in
    `features/niri.nix` was kept on purpose so a terminal still exists if
    home-manager activation ever fails)
- `hardware.enableAllFirmware` → `enableRedistributableFirmware`. The former
  pulls unfree blobs on top of the redistributable set; the latter covers your
  actual hardware at a smaller closure.

---

## D5 — Removed `gpu.nix.bak`

`modules/nixos/hardware/gpu.nix.bak` was tracked in git. Deleted and staged.

---

## Sunshine

`hosts/thousandsunny/thousandsunny.nix` — `capSysAdmin = true` → `false`.
`CAP_SYS_ADMIN` on a network-facing service is a large grant, and it's only
needed for KMS capture; under niri/Wayland the capture path goes through portals.

If Sunshine capture breaks after this, that's the cause — flip it back. Note it's
also `openFirewall = false`, so today it's only reachable over Tailscale.

---

## Deliberately not done

Per your instructions:

- **A4, A5, A8** (thousandsunny 53/67 ports, impermanence feature module, public
  repo leaks) — you're handling these.
- **B1–B6** (nix-mineral tradeoffs: `panic=-1`/`sysrq=0`, `iommu.passthrough`,
  IPv6 SLAAC, rp_filter vs Tailscale, `perf_event_paranoid`, `init_on_free`) —
  understood and intended.
- **B7** (AppArmor / MAC layer) — too much work right now. This remains the real
  gap between this config and secureblue; everything else is the shallow half.
- **C2, C3, C5** (tmpfs `/tmp` vs nix builds, hibernation, `pcie_aspm=force`) —
  already aware.
- **D5 partial** — only `gpu.nix.bak` removed; the `home/hypr/*` tree left in
  place as work-in-progress.

---

## Verification

```
nix eval  .#nixosConfigurations.goingmerry  → 0 failed assertions
                                            → 1 warning (pre-existing pointerCursor)
nixos-rebuild build --flake .#goingmerry    → OK
```

Confirmed in the built system:

- no `sshd` unit
- no `illuminanced` unit (still disabled)
- `allowedTCPPorts` / `allowedUDPPorts` both empty
- `SCX_SCHEDULER=scx_lavd`, `SCX_FLAGS=--autopower`
- `swayidle.service` ExecStart has all four handlers with the pgrep guard
- `~/.config/nwg-bar/bar.json` generated with store-resolved icon paths

`thousandsunny` was evaluated clean before you asked me to focus on `goingmerry`,
but has **not** been built or activated — do that on the desktop before trusting
the scx and sunshine changes there.
