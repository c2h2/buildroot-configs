#!/bin/bash

set -x

DIR=`pwd`
MMC_DEV=/dev/mmcblk0
BOOTFS_PART=${MMC_DEV}p1
ROOTFS_PART=${MMC_DEV}p2
ROOTDIR_PART=${MMC_DEV}p7

BOOTFS_PATH=/bootfs
ROOTFS_PATH=/rootfs
ROOTDIR_PATH=/rootdir

ROOTFS_URL="http://192.168.8.80/rootfs-minimal.tar.xz"
BOOTFS_URL="http://192.168.8.80/bootfs.tar.xz"

mount_parts(){
  ## make dir if missing
  mkdir -p ${BOOTFS_PATH}
  mkdir -p ${ROOTFS_PATH}
  mkdir -p ${ROOTDIR_PATH}

  ## mount to correct dir
  mount ${BOOTFS_PART} ${BOOTFS_PATH}
  mount ${ROOTFS_PART} ${ROOTFS_PATH}
  mount ${ROOTDIR_PART} ${ROOTDIR_PATH}
}

update_parts(){
  ##get parts
  if [ -f ${ROOTDIR_PATH}/rootfs.tar.xz ]; then
    echo "re-dl"
    wget -O ${ROOTDIR_PATH}/rootfs.tar.xz ${ROOTFS_URL}
  else
    wget -O ${ROOTDIR_PATH}/rootfs.tar.xz ${ROOTFS_URL}
  fi

  if [ -f ${ROOTDIR_PATH}/bootfs.tar.xz ]; then
    echo "re-dl"
    wget -O ${ROOTDIR_PATH}/bootfs.tar.xz ${BOOTFS_URL}
  else
    wget -O ${ROOTDIR_PATH}/bootfs.tar.xz ${BOOTFS_URL}
  fi
 
  #flash parts 
  cd ${ROOTFS_PATH}
  rm -rf *
  xzcat ${ROOTDIR_PATH}/rootfs.tar.xz | tar xv

  cd ${BOOTFS_PATH}
  xzcat ${ROOTDIR_PATH}/bootfs.tar.xz | tar xv

}

cleaning(){
  rm -rf ${ROOTDIR_PATH}/rootfs.tar.xz  
  rm -rf ${ROOTDIR_PATH}/bootfs.tar.xz 
}

verify(){
  sed -i "s/mmcblk0p3/mmcblk0p2/g" ${BOOTFS_PATH}/uEnv.txt

}

umount_parts(){
  cd ${DIR}
  umount ${BOOTFS_PART} || true
  umount ${ROOTFS_PART} || true
  umount ${ROOTDIR_PART} || true
}


#do the job
umount_parts
mount_parts
update_parts
verify
cleaning
umount_parts


reboot
