#!/bin/bash
#
# LICENSE UPL 1.0
#
# Copyright (c) 1982-2018 Oracle and/or its affiliates. All rights reserved.
# 
# Since: January, 2018
# Author: gerald.venzl@oracle.com
# Description: Updates Oracle Linux to the latest version
# 
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#

echo 'INSTALLER: Enabling MySQL and Software Collection Yum repositories'

# install yum-config-manager to get yum repos managed
yum install yum-utils -y

# enable software-collection yum repository
yum-config-manager --enable ol7_software_collections

# enable MySQL yum repository
yum-config-manager --enable ol7_MySQL57

echo 'INSTALLER: Installing Apache Web Server from Oracle Linux Software Collections'

# get Apache2 from software-collections installed and running
yum install httpd24 -y
systemctl enable httpd24-httpd
systemctl start httpd24-httpd

echo 'INSTALLER: Installing MySQL Community Release 5.7'

# get MySQL Community 5.7
yum install mysql-community-server.x86_64 mysql-community-client.x86_64 -y
systemctl enable mysqld
systemctl start mysqld

echo 'INSTALLER: Installing PHP 7.1 from Oracle Linux Software Collections'
# get PHP 7.0
yum install rh-php71.x86_64 rh-php71-php rh-php71-php-mysqlnd.x86_64 rh-php71-php-fpm.x86_64 -y
systemctl enable rh-php71-php-fpm
systemctl start rh-php71-php-fpm

echo 'INSTALLER: Configuring Apache Server'
echo "<?php" > /opt/rh/httpd24/root/var/www/html/info.php
echo "phpinfo();" >> /opt/rh/httpd24/root/var/www/html/info.php
echo "?>" >> /opt/rh/httpd24/root/var/www/html/info.php
systemctl restart httpd24-httpd

cat > /etc/motd << EOF

Welcome to Oracle Linux Server release 7.4
LAMP architecture based on Oracle Linux Software Collections:
 - Apache 2.4, MySQL Community 5.7 and PHP 7.1

The Oracle Linux End-User License Agreement can be viewed here:

    * /usr/share/eula/eula.en_US

For additional packages, updates, documentation and community help, see:

    * http://yum.oracle.com/

To test your environment is correctly working, just open following URL from your Host OS:
http://localhost:8080/info.php

Please use following commands to enable Software Collection environments:
- Apache 2.4: # scl enable httpd24 /bin/bash
- PHP 7.1: # scl enable rh-php71 /bin/bash
EOF
