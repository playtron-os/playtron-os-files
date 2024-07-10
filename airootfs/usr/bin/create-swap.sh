#!/bin/bash

# Enable shell debugging.
set -x

# Calculate the ideal swap size.
# There should be 32 GB of temporary file system size (RAM and swap combined).
# First, we find the RAM size in GB by converting from KB.
ram_gb=$(expr $(cat /proc/meminfo | grep MemTotal | awk {'print $2'}) / 1000000)
root_size=$(df -h | grep -P '\/sysroot$' | awk '{print $4}')
# If the available space on the root file system is in gigabytes (not terabytes), we need to make sure there is enough space.
# zram is enabled and used by default on Fedora which will help in low space situations.
if echo ${root_size} | grep -P 'G$'; then
    if [ $(echo ${root_size} | cut -d. -f1 | grep -o -P "[0-9]+") -lt 32 ]; then
        echo "Not creating swap. Less than 32 GB of space available."
        exit 0
    fi
fi
if echo ${root_size} | grep -P 'M$'; then
    echo "Not creating swap. Less than 1 GB of space available."
    exit 0
fi
swap_gb=$(expr 32 - $ram_gb)
# Check to see if swap_gb variable is a zero or negative number (meaning there is more than 32 GB of RAM).
echo $swap_gb | grep -q -P "^[\-|0]"
if [ $? -ne 0 ]; then
    # The swap file is stored in the '/home/' directory because this is guaranteed to have persistent storage on Fedora Silverblue.
    export SWAP_FILE_NAME="/home/swapfile"
    echo "Creating swap file ${SWAP_FILE_NAME} that is ${swap_gb} GB in size."
    touch "${SWAP_FILE_NAME}"
    # Disable Btrfs copy-on-write.
    # By disabling this, it will improve performance and is unnecessary for a swap file.
    chattr +C "${SWAP_FILE_NAME}"
    # Create the swap file.
    # It cannot be sparsely allocated.
    dd if=/dev/zero of=${SWAP_FILE_NAME} bs=1M count="${swap_gb}000"
    # A swap file requires these exact permissions to work.
    # Otherwise, system users can access this data.
    chmod 0600 ${SWAP_FILE_NAME}
    mkswap ${SWAP_FILE_NAME}
    swaplabel --label playtron-os-swap ${SWAP_FILE_NAME}
    swapon ${SWAP_FILE_NAME}
    echo "${SWAP_FILE_NAME}    none    swap    defaults    0 0" | tee -a /etc/fstab
else
    echo "Not creating swap. ${ram_gb} GB of RAM is larger than 32."}
fi
