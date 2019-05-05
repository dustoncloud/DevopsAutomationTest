############ Installation Script for nagios -4.3.4 ##################
# SCRIPT SETUP AREA
# Setup those variable accordingly... specially those versions will outdate!
NAGIOSUSER="nagios"
NAGIOSGROUP="nagcmd"
NAGIOSCOREVERSION="nagios-4.3.4"
NAGIOSPLUGINSVERSION="nagios-plugins-2.2.1"


# SCRIPT EXECUTION CODE
echo "Install a LAMP environment."
apt-get install -y wget build-essential apache2 apache2-utils php apache2-mod-php7.0 php-gd libgd-dev sendmail unzip
echo ""
echo "OK"
echo ""
echo ""
echo "Install build environment."
apt-get install -y build-essential libgd2-xpm-dev curl
echo ""
echo "OK"
echo ""
echo ""
echo "Enabling apache2 modules."
a2enmod rewrite
a2enmod cgi
systemctl restart apache2
echo ""
echo "OK"
echo ""
echo ""
echo "We now create the 'nagios' user."
echo "you'll be propmpt for a password..."
useradd -m ${NAGIOSUSER}
passwd ${NAGIOSUSER}
echo ""
echo "OK"
echo ""
echo ""
echo "Creating the 'nagcmd' group."
groupadd ${NAGIOSGROUP}
usermod -a -G ${NAGIOSGROUP} nagios
usermod -a -G ${NAGIOSGROUP} nagcmd www-data
echo ""
echo "OK"
echo ""
echo ""
echo "...downloading nagios-core 4..."
wget https://assets.nagios.com/downloads/nagioscore/releases/${NAGIOSCOREVERSION}.tar.gz -O /usr/src/${NAGIOSCOREVERSION}.tar.gz
echo ""
echo "OK"
echo ""
echo ""
echo "... downloading nagios plugins..."
wget http://www.nagios-plugins.org/download/${NAGIOSPLUGINSVERSION}.tar.gz -O /usr/src/${NAGIOSPLUGINSVERSION}.tar.gz
echo ""
echo "OK"
echo ""
echo ""
echo "Building nagios-core..."
cd /usr/src
tar xzf ${NAGIOSCOREVERSION}.tar.gz
cd ${NAGIOSCOREVERSION}/
./configure --with-nagios-user=${NAGIOSUSER} --with-nagios-group=${NAGIOSGROUP} --with-openssl
make all
make install
make install-init
make install-config
make install-commandmode
make install-webconf
echo ""
echo "OK"
echo ""
echo ""
echo "Now you can change the default nagios web page."
echo "(A backup of original config file will be made prior to change.)"
echo ""
banner='Select the home page (or any key to default): '
options=("default" "tactical" "hosts")
select opt in "${options[@]}"
do
	echo "${banner}"
    case $opt in
        "default")
            echo "let as default..."
			break
            ;;
        "tactical")
            echo "Setting tactical page as default..."
			cp /usr/local/nagios/share/index.php /usr/local/nagios/share/index.php.bak
			sed -i '3s|main.php|/nagios/cgi-bin/tac.cgi|' /usr/local/nagios/share/index.php
			break
            ;;
        "hosts")
			echo "Setting hosts page as default"
			cp /usr/local/nagios/share/index.php /usr/local/nagios/share/index.php.bak
			sed -i '3s|main.php|/nagios/cgi-bin/status.cgi?host=all|' /usr/local/nagios/share/index.php
            break
            ;;
        *)
			echo "Let as default..."
			break
			;;
    esac
done
echo ""
echo "OK"
echo ""
echo ""
echo "Configure login credentials to nagios UI..."
htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
systemctl restart apache2
echo ""
echo "OK"
echo ""
echo ""
echo "Building nagios plugins..."
cd /usr/src
tar xzf ${NAGIOSPLUGINSVERSION}.tar.gz
cd ${NAGIOSPLUGINSVERSION}/
./configure --with-nagios-user=${NAGIOSUSER} --with-nagios-group=${NAGIOSGROUP}
make
make install
echo ""
echo "OK"
echo ""
echo ""
echo "checking nagios..."
/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
echo ""
echo "OK"
echo ""
echo ""
echo "Setting the init script and starting nagios..."
chmod +x /etc/init.d/nagios
/etc/init.d/nagios start
systemctl enable nagios
echo ""
echo "OK"
echo ""
echo ""
echo " Nagios Installed Try from URL"
echo ""
echo "ALL DONE!"
