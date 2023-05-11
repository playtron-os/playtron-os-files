# gamingos-scripts

## Files

Resize root file system:

- ./lib/systemd/system/resize-root-file-system.service
    - A systemd service file to run the `resize-root-file-system.sh` script once and then disable itself so the service does not run again.
- ./sbin/resize-root-file-system.sh
    - A script to resize the root file system to use all available space. Assumes the file system is Btrfs.

## License

[Apache License Version 2.0](LICENSE).
