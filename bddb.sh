#!/bin/bash
. /etc/init.d/functions #调用公共函数echo_success,echo_warning
DIR_dns=/var/named/lab.com.zone
login=0
Install_DB(){
   yum -y install mariadb mariadb-server mariadb-devel &> /dev/null
   systemctl restart mariadb &> /dev/null
 if [ $? -ge 0 ];then
   #mysql 
   #create database wordpress character set utf8mb4;
   #exit
   #mysql wordpress < wordpress.bak
   #mysql
   #grant all on wordpress.* to wordpress@'%' identified by 'wordpress';
   #flush privileges;
   #exit
   echo_success 
   echo "DB is succsessful"
 else
   echo_warning
   echo "DB is failed" 
 fi  
   systemctl enable mariadb  &> /dev/null
}

Install_NFS(){
    yum install nfs-utils &> /dev/null
    mkdir /web_share  
    echo "/web_share  192.168.4.0/24(rw,no_root_squash)
" > /etc/exports
    systemctl restart rpcbind  &> /dev/null
    systemctl enable rpcbind   &> /dev/null
    systemctl restart nfs    &> /dev/null 
    systemctl enable nfs    &> /dev/null
    tar -xf html.tar.gz -C /web_share/
    ls /web_share/html -ldh &> /dev/null
       if [ $? -ge 0 ];then
       echo_success
       echo "NFS is succsessful"
       else
       echo_warning
       echo "NFS is failed"
       fi
}
Install_MEM(){
yum -y  install   memcached  telnet  &> /dev/null
systemctl  start  memcached  &> /dev/null
if [ $? -ge 0 ];then
  echo_success 
  echo "Memcached is succsessful"
  else
  echo_warning
  echo "Memcached is failed"
fi 
systemctl  enable memcached  &> /dev/null
setenforce 0 &> /dev/null
firewall-cmd --set-default-zone=trusted  &>/dev/null

}
Install_DNS(){
yum  -y  install  bind  bind-chroot &> /dev/null
echo 'options {
        directory       "/var/named";
};

zone "lab.com" IN {
        type master;
        file "lab.com.zone";
};' >  /etc/named.conf

echo '$TTL 1D
@       IN SOA  @ rname.invalid. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
@       NS      dns.lab.com.
dns     A       192.168.4.102
www     A       192.168.4.100' > /var/named/lab.com.zone

systemctl  restart  named  &>/dev/null
if [ $? -ge 0 ];then
       echo_success
       echo "DNS is succsessful"
else
       echo_warning
       echo "DNS is failed"
fi
systemctl  enable  named &>/dev/null
}


while (( $login == 0 ))
do
    echo '+===================================================+'
    echo '|    Welcome to my Nginx auto install system!!!     |'
    echo '|        1.Install DB server and SET DB             |'
    echo '|        2.Install NFS server and SET NFS           |'
    echo '|        3.Install Memcached                        |'
    echo '|        4.Install DNS                              |'
    echo '|        5.exit                                     |'
    echo '+===================================================+'
    read -p 'Please chose your number:' chose
    if [ ! $chose ]
        then
            continue
    fi
    if   (( $chose == 1 ))
        then
            Install_DB;
    elif (( $chose == 2 ))
        then
            Install_NFS;
    elif (( $chose == 3 ))
        then
            Install_MEM;
    elif (( $chose == 4 ))
        then
            Install_DNS;
    elif (( $chose == 5 ))
        then
            echo 'Bye.'
            break
    else break
    fi
done
