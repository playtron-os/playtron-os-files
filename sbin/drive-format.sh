#!/bin/bash

if echo ${1} | grep -q -P "^\/dev\/"
    # Unmounting first allows the new partition to be mountable immediately after being formatted.
    then echo "INFO: Unmounting partitions by name..."
    for d in $(ls -1 ${1}*)
        do echo "INFO: Unmounting ${d}."
        umount ${d} 2> /dev/null
    done
    echo "INFO: Clearing the existing partition table and first partition metadata."
    dd if=/dev/zero of=/${1} bs=1M count=10 conv=sync 2> /dev/null
    echo "INFO: Creating a new GPT partition table."
    parted --script ${1} mklabel gpt
    echo "INFO: Creating a partition using all available space."
    # By specifying "ext4", the file system code is saved to the partition table but `parted` does not actually format the file system.
    parted --script ${1} mkpart primary ext4 2048s 100%
    echo "INFO: Formatting the partition to ext4 with case folding support."
    partition_to_format=$(fdisk -l ${1} | grep -A 1 Device | tail -n 1 | awk '{print $1}')
    if ! mkfs.ext4 -O casefold ${partition_to_format} &> /dev/null
        then echo "ERROR: Failed to format ${partition_to_format} to ext4!"
        exit 1
    else
        echo "INFO: Successfully formatted ${partition_to_format} to ext4."
    fi
    echo "INFO: Reloading system partition information."
    partprobe
else
    echo -e "Usage:
\tdrive-format.sh /dev/\${DEVICE}\tForce the device to be formatted even if in-use"
    exit 1
fi
