!/bin/bash
. /etc/init.d/functions
CONF_DIR=/etc/libvirt/qemu
IMG_DIR=/var/lib/libvirt/images

delete(){
   sudo  virsh destroy ${1} &> /dev/null
   sudo  virsh undefine ${1} &> /dev/null
   rm -rf $CONF_DIR/${1}.xml
   rm -rf $IMG_DIR/${1}.qcow2
   echo_success
   echo "已删除虚拟机${1}"

}

read -p "请输入要删除的虚拟机"  VMNAME

if [ -z $VMNAME  ];then
   echo_warning
   echo "请输入一个参数"
fi
if [ -e ${IMG_DIR}/${VMNAME}.qcow2 ];then

          sleep 0.2
          delete ${VMNAME}
    else
          echo_warning
          echo "虚拟机不存在,并且必须是.qcow2结尾的文件"
fi
                                                             
