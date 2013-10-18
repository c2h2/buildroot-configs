#!/bin/bash

set -xe

DIR=`pwd`
MMC_DEV=/dev/mmcblk0
BOOTFS_PART=${MMC_DEV}p1

BOOTFS_PATH=/boot/uboot

mount_parts(){
  ## make dir if missing
  mkdir -p ${BOOTFS_PATH}

  ## mount to correct dir
  mount ${BOOTFS_PART} ${BOOTFS_PATH}
}

change2rootfs(){
  sed -i "s/mmcblk0p3/mmcblk0p2/g" ${BOOTFS_PATH}/uEnv.txt
}
change2upfs(){
  sed -i "s/mmcblk0p2/mmcblk0p3/g" ${BOOTFS_PATH}/uEnv.txt

}
umount_parts(){
  cd ${DIR}
  umount ${BOOTFS_PART} || true
}


#do the job
umount_parts
mount_parts
change2upfs
umount_parts
