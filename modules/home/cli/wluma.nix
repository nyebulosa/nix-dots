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
      {
        name = "framework_laptop::kbd_backlight";
        enabled = true;
      }
      {
        name = "chromeos::kbd_backlight";
        enabled = true;
      }
    ];
  };
}
