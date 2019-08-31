#!/bin/bash
. /etc/init.d/functions #调用公共函数echo_success,echo_warning
login=0
DIR_nginx=/usr/local/nginx/conf/nginx.conf
DIR_virtual=/etc/sysconfig/network-scripts/ifcfg-lo
Install_nginx(){
id nginx &>/dev/null    # 判断是否有这个用户（nginx）
if [ $? -ne 0 ];then    # 没有则才去创建这个用户
   useradd -s /sbin/nologin  nginx
fi
   rpm -q nginx &> /dev/null  
if [ $? -ne 0 ];then
     yum -y install php php-fpm php-mysql mariadb-devel &> /dev/null
     yum -y install nginx-1.15.8-10.x86_64.rpm &> /dev/null
    
    if  [ $? -ge 0 ];then                  #判断安装nginx成功与否
          echo_success
          echo "Install nginx successful" 
       else
          echo_warning
          echo "Install nginx failed"
    fi 
fi     
}   
Start_nginx(){  #开始nginx服务
   if [ `rpm -q nginx` ];then
       /usr/local/nginx/sbin/nginx &> /dev/null
       if [ $? -ge 0 ];then
            systemctl start   php-fpm  &> /dev/null
            systemctl enable  php-fpm  &> /dev/null
            echo "/usr/local/nginx/sbin/nginx" >> /etc/rc.local
            chmod +x /etc/rc.local
            echo_success
            echo "The service is started successful"
         else
            echo_warning
            echo "$ervice The is started failed  $end"
       fi
   fi
}
Set_nginx(){    #设置配置文件并reload
    if [ -e $DIR_nginx ];then
        cat nginx.conf > $DIR_nginx
        ss -antp |grep nginx &> /dev/null  
        if [ $? -ge 0 ];then
          /usr/local/nginx/sbin/nginx -s reload  &> /dev/null
            if [ $? -ge 0 ];then
              echo_success
              echo "Nginx reload succsessful"
            else
              echo_warning
              echo "Nginx reload failed"       
            fi
        fi
    fi
}
Set_virtual(){ #设置虚拟IP
  if [ -e $DIR_virtual ];then
    cp /etc/sysconfig/network-scripts/ifcfg-lo{,:0}
   echo "DEVICE=lo:0
         IPADDR=192.168.4.100
         NETMASK=255.255.255.255
         NETWORK=192.168.4.100
         BROADCAST=192.168.4.100
         ONBOOT=yes
         NAME=lo:0" > /etc/sysconfig/network-scripts/ifcfg-lo:0
   echo "net.ipv4.conf.all.arp_ignore = 1
         net.ipv4.conf.lo.arp_ignore = 1
         net.ipv4.conf.lo.arp_announce = 2
         net.ipv4.conf.all.arp_announce = 2" >> /etc/sysctl.conf      
         systemctl stop NetworkManager  &> /dev/null
         systemctl disable NetworkManager &> /dev/null 
         systemctl restart network  &> /dev/null
         ifconfig | grep 192.168.4.100  &> /dev/null
            if [ $? -ge 0  ];then
              echo_success   
              echo "Set Virtual is succsessful"
            else 
              echo_warning
              echo "Set Virtual is failed"  
            fi
      else
        echo_warning
        echo "lo is not existent" 
fi
}
Set_Fstab(){ #设置NFS挂载
yum -y install nfs-utils &> /dev/null
   if [ $? -ge 0 ];then
       rm -rf /usr/local/nginx/html/*
       echo "192.168.4.101:/web_share/html /usr/local/nginx/html/ nfs defaults 0 0" >> /etc/fstab
       mount -a  &> /dev/null
       df -h | grep 192.168.4.101 &> /dev/null
           if [ $? -ge 0 ];then
               echo_success
               echo "Set NFS Fstab is succsessful"
           else
               echo_warning   
               echo "Set NFS Fstab is failed"
           fi
   fi


}
while (( $login == 0 ))
do
    echo '+===================================================+'
    echo '|    Welcome to my Nginx auto install system!!!     |'
    echo '|        1.Install Nginx server and Start Nginx     |'
    echo '|        2.Set Nginx server and reload Nginx        |'
    echo '|        3.Set Virtual IP                           |'
    echo '|        4.Set NFS fstab                            |'
    echo '|        5.exit                                     |'
    echo '+===================================================+'
    read -p 'Please chose your number:' chose                
                #############################
                #1:安装Nginx并start         #
                #2:设置Nginx并reload        #
                #3:设置虚拟IP               #
                #4:设置NFS开机挂载          #
                #5:退出                     #
                #############################
    if [ ! $chose ]
        then
            continue
    fi
    if   (( $chose == 1 ))
        then
            Install_nginx;
            Start_nginx; 
    elif (( $chose == 2 ))
        then
            Set_nginx;
    elif (( $chose == 3 ))
        then
            Set_virtual;
    elif (( $chose == 4 ))
        then 
            Set_Fstab;
    elif (( $chose == 5 ))
        then
            echo 'Bye.'
            break
    else
        break
    fi
done
















