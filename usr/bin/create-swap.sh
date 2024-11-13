#!/bin/bash

# Enable shell debugging.
set -x

# Find the RAM size in GB by converting from KB.
ram_gb=$(expr "$(cat /proc/meminfo | grep MemTotal | awk '{print $2}')" / 1000000)
# Fedora recommends using swap that is 1.5x the amount of RAM for hibernation support
# for systems with more than 4 GB of RAM.
# https://opensource.com/article/19/2/swap-space-poll
swap_gb=$(expr "${ram_gb}" \* 15 / 10)
tmpfs_gb=$(expr "${ram_gb}" + "${swap_gb}")
if [[ -f /usr/bin/rpm-ostree ]]; then
    root_size=$(df -h | grep -P '\/sysroot$' | awk '{print $4}')
else
    root_size=$(df -h | grep -P '\/$' | awk '{print $4}')
fi

# There should be a minimum of 32 GB of temporary file system size (RAM and swap combined).
# This helps to account for Legendary needing up to 23 GB to download some games
# while also leaving memory for the system.
# https://github.com/derrod/legendary/issues/158
swap_gb_total="${swap_gb}"
if [ "${tmpfs_gb}" -lt 32 ]; then
    swap_gb_additional=$(expr 32 - "${tmpfs_gb}")
    swap_gb_total=$(expr "${swap_gb}" + "${swap_gb_additional}")
fi

# If the available space on the root file system is in gigabytes (not terabytes),
# we need to make sure there is enough space.
if echo "${root_size}" | grep -P 'G$'; then
    if [ $(echo "${root_size}" | cut -d. -f1 | grep -o -P "[0-9]+") -lt "${swap_gb_total}" ]; then
        echo "Not creating swap. Less than ${swap_gb_total} GB of space available."
        exit 0
    fi
fi
if echo "${root_size}" | grep -P 'M$'; then
    echo "Not creating swap. Less than 1 GB of space available."
    exit 0
fi

# Create swap.
# The swap file is stored in the '/var/' directory because
# this is guaranteed to have persistent storage with rpm-ostree and bootc.
export SWAP_FILE_NAME="/var/swapfile"
echo "Creating swap file ${SWAP_FILE_NAME} that is ${swap_gb_total} GB in size."
touch "${SWAP_FILE_NAME}"
# Disable Btrfs copy-on-write.
# By disabling this, it will improve performance and is unnecessary for a swap file.
chattr +C "${SWAP_FILE_NAME}"
# Create the swap file.
# It cannot be sparsely allocated.
dd if=/dev/zero of=${SWAP_FILE_NAME} bs=1M count="${swap_gb_total}000"
# A swap file requires these exact permissions to work.
# Otherwise, system users can access this data.
chmod 0600 ${SWAP_FILE_NAME}
mkswap ${SWAP_FILE_NAME}
swapon ${SWAP_FILE_NAME}
echo "${SWAP_FILE_NAME}    none    swap    defaults    0 0" | tee -a /etc/fstab
