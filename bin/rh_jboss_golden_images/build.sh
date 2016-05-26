#!/bin/sh
#
# This script builds the company specific Red Hat JBoss EAP gold-master distributions.
#

#set -x

readonly CURRENT=$(pwd)
readonly FILE_LOG="${CURRENT}/build.log"

rm -f ${FILE_LOG}

# Build the Red Hat JBoss EAP 6_4_7 golden image
./build_6_x_x.sh ${FILE_LOG} 6.4.7

# Build the Red Hat JBoss EAP 6_4_7 golden image
./build_6_x_x.sh ${FILE_LOG} 6.4.8

# Build the Red Hat JBoss EAP 7_0_0 golden image
./build_7_0_0.sh ${FILE_LOG}
