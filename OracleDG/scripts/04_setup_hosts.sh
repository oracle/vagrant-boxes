#!/bin/bash
#
# $Header: /home/rcitton/CVS/vagrant_dg-2.0.1/scripts/04_setup_hosts.sh,v 2.0.1.1 2018/12/10 11:15:28 rcitton Exp $
#
# LICENSE UPL 1.0
#
# Copyright (c) 1982-2018 Oracle and/or its affiliates. All rights reserved.
#
#    NAME
#      03_setup_hosts.sh
#
#    DESCRIPTION
#      Setup for '/etc/hosts'
#
#    NOTES
#       DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#
#    AUTHOR
#       ruggero.citton@oracle.com
#
#    MODIFIED   (MM/DD/YY)
#    rcitton     11/06/18 - Creation
#
. /vagrant_config/setup.env
echo "-----------------------------------------------------------------"
echo -e "${INFO}`date +%F' '%T`: Setup /etc/hosts"
echo "-----------------------------------------------------------------"

cat > /etc/hosts <<EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
EOF

cat >> /etc/hosts <<EOF
# Public host info
${NODE1_PUBLIC_IP}  ${NODE1_FQ_HOSTNAME}  ${NODE1_HOSTNAME}
${NODE2_PUBLIC_IP}  ${NODE2_FQ_HOSTNAME}  ${NODE2_HOSTNAME}
# Private host info
${NODE1_PRIV_IP}  ${NODE1_FQ_PRIVNAME}   ${NODE1_PRIVNAME}
${NODE2_PRIV_IP}  ${NODE2_FQ_PRIVNAME}   ${NODE2_PRIVNAME}
# Virtual host info
${NODE1_VIP_IP}  ${NODE1_FQ_VIPNAME}    ${NODE1_VIPNAME}
${NODE2_VIP_IP}  ${NODE2_FQ_VIPNAME}    ${NODE2_VIPNAME}
EOF

echo "-----------------------------------------------------------------"
echo -e "${INFO}`date +%F' '%T`: Setup /etc/resolv.conf"
echo "-----------------------------------------------------------------"
cat > /etc/resolv.conf <<EOF
search localdomain
nameserver ${DNS_PUBLIC_IP}
EOF

#----------------------------------------------------------
# EndOfFile
#----------------------------------------------------------
