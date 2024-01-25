# gamingos-scripts

## Files

Hardware control:

- ./bin/hwctl
    - A Bash script to manage audio, battery, display, storage, and system information.

Resize root file system:

- ./lib/systemd/system/resize-root-file-system.service
    - A systemd service file to run the `resize-root-file-system.sh` script once and then disable itself so the service does not run again.
- ./bin/resize-root-file-system.sh
    - A script to resize the root file system to use all available space. Assumes the file system is Btrfs.

Swap creation:

- ./lib/sysctl.d/50-swappiness.conf
    - Lower the swappiness to 1.
- ./lib/systemd/system/create-swap.service
    - A systemd service file to run the `create-swap.sh` script once (after the `resize-root-file-system` service finishes) and then disable itself so the service does not run again.
- ./bin/create-swap.sh
    - A script to create swap if the RAM size is less than 32 GB.

Configuration:

- ./etc/gai.conf
    - Deprioritize IPv6 to address Steam client issues where it is hard-coded to use IPv4
    - See: https://github.com/ValveSoftware/steam-for-linux/issues/3372
- ./etc/xdg/weston/weston.ini
    - Default dev session configuration
- ./lib/systemd/system-preset/50-playtron.preset
    - Enable default system services
- ./lib/systemd/user-preset/50-playtron.preset
    - Enable default user services
- ./share/lightdm/lightdm.conf.d/55-playtron.conf
    - Autologin to playtron session
- ./share/polkit-1/rules.d/50-one.playtron.rpmostree1.rules
    - Allow running OS upgrades without a password

## License

[GNU General Public License v3.0](LICENSE).
