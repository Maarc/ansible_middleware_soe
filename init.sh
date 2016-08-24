#!/bin/sh
# Initializes the Red Hat JBoss middleware SOE

#set -x

CURRENT=$(pwd)

echo " >>> Retrieve required Ansible roles"
ansible-galaxy install -r requirements.yml -p roles

echo " >>> Build Red Hat Golden Images ..."
cd ${CURRENT}
ansible-playbook local.yml

echo " >>> Download and build Java applications ..."
cd ${CURRENT}/bin/rh_jboss_golden_images
./build.sh

# Backup and removes the ssh known_hosts (prevents issues with ssh)
mv -n ~/.ssh/known_hosts{,_$(date +%s).orig}

echo " >>> Create and start the virtual machine(s) ..."
cd ${CURRENT}/vagrant
vagrant up host-dev-01
vagrant up host-dev-02
#vagrant up host-dev-03
#vagrant up nexus

echo " >>> Provision the virtual machine(s) with ansible..."
cd ${CURRENT}
ansible-playbook site.yml

echo "==========================================================================================="
echo " Congratulations, you just setup your Red Hat JBoss middleware successfully!"
echo " "
echo " Check the running applications here:"
echo "    http://192.168.0.101/ticket-monster/"
echo "    http://192.168.0.101/petclinic/"
echo "    http://192.168.0.101/jenkins/"
echo " "
echo " Execute this command for running Ansible again:"
echo "     $ ansible-playbook site.yml"
echo "==========================================================================================="
