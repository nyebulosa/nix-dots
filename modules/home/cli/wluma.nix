{ osConfig, ... }:

{
  services.wluma = {
    enable = osConfig.my.wluma.enable;

    settings.output.backlight = [
      {
        name = "eDP-1";
        path = "/sys/class/backlight/amdgpu_bl1";
        capturer = "auto";
        predictor = "adaptive";
      }
      # The in-kernel cros_kbd_led_backlight and the out-of-tree framework_laptop
      # module both expose the same physical keyboard backlight, so wluma's output
      # discovery finds it twice and two controllers write to one LED. Keep the
      # in-kernel `chromeos::kbd_backlight` and drop the duplicate.
      {
        name = "framework_laptop::kbd_backlight";
        enabled = false;
      }
    ];
  };
}
