#!/bin/bash
#
# $Header: /home/rcitton/CVS/vagrant_rac-2.0.1/scripts/08_asmlib_label_disk.sh,v 2.0.1.2 2018/11/14 16:34:49 rcitton Exp $
#
#
# Copyright (c) 1982-2018 Oracle and/or its affiliates. All rights reserved.
#
#    NAME
#      08_asmlib_label_disk.sh
#
#    DESCRIPTION
#      Setup ASMLib disks
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
/usr/sbin/oracleasm configure -u grid -g asmadmin -e -b -s y
/usr/sbin/oracleasm init

LETTER=d
SDISKSNUM=$(ls -l /dev/sd[d-z]|wc -l)
for (( i=1; i<=$SDISKSNUM; i++ ))
do
  DISK="ORCL_DISK${i}_P1"
  DEVICE="/dev/sd${LETTER}1";
  /usr/sbin/oracleasm createdisk ${DISK} ${DEVICE}
  LETTER=$(echo "$LETTER" | tr "0-9a-z" "1-9a-z_")
done

LETTER=d
SDISKSNUM=$(ls -l /dev/sd[d-z]|wc -l)
for (( i=1; i<=$SDISKSNUM; i++ ))
do
  DISK="ORCL_DISK${i}_P2"
  DEVICE="/dev/sd${LETTER}2";
  /usr/sbin/oracleasm createdisk ${DISK} ${DEVICE}
  LETTER=$(echo "$LETTER" | tr "0-9a-z" "1-9a-z_")
done

/usr/sbin/oracleasm scandisks
/usr/sbin/oracleasm listdisks

#----------------------------------------------------------
# EndOfFile
#----------------------------------------------------------
