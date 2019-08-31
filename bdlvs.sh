#!/bin/bash
. /etc/init.d/functions #调用公共函数echo_success,echo_warning
DIR_keepconf=/etc/keepalived/keepalived.conf
dvip=192.168.4.100
login=0
yum -y install keepalived ipvsadm 
if [ "rpm -q keepalived" ];then
 read -p "MASTER|BACKUP:" morb
 if [ $morb == MASTER ];then
 cat keepalived.conf > $DIR_keepconf
  read -p "Please enter hostname:" rid 
   if [ $rid ];then
    sed -i "s/proxy1/$rid/" $DIR_keepconf 
    read -p "Please enter VIP:" vip
      if [ $vip ];then
       sed -i "s/$dvip/$vip/g" $DIR_keepconf
       read -p "rr|wrr|lc|wlc:" lb
        if [ $lb ];then
         case $lb in
             "rr")
              sed -i "s/wrr/$lb/" $DIR_keepconf
              ;;
             "wrr")
              sed -i "s/wrr/$lb/" $DIR_keepconf
              ;;
             "lc")
              sed -i "s/wrr/$lb/" $DIR_keepconf
              ;;
             "wlc")
              sed -i "s/wrr/$lb/" $DIR_keepconf
              ;;
            esac    
        else
            echo "rr|wrr|lc|wlc"
        fi
          read -p "NAT|TUN|DR:" mode
             if [ $mode ];then
             case $mode in
             "NAT")
              sed -i "s/DR/$mode/" $DIR_keepconf
              ;;
             "TUN")
              sed -i "s/DR/$mode/" $DIR_keepconf
              ;;
             "DR")
              sed -i "s/DR/$mode/" $DIR_keepconf
            esac
             else
              echo "NAT|TUN|DR"
             fi
                while (( $login == 0 ))
                do
                  echo '+================================+'
                  echo '|        1: add rs ip            |'
                  echo '|        2: exit|break           |'
                  echo '+================================+'
                  read -p "NUM:" num
                         if (( $num == 1 ))
                            then
                              read -p "RS IP:" rs 
                              sed  -i '$d' $DIR_keepconf
                              echo "    real_server $rs 80 {
        weight 1 
        TCP_CHECK { 
          connect_timeout 3
          nb_get_retry 3
          delay_before_retry 3
        }
    }
}" >> $DIR_keepconf
                         elif (( $num == 2 ))
                            then
                            break
                         else
                            continue   
                         fi
              done
      fi      
    fi   
elif [ $morb == BACKUP ];then
 cat keepalived2.conf > $DIR_keepconf
  read -p "Please enter hostname:" rid 
   if [ $rid ];then
    sed -i "s/proxy2/$rid/" $DIR_keepconf 
    read -p "Please enter VIP:" vip
      if [ $vip ];then
       sed -i "s/$dvip/$vip/g" $DIR_keepconf
       read -p "rr|wrr|lc|wlc:" lb
        if [ $lb ];then
         case $lb in
             "rr")
              sed -i "s/wrr/$lb/" $DIR_keepconf
              ;;
             "wrr")
              sed -i "s/wrr/$lb/" $DIR_keepconf
              ;;
             "lc")
              sed -i "s/wrr/$lb/" $DIR_keepconf
              ;;
             "wlc")
              sed -i "s/wrr/$lb/" $DIR_keepconf
              ;;
            esac    
        else
            echo "rr|wrr|lc|wlc"
        fi
          read -p "NAT|TUN|DR:" mode
             if [ $mode ];then
             case $mode in
             "NAT")
              sed -i "s/DR/$mode/" $DIR_keepconf
              ;;
             "TUN")
              sed -i "s/DR/$mode/" $DIR_keepconf
              ;;
             "DR")
              sed -i "s/DR/$mode/" $DIR_keepconf
            esac
             else
              echo "NAT|TUN|DR"
             fi
                while (( $login == 0 ))
                do
                  echo '+================================+'
                  echo '|        1: add rs ip            |'
                  echo '|        2: exit|break           |'
                  echo '+================================+'
                  read -p "NUM:" num
                         if (( $num == 1 ))
                            then
                              read -p "RS IP:" rs 
                              sed  -i '$d' $DIR_keepconf
                              echo "    real_server $rs 80 {
        weight 1 
        TCP_CHECK { 
          connect_timeout 3
          nb_get_retry 3
          delay_before_retry 3
        }
    }
}" >> $DIR_keepconf
                         elif (( $num == 2 ))
                            then
                            break
                         else
                            continue   
                         fi
              done
   fi            
  fi    
 fi  
 systemctl restart keepalived.service 
 ipvsadm -ln | grep $rs
       if [ $? -ge 0  ];then
           echo_success
           echo "lvs+keepalived is succsessful"
       else
           echo_warning
           echo "lvs+keepalived is failed"
       fi
fi     
