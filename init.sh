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
vagrant up host-dev-eap-01

# Backup and removes the ssh known_hosts (prevents issues with ssh)
mv -n ~/.ssh/known_hosts{,_$(date +%s).orig}

# Provision the virtual machine
cd ${CURRENT}
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i inventory/hosts-dev site.yml

echo "======================================================================================================"
echo " Congratulations, you just setup your Red Hat JBoss middleware successfully!"
echo " "
echo " Check the running applications here:"
echo "    http://192.168.0.101:9080/ticket-monster/"
echo "    http://192.168.0.101:8080/petclinic-2.3.0/"
echo " "
echo " Execute this command for running Ansible again:"
echo "     $ ansible-playbook -i inventory/hosts-dev site.yml"
echo "======================================================================================================"
