# playtron-os-files

## Files

Hardware control:

- ./usr/bin/hwctl
    - A Bash script to manage audio, battery, display, storage, and system information

Open file and memory mapping limits:

- ./etc/security/limits.d/50-playtron.conf
    - Increase the open file limit for user processes to 524288.
- ./usr/lib/sysctl.d/50-playtron.conf
    - Increase the open file limit for the kernel to 524288.
    - Increase the mapped memory limit to 16777216.

Resize root file system:

- ./usr/lib/systemd/system/resize-root-file-system.service
    - A systemd service file to run the `resize-root-file-system.sh` script once and then disable itself so the service does not run again
- ./usr/bin/resize-root-file-system.sh
    - A script to resize the root file system to use all available space. Assumes the file system is Btrfs

zram creation:

- ./usr/lib/sysctl.d/50-playtron.conf
    - Configure optimal swap settings for zram

Network configurations:

- ./etc/gai.conf
    - Deprioritize IPv6 to address Steam client issues where it is hard-coded to use IPv4
    - See: https://github.com/ValveSoftware/steam-for-linux/issues/3372
- ./usr/bin/clatd-ipv6-check
    - Check if only IPv6 is used (no IPv4) and then start clatd for 464XLAT support
- ./usr/lib/NetworkManager/conf.d/50-playtron.conf
    - A configuration to disable random MAC address generation to fix Wi-Fi connections with some routers.
- ./usr/lib/systemd/system/clatd-ipv6-check.service
    - A systemd service file to run the `clatd-ipv6-check` script

Disable Bluetooth and Wi-Fi on sleep to save power:

- ./usr/lib/systemd/system-preset/50-playtron.preset
    - Enable the sleep-rfkill.service
- ./usr/lib/systemd/system/sleep-rfkill.service
    - Disable Bluetooth and Wi-Fi on sleep and re-active when powered back on

Noise cancellation for mircophone input:

- ./usr/lib/systemd/user-preset/50-playtron.preset
    - Enable the pipewire-rnnoise.service
- ./usr/lib/systemd/user/pipewire-rnnoise-switch.service
    - Switch the audio input to use the RNNoise filter
- ./usr/share/pipewire/pipewire.conf.d/pipewire-rnnoise.conf
    - PipeWire configuration for RNNoise

Factory reset:

- ./usr/bin/playtron-factory-reset
    - A script to factory reset the system
- ./usr/share/polkit-1/rules.d/50-one.playtron.factory-reset.rules
    - A PolicyKit rule to allow the user to run the factory reset script as root

Configuration:

- ./etc/xdg/weston/weston.ini
    - Default dev session configuration
- ./usr/lib/modules-load.d/controllers.conf
    - Load controller drivers
- ./usr/lib/systemd/logind.conf.d/00-playtron-power.conf
    - Configure the power button
- ./usr/lib/systemd/system-preset/50-playtron.preset
    - Enable default system services
- ./usr/lib/systemd/user-preset/50-playtron.preset
    - Enable default user services
- ./usr/lib/sddm/sddm.conf.d/55-playtron.conf
    - Autologin to playtron session
- ./usr/share/polkit-1/rules.d/50-one.playtron.rpmostree1.rules
    - Allow running OS upgrades without a password

Device tweaks:

- ./usr/lib/udev/rules.d/50-block-scheduler.rules
    - Use the Kyber I/O scheduler for NVMe drives

## License

[GNU General Public License v3.0](LICENSE)
