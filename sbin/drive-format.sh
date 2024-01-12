#!/bin/bash

if [[ "${1}" == "--check" ]]
    # Use return code of "0" if it is safe to format or "1" if potentially unsafe.
    then drive_format_check_rc=0
    # The partition type reported by `parted` is one of three possible values: "gpt", "msdos" (MBR), or "unknown" (none).
    if parted ${2} print 2> /dev/null | grep -q "Partition Table: unknown"
        then echo "INFO: Partition table does not exist."
    else
        echo "WARNING: Partition table does exist!"
        drive_format_check_rc=1
        # ${partitions_found_check} will return one of the follow:
        # 0 = no partitions will be listed if there is no partition table
        # 2 = an empty list of partitions
        # 3 = at least one partition found
        partitions_found_check=$(parted ${2} print 2> /dev/null | grep -A 2 Number | wc -l)
        if (( ${partitions_found_check} > 2 ))
            then echo "WARNING: Partition table is not empty!"
            drive_format_check_rc=1
            if mount | grep -q ${2}
                then echo "WARNING: Partition(s) are mounted!"
                drive_format_check_rc=1
                if grep -q ${2} /etc/fstab
                    then echo "WARNING: Partition named mount found in /etc/fstab!"
                    drive_format_check_rc=1
                else
                    echo "INFO: Partition named mount not found in /etc/fstab."
                fi
                for device_uuid in $(ls -l /dev/disk/by-uuid/ | grep $(echo ${2} | cut -d\/ -f3) | awk '{print $9}')
                    do if grep -q ${device_uuid} /etc/fstab
                        then echo "WARNING: Partition UUID mount found in /etc/fstab!"
                        drive_format_check_rc=1
                    else
                        echo "INFO: Partition UUID mount not found in /etc/fstab."
                    fi
                done
            else
                echo "INFO: Partition(s) are not mounted."
            fi
        else
            echo "INFO: Partition table is empty."
        fi
    fi
    exit ${drive_format_check_rc}
elif [[ "${1}" == "--format" ]]
    then echo "INFO: Clearing the existing partition table and first partition metadata."
    dd if=/dev/zero of=/${2} bs=1M count=10 conv=sync 2> /dev/null
    echo "INFO: Creating a new GPT partition table."
    parted --script ${2} mklabel gpt
    echo "INFO: Creating a partition using all available space."
    # By specifying "ext4", the file system code is saved to the partition table but `parted` does not actually format the file system.
    parted --script ${2} mkpart primary ext4 2048s 100%
    echo "INFO: Formatting the partition to ext4 with case folding support."
    partition_to_format=$(fdisk -l ${2} | grep -A 1 Device | tail -n 1 | awk '{print $1}')
    mkfs.ext4 -O casefold ${partition_to_format} &> /dev/null
else
    echo "Usage:
  Check to see if a device has any data and is in-use:
    drive-format.sh --check /dev/${DEVICE}
  Force the device to be formatted even if in-use:
    drive-format.sh --format /dev/${DEVICE}"
    exit 1
fi
