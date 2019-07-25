#!/bin/bash
. /etc/init.d/functions
CONF_DIR=/etc/libvirt/qemu
IMG_DIR=/var/lib/libvirt/images
BASEVM=centos7.0

createvm(){
 qemu-img create -f qcow2 -b ${IMG_DIR}/${BASEVM}.qcow2 $IMG_DIR/${1}.qcow2 30G &> /dev/null
 sed  "s/${BASEVM}/${1}/" ${IMG_DIR}/${BASEVM}.xml > ${CONF_DIR}/${1}.xml
 sudo virsh define ${CONF_DIR}/${1}.xml &> /dev/null
 echo_success
 echo "虚拟机 ${1} 已创建"
}

read -p "请输入要创建的虚拟机:" VMNAME

if [ -z $VMNAME  ];then
echo "请输入一个参数"
exit
fi
 if [ -e ${IMG_DIR}/${VMNAME}.qcow2 ]; then
   echo_warning
   echo "虚拟机 ${VMNAME} 已存在"
   exit 38
 else
   sleep 0.2
   createvm ${VMNAME}
fi
