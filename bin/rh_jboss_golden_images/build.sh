#!/bin/sh
#
# This script builds the company specific Red Hat JBoss EAP golden images distributions.
#
# Feel free to extend these builds or remove existing ones.
#

#set -x

readonly CURRENT=$(pwd)
readonly FILE_LOG="${CURRENT}/build.log"

rm -f ${FILE_LOG}

# Build the Red Hat JBoss EAP 6_4_8 golden image
./build_6_4_x.sh ${FILE_LOG} 6.4.8

# Build the Red Hat JBoss EAP 6_4_9 golden image
./build_6_4_x.sh ${FILE_LOG} 6.4.9

# Build the Red Hat JBoss EAP 7_0_1 golden image
./build_7_0_x.sh ${FILE_LOG} 7.0.1
