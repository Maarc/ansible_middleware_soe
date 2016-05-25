#!/bin/sh
#
# This script builds the company specific Red Hat JBoss EAP gold-master distributions.
#

set -x

CURRENT=$(pwd)

# Build the Red Hat JBoss EAP 6_4_7 golden image
./build_6_4_7.sh

# Build the Red Hat JBoss EAP 7_0_0 golden image
#./build_7_0_0.sh
