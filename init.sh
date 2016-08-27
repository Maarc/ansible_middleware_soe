#!/bin/sh
# Initializes the Red Hat JBoss middleware SOE

#set -x

CURRENT=$(pwd)

IS_NEXUS=false
IS_TOWER=false

for var in "$@"
do
  case $var in
  "nexus")
    IS_NEXUS=true
    ;;
  "tower")
    IS_TOWER=true
    ;;
  esac
done

echo " >>> Retrieve required Ansible roles"
ansible-galaxy install -r roles/requirements.yml -p roles --force

echo " >>> Prepare locale file structure, build applications and golden images"
ansible-playbook local.yml

# Backup and removes the ssh known_hosts (prevents issues with ssh)
mv -n ~/.ssh/known_hosts{,_$(date +%s).orig}

echo " >>> Create and start the virtual machine(s)"
cd ${CURRENT}/vagrant
vagrant up host-dev-01
vagrant up host-dev-02
vagrant up host-dev-03

if $IS_NEXUS; then
  vagrant up nexus
fi

if $IS_TOWER ; then
  vagrant up tower
else
  echo " >>> Provision the virtual machine(s) with ansible"
  cd ${CURRENT}
  ansible-playbook site.yml
fi

if $IS_TOWER ; then
  echo "================================================================================="
  echo " Congratulations, you just prepared your Red Hat JBoss middleware successfully!"
  echo " "
  echo " To provision your virtual machines, please log into Ansible Tower (https://192.168.0.200/)"
  echo "      using the previously displayed user and password."
  echo " "
  echo "================================================================================="
else
  echo "================================================================================="
  echo " Congratulations, you just setup your Red Hat JBoss middleware successfully!"
  echo " "
  echo " Check the running applications here:"
  echo "    http://192.168.0.101/ticket-monster/"
  echo "    http://192.168.0.101/petclinic/"
  echo "    http://192.168.0.101/jenkins/"
  echo " "
  echo " Execute this command for running Ansible again:"
  echo "     $ ansible-playbook site.yml"
  echo "================================================================================="
fi
