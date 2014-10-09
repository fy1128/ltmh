#!/bin/bash

# Check if user is root
[ $(id -u) != "0" ] && echo "Error: You must be root to run this script" && exit 1 

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
printf "
#############################################################################
#   LTMH/LNMH/LNMP/LTMP for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+       #
#   For more information please visit http://www.hhvmc.com/forum-36-1.html   #
############################################################################"

#get pwd
sed -i "s@^ltmh_dir.*@ltmh_dir=`pwd`@" ./options.conf

# get local ip address
local_IP=`./tools/get_local_ip.py`

# Definition Directory
. ./options.conf
. tools/check_os.sh
mkdir -p $home_dir/default $wwwlogs_dir $ltmh_dir/{src,conf}

# choice upgrade OS
while :
do
        echo
        read -p "Do you want to upgrade operating system ? [y/n]: " upgrade_yn
        if [ "$upgrade_yn" != 'y' -a "$upgrade_yn" != 'n' ];then
                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
        else
                [ -e init/init_*.ed -a "$upgrade_yn" == 'y' ] && { echo -e "\033[31mYour system is already upgraded! \033[0m" ; upgrade_yn=n ; }
                break
        fi
done

# check Web server
while :
do
        echo
        read -p "Do you want to install Web server? [y/n]: " Web_yn
        if [ "$Web_yn" != 'y' -a "$Web_yn" != 'n' ];then
                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
        else
                if [ "$Web_yn" == 'y' ];then
                        [ -d "$web_install_dir" ] && { echo -e "\033[31mThe web service already installed! \033[0m" ; Web_yn=n ; break ; }
                        while :
                        do
                                echo
                                echo 'Please select Nginx server:'
                                echo -e "\t\033[32m1\033[0m. Install Nginx"
                                echo -e "\t\033[32m2\033[0m. Install Tengine"
                                echo -e "\t\033[32m3\033[0m. Do not install"
                                read -p "Please input a number:(Default 1 press Enter) " Nginx_version
                                [ -z "$Nginx_version" ] && Nginx_version=1
                                if [ $Nginx_version != 1 -a $Nginx_version != 2 -a $Nginx_version != 3 ];then
                                        echo -e "\033[31minput error! Please only input number 1,2,3\033[0m"
                                else
                                if [ $Nginx_version = 1 -o $Nginx_version = 2 ];then
                                        break;
                                fi

                                break
                                fi
                        done
                fi
                break
        fi
done

# choice database
while :
do
        echo
        read -p "Do you want to install Database? [y/n]: " DB_yn
        if [ "$DB_yn" != 'y' -a "$DB_yn" != 'n' ];then
                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
        else
                if [ "$DB_yn" == 'y' ];then
                        [ -d "$db_install_dir" ] && { echo -e "\033[31mThe database already installed! \033[0m" ; DB_yn=n ; break ; }
                        while :
                        do
                                echo
                                echo 'Please select a version of the Database:'
                                echo -e "\t\033[32m1\033[0m. Install MySQL-5.6"
                                echo -e "\t\033[32m2\033[0m. Install MySQL-5.5"
                                echo -e "\t\033[32m3\033[0m. Install MariaDB-10.0"
                                echo -e "\t\033[32m4\033[0m. Install MariaDB-5.5"
                                read -p "Please input a number:(Default 1 press Enter) " DB_version
                                [ -z "$DB_version" ] && DB_version=1
                                if [ $DB_version != 1 -a $DB_version != 2 -a $DB_version != 3 -a $DB_version != 4 ];then
                                        echo -e "\033[31minput error! Please only input number 1,2,3,4 \033[0m"
                                else
                                        while :
                                        do
                                                read -p "Please input the root password of database: " dbrootpwd
                                                (( ${#dbrootpwd} >= 5 )) && sed -i "s@^dbrootpwd.*@dbrootpwd=$dbrootpwd@" ./options.conf && break || echo -e "\033[31mdatabase root password least 5 characters! \033[0m"
                                        done
                                        break
                                fi
                        done
                fi
                break
        fi
done

# check PHP
while :
do
echo
read -p "Do you want to install PHP? [y/n]: " PHP_yn
if [ "$PHP_yn" != 'y' -a "$PHP_yn" != 'n' ];then
        echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
else
        if [ "$PHP_yn" == 'y' ];then
                [ -d "$php_install_dir" ] && { echo -e "\033[31mThe php already installed! \033[0m" ; PHP_yn=n ; break ; }
                while :
                do
                        echo
                        echo 'Please select a version of the PHP:'
                        echo -e "\t\033[32m1\033[0m. Install php-5.5"
                        echo -e "\t\033[32m2\033[0m. Install php-5.4"
                        echo -e "\t\033[32m3\033[0m. Install php-5.3"
                        read -p "Please input a number:(Default 1 press Enter) " PHP_version
                        [ -z "$PHP_version" ] && PHP_version=1
                        if [ $PHP_version != 1 -a $PHP_version != 2 -a $PHP_version != 3 ];then
                                echo -e "\033[31minput error! Please only input number 1,2,3 \033[0m"
                        else
                                while :
                                        do
                                        echo
                                        echo 'You can either use the mysqlnd or libmysql library to connect from PHP to MySQL:'
                                        echo -e "\t\033[32m1\033[0m. MySQL native driver (mysqlnd)"
                                        echo -e "\t\033[32m2\033[0m. MySQL Client Library (libmysql)"
                                        read -p "Please input a number:(Default 1 press Enter) " PHP_MySQL_driver
                                        [ -z "$PHP_MySQL_driver" ] && PHP_MySQL_driver=1
                                        if [ $PHP_MySQL_driver != 1 -a $PHP_MySQL_driver != 2 ];then
                                                echo -e "\033[31minput error! Please only input number 1,2\033[0m"
                                        else
                                                break
                                        fi
                                done

				while :
				do
					echo
					read -p "Do you want to install opcode cache of the PHP? [y/n]: " PHP_cache_yn 
					if [ "$PHP_cache_yn" != 'y' -a "$PHP_cache_yn" != 'n' ];then
						echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
					else
						if [ "$PHP_cache_yn" == 'y' ];then	
		                                        if [ $PHP_version == 1 ];then
		                                                while :
		                                                do
		                                                        echo 'Please select a opcode cache of the PHP:'
		                                                        echo -e "\t\033[32m1\033[0m. Install Zend OPcache"
		                                                        echo -e "\t\033[32m2\033[0m. Install XCache"
		                                                        echo -e "\t\033[32m3\033[0m. Install APCU"
		                                                        read -p "Please input a number:(Default 1 press Enter) " PHP_cache
		                                                        [ -z "$PHP_cache" ] && PHP_cache=1
		                                                        if [ $PHP_cache != 1 -a $PHP_cache != 2 -a $PHP_cache != 3 ];then
		                                                                echo -e "\033[31minput error! Please only input number 1,2,3\033[0m"
		                                                        else
		                                                                break
		                                                        fi
		                                                done
		                                        fi
		                                        if [ $PHP_version == 2 ];then
		                                                while :
		                                                do
		                                                        echo 'Please select a opcode cache of the PHP:'
		                                                        echo -e "\t\033[32m1\033[0m. Install Zend OPcache"
		                                                        echo -e "\t\033[32m2\033[0m. Install XCache"
		                                                        echo -e "\t\033[32m3\033[0m. Install APCU"
		                                                        echo -e "\t\033[32m4\033[0m. Install eAccelerator-1.0-dev"
		                                                        read -p "Please input a number:(Default 1 press Enter) " PHP_cache
		                                                        [ -z "$PHP_cache" ] && PHP_cache=1
		                                                        if [ $PHP_cache != 1 -a $PHP_cache != 2 -a $PHP_cache != 3 -a $PHP_cache != 4 ];then
		                                                                echo -e "\033[31minput error! Please only input number 1,2,3,4\033[0m"
		                                                        else
		                                                                break
		                                                        fi
		                                                done
		                                        fi
		                                        if [ $PHP_version == 3 ];then
		                                                while :
		                                                do
		                                                        echo 'Please select a opcode cache of the PHP:'
		                                                        echo -e "\t\033[32m1\033[0m. Install Zend OPcache"
		                                                        echo -e "\t\033[32m2\033[0m. Install XCache"
		                                                        echo -e "\t\033[32m3\033[0m. Install APCU"
		                                                        echo -e "\t\033[32m4\033[0m. Install eAccelerator-0.9"
		                                                        read -p "Please input a number:(Default 1 press Enter) " PHP_cache
		                                                        [ -z "$PHP_cache" ] && PHP_cache=1
		                                                        if [ $PHP_cache != 1 -a $PHP_cache != 2 -a $PHP_cache != 3 -a $PHP_cache != 4 ];then
		                                                                echo -e "\033[31minput error! Please only input number 1,2,3,4\033[0m"
		                                                        else
		                                                                break
		                                                        fi
		                                                done
		                                        fi
                                                fi
						break
                                        fi
                                done
                                if [ "$PHP_cache" == '2' ];then
                                        while :
                                        do
                                                read -p "Please input xcache admin password: " xcache_admin_pass
                                                (( ${#xcache_admin_pass} >= 5 )) && { xcache_admin_md5_pass=`echo -n "$xcache_admin_pass" | md5sum | awk '{print $1}'` ; break ; } || echo -e "\033[31mxcache admin password least 5 characters! \033[0m"
                                        done
                                fi
				if [ "$PHP_version" == '2' -o "$PHP_version" == '3' ];then
                                        while :
                                        do
                                                echo
                                                read -p "Do you want to install ZendGuardLoader? [y/n]: " ZendGuardLoader_yn
                                                if [ "$ZendGuardLoader_yn" != 'y' -a "$ZendGuardLoader_yn" != 'n' ];then
                                                        echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
                                                else
                                                        break
                                                fi
                                        done
                                fi

                                while :
                                do
                                        echo
                                        read -p "Do you want to install ionCube? [y/n]: " ionCube_yn
                                        if [ "$ionCube_yn" != 'y' -a "$ionCube_yn" != 'n' ];then
                                                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
                                        else
                                                break
                                        fi
                                done

                                while :
                                do
                                        echo
                                        read -p "Do you want to install ImageMagick or GraphicsMagick? [y/n]: " Magick_yn
                                        if [ "$Magick_yn" != 'y' -a "$Magick_yn" != 'n' ];then
                                                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
                                        else
                                                break
                                        fi
                                done
                                if [ "$Magick_yn" == 'y' ];then
                                        while :
                                        do
                                                echo 'Please select ImageMagick or GraphicsMagick:'
                                                echo -e "\t\033[32m1\033[0m. Install ImageMagick"
                                                echo -e "\t\033[32m2\033[0m. Install GraphicsMagick"
                                                read -p "Please input a number:(Default 1 press Enter) " Magick
                                                [ -z "$Magick" ] && Magick=1
                                                if [ $Magick != 1 -a $Magick != 2 ];then
                                                        echo -e "\033[31minput error! Please only input number 1,2 \033[0m"
                                                else
                                                        break
                                                fi
                                        done
                                fi

                                break
                        fi
                done
        fi
        break
fi
done

if [ "$Web_yn" == 'y' -a "$DB_yn" == 'y' -a "$PHP_yn" == 'y' ];then
# check Pureftpd
while :
do
        echo
        read -p "Do you want to install Pure-FTPd? [y/n]: " FTP_yn
        if [ "$FTP_yn" != 'y' -a "$FTP_yn" != 'n' ];then
                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
        else

                if [ "$FTP_yn" == 'y' ];then
                        [ -d "$pureftpd_install_dir" ] && { echo -e "\033[31mThe FTP service already installed! \033[0m" ; FTP_yn=n ; break ; }
                        while :
                        do
                                read -p "Please input the manager password of Pure-FTPd: " ftpmanagerpwd
                                if (( ${#ftpmanagerpwd} >= 5 ));then
                                        sed -i "s@^ftpmanagerpwd.*@ftpmanagerpwd=$ftpmanagerpwd@" options.conf
                                        break
                                else
                                        echo -e "\033[31mFtp manager password least 5 characters! \033[0m"
                                fi
                        done
                fi
                break
        fi
done
fi

# check phpMyAdmin
while :
do
        echo
        read -p "Do you want to install phpMyAdmin? [y/n]: " phpMyAdmin_yn
        if [ "$phpMyAdmin_yn" != 'y' -a "$phpMyAdmin_yn" != 'n' ];then
                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
        else
		if [ "$phpMyAdmin_yn" == 'y' ];then
		        [ -d "$home_dir/default/phpMyAdmin" ] && echo -e "\033[31mThe phpMyAdmin already installed! \033[0m" && phpMyAdmin_yn=n && break
		fi
                break
        fi
done

# check redis
while :
do
	echo
	read -p "Do you want to install redis? [y/n]: " redis_yn
	if [ "$redis_yn" != 'y' -a "$redis_yn" != 'n' ];then
                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
	else
		if [ "$redis_yn" == 'y' ];then
			[ -d "$redis_install_dir" ] && { echo -e "\033[31mThe redis already installed! \033[0m" ; redis_yn=n ; break ; }
		fi
		break
	fi
done

# check memcached
while :
do
	echo
        read -p "Do you want to install memcached? [y/n]: " memcached_yn
        if [ "$memcached_yn" != 'y' -a "$memcached_yn" != 'n' ];then
                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
        else
		if [ "$memcached_yn" == 'y' ];then
			[ -d "$memcached_install_dir" ] && { echo -e "\033[31mThe memcached already installed! \033[0m" ; memcached_yn=n ; break ; }
		fi
                break
        fi
done

chmod +x shell/*.sh init/* *.sh

# init
if [ "$OS" == 'CentOS' ];then
	. init/init_CentOS.sh 2>&1 | tee $ltmh_dir/install.log
	[ -n "`gcc --version | head -n1 | grep '4\.1\.'`" ] && export CC="gcc44" CXX="g++44"
elif [ "$OS" == 'Debian' ];then
	. init/init_Debian.sh 2>&1 | tee $ltmh_dir/install.log
elif [ "$OS" == 'Ubuntu' ];then
	. init/init_Ubuntu.sh 2>&1 | tee $ltmh_dir/install.log
fi

# Optimization compiled code using safe, sane CFLAGS and CXXFLAGS
if [ "$gcc_sane_yn" == 'y' ];then
        if [ `getconf WORD_BIT` == 32 ] && [ `getconf LONG_BIT` == 64 ];then
                export CHOST="x86_64-pc-linux-gnu" CFLAGS="-march=native -O3 -pipe -fomit-frame-pointer"
                export CXXFLAGS="${CFLAGS}"
        elif [ `getconf WORD_BIT` == 32 ] && [ `getconf LONG_BIT` == 32 ];then
                export CHOST="i686-pc-linux-gnu" CFLAGS="-march=native -O3 -pipe -fomit-frame-pointer"
                export CXXFLAGS="${CFLAGS}"
        fi
fi

# jemalloc or tcmalloc
	. shell/jemalloc.sh
	Install_jemalloc | tee -a $ltmh_dir/install.log


# Database
if [ "$DB_version" == '1' ];then
	. shell/mysql-5.6.sh 
	Install_MySQL-5-6 2>&1 | tee -a $ltmh_dir/install.log 
elif [ "$DB_version" == '2' ];then
        . shell/mysql-5.5.sh
        Install_MySQL-5-5 2>&1 | tee -a $ltmh_dir/install.log
elif [ "$DB_version" == '3' ];then
	. shell/mariadb-10.0.sh
	Install_MariaDB-10-0 2>&1 | tee -a $ltmh_dir/install.log 
elif [ "$DB_version" == '4' ];then
	. shell/mariadb-5.5.sh
	Install_MariaDB-5-5 2>&1 | tee -a $ltmh_dir/install.log 
fi

# PHP MySQL Client
if [ "$DB_yn" == 'n' -a "$PHP_yn" == 'y' -a "$PHP_MySQL_driver" == '2' ];then
	. shell/php-mysql-client.sh
	Install_PHP-MySQL-Client 2>&1 | tee -a $ltmh_dir/install.log
fi

# PHP
if [ "$PHP_version" == '1' ];then
	. shell/php-5.5.sh
	Install_PHP-5-5 2>&1 | tee -a $ltmh_dir/install.log
elif [ "$PHP_version" == '2' ];then
        . shell/php-5.4.sh
        Install_PHP-5-4 2>&1 | tee -a $ltmh_dir/install.log
elif [ "$PHP_version" == '3' ];then
        . shell/php-5.3.sh
        Install_PHP-5-3 2>&1 | tee -a $ltmh_dir/install.log
fi

# ImageMagick or GraphicsMagick
if [ "$Magick" == '1' ];then
	. shell/ImageMagick.sh
	Install_ImageMagick 2>&1 | tee -a $ltmh_dir/install.log
elif [ "$Magick" == '2' ];then
	. shell/GraphicsMagick.sh
	Install_GraphicsMagick 2>&1 | tee -a $ltmh_dir/install.log
fi

# ionCube
if [ "$ionCube_yn" == 'y' ];then
        . shell/ioncube.sh
        Install_ionCube 2>&1 | tee -a $ltmh_dir/install.log
fi

# PHP opcode cache
if [ "$PHP_cache" == '1' -a "$PHP_version" != '1' ];then
        . shell/zendopcache.sh
        Install_ZendOPcache 2>&1 | tee -a $ltmh_dir/install.log
elif [ "$PHP_cache" == '2' ];then
        . shell/xcache.sh 
        Install_XCache 2>&1 | tee -a $ltmh_dir/install.log
elif [ "$PHP_cache" == '3' ];then
        . shell/apcu.sh
        Install_APCU 2>&1 | tee -a $ltmh_dir/install.log
elif [ "$PHP_cache" == '4' -a "$PHP_version" == '2' ];then
        . shell/eaccelerator-1.0-dev.sh
        Install_eAccelerator-1-0-dev 2>&1 | tee -a $ltmh_dir/install.log
elif [ "$PHP_cache" == '4' -a "$PHP_version" == '3' ];then
        . shell/eaccelerator-0.9.sh
        Install_eAccelerator-0-9 2>&1 | tee -a $ltmh_dir/install.log
fi

# ZendGuardLoader (php <= 5.4)
if [ "$ZendGuardLoader_yn" == 'y' ];then
	. shell/ZendGuardLoader.sh
        Install_ZendGuardLoader 2>&1 | tee -a $ltmh_dir/install.log
fi

# Web server
if [ "$Nginx_version" == '1' ];then
        . shell/nginx.sh
        Install_Nginx 2>&1 | tee -a $ltmh_dir/install.log
elif [ "$Nginx_version" == '2' ];then
	. shell/tengine.sh
        Install_Tengine 2>&1 | tee -a $ltmh_dir/install.log
fi

# Pure-FTPd
if [ "$FTP_yn" == 'y' ];then
	. shell/pureftpd.sh
	Install_PureFTPd 2>&1 | tee -a $ltmh_dir/install.log 
fi

# phpMyAdmin
if [ "$phpMyAdmin_yn" == 'y' ];then
	. shell/phpmyadmin.sh
	Install_phpMyAdmin 2>&1 | tee -a $ltmh_dir/install.log
fi

# redis
if [ "$redis_yn" == 'y' ];then
	. shell/redis.sh
	Install_redis 2>&1 | tee -a $ltmh_dir/install.log
fi

# memcached
if [ "$memcached_yn" == 'y' ];then
	. shell/memcached.sh
	Install_memcached 2>&1 | tee -a $ltmh_dir/install.log
fi


# get db_install_dir and web_install_dir
. ./options.conf

# index example
if [ ! -e "$home_dir/default/index.html" -a "$Web_yn" == 'y' ];then
	. tools/init.sh
	INIT 2>&1 | tee -a $ltmh_dir/install.log 
fi

echo "####################Congratulations########################"
[ "$Web_yn" == 'y' -a "$Nginx_version" != '3' ] && echo -e "\n`printf "%-32s" "Nginx/Tengine install dir":`\033[32m$web_install_dir\033[0m"
[ "$DB_yn" == 'y' ] && echo -e "\n`printf "%-32s" "Database install dir:"`\033[32m$db_install_dir\033[0m"
[ "$DB_yn" == 'y' ] && echo -e "`printf "%-32s" "Database data dir:"`\033[32m$db_data_dir\033[0m"
[ "$DB_yn" == 'y' ] && echo -e "`printf "%-32s" "Database user:"`\033[32mroot\033[0m"
[ "$DB_yn" == 'y' ] && echo -e "`printf "%-32s" "Database password:"`\033[32m${dbrootpwd}\033[0m"
[ "$PHP_yn" == 'y' ] && echo -e "\n`printf "%-32s" "PHP install dir:"`\033[32m$php_install_dir\033[0m"
[ "$PHP_cache" == '1' ] && echo -e "`printf "%-32s" "Opcache Control Panel url:"`\033[32mhttp://$local_IP/ocp.php\033[0m" 
[ "$PHP_cache" == '2' ] && echo -e "`printf "%-32s" "xcache Control Panel url:"`\033[32mhttp://$local_IP/xcache\033[0m"
[ "$PHP_cache" == '2' ] && echo -e "`printf "%-32s" "xcache user:"`\033[32madmin\033[0m"
[ "$PHP_cache" == '2' ] && echo -e "`printf "%-32s" "xcache password:"`\033[32m$xcache_admin_pass\033[0m"
[ "$PHP_cache" == '3' ] && echo -e "`printf "%-32s" "APC Control Panel url:"`\033[32mhttp://$local_IP/apc.php\033[0m" 
[ "$PHP_cache" == '4' ] && echo -e "`printf "%-32s" "eAccelerator Control Panel url:"`\033[32mhttp://$local_IP/control.php\033[0m"
[ "$PHP_cache" == '4' ] && echo -e "`printf "%-32s" "eAccelerator user:"`\033[32madmin\033[0m"
[ "$PHP_cache" == '4' ] && echo -e "`printf "%-32s" "eAccelerator password:"`\033[32meAccelerator\033[0m"
[ "$FTP_yn" == 'y' ] && echo -e "\n`printf "%-32s" "Pure-FTPd install dir:"`\033[32m$pureftpd_install_dir\033[0m"
[ "$FTP_yn" == 'y' ] && echo -e "`printf "%-32s" "Pure-FTPd php manager dir:"`\033[32m$home_dir/default/ftp\033[0m"
[ "$FTP_yn" == 'y' ] && echo -e "`printf "%-32s" "Ftp User Control Panel url:"`\033[32mhttp://$local_IP/ftp\033[0m"
[ "$phpMyAdmin_yn" == 'y' ] && echo -e "\n`printf "%-32s" "phpMyAdmin dir:"`\033[32m$home_dir/default/phpMyAdmin\033[0m"
[ "$phpMyAdmin_yn" == 'y' ] && echo -e "`printf "%-32s" "phpMyAdmin Control Panel url:"`\033[32mhttp://$local_IP/phpmyadmin\033[0m"
[ "$redis_yn" == 'y' ] && echo -e "\n`printf "%-32s" "redis install dir:"`\033[32m$redis_install_dir\033[0m"
[ "$memcached_yn" == 'y' ] && echo -e "\n`printf "%-32s" "memcached install dir:"`\033[32m$memcached_install_dir\033[0m"
[ "$Web_yn" == 'y' ] && echo -e "\n`printf "%-32s" "index url:"`\033[32mhttp://$local_IP/\033[0m"
while :
do
        echo
        echo -e "\033[31mPlease restart the server and see if the services start up fine.\033[0m"
        read -p "Do you want to restart OS ? [y/n]: " restart_yn
        if [ "$restart_yn" != 'y' -a "$restart_yn" != 'n' ];then
                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
        else
                break
        fi
done
[ "$restart_yn" == 'y' ] && reboot
