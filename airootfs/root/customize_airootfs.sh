#!/bin/bash

cd /etc
chmod +x -R /home/liveuser/Desktop/install.desktop /usr/bin/playtron-factory-reset
chmod +x -R /usr/bin/playtronos-update
chmod +x -R /usr/bin/resize-root-file-system.sh
chmod +X -R /usr/bin/shell-file-starter.sh
systemctl enable sddm
