#!/bin/sh

# Initializes the Red Hat JBoss middleware SOE

set -x

CURRENT=$(pwd)

# Build Red Hat Golden Images
cd ${CURRENT}/bin/rh_jboss_golden_images
./build.sh

# Downloand and build Java applications
cd ${CURRENT}/bin/java_applications
./build.sh

# Create and start the virtualmachine
cd ${CURRENT}/vagrant
vagrant up

# Backup and removes the ssh known_hosts (prevents issues with ssh)
mv -n ~/.ssh/known_hosts{,_$(date +%s).orig}

# Provision the virtual machine
cd ${CURRENT}
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i inventory/hosts-dev site.yml
