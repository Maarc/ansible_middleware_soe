# Ansible-based Red Hat JBoss EAP SOE

This project is an example showing how to implement a Red Hat JBoss middleware Standard Operating Environment (SOE) using Ansible.

## Setup

To get started quickly with your SOE, you will need to install Ansible, Vagrant and VirtualBox locally. In addition to this, you will have to download and copy the Red Hat JBoss binaries from the [Red Hat Customer Support Portal](https://www.redhat.com/wapps/sso/login.html?redirect=https%3A%2F%2Faccess.redhat.com%2Fjbossnetwork%2Frestricted%2FlistSoftware.html)

### Ansible

Ansible 2 or newer is required.

Centos / RHEL / Other::
Please follow [the official](https://docs.ansible.com/ansible/intro_installation.html) instructions.

MacOS::
Please follow [those instructions](https://valdhaus.co/writings/ansible-mac-osx/) to install Ansible.

### Vagrant

Please follow [those instructions](https://www.vagrantup.com/docs/installation/) to setup [Vagrant](https://www.vagrantup.com/).


### Red Hat JBoss binaries

Please download the following Red Hat JBoss binaries from the [Red Hat Customer Support Portal](https://www.redhat.com/wapps/sso/login.html?redirect=https%3A%2F%2Faccess.redhat.com%2Fjbossnetwork%2Frestricted%2FlistSoftware.html)

* jboss-eap-6.4.0.zip
* jboss-eap-6.4.7-patch.zip
* jboss-eap-6.4.8-patch.zip
* jboss-eap-native-6.4.0-RHEL6-x86_64.zip
* jboss-eap-7.0.0.zip

... and copy them into

	./bin/rh_jboss_binaries


### SOE initialization

To initialize the JBoss middleware Standard Operating Environment, just execute:

		$ ./init.sh

It might takes a while to create all virtual machines and provision them.


## Test

The deployed test applications can be accessed here:

* http://192.168.0.102:8080/ticket-monster/
* http://192.168.0.102:9080/petclinic/
* http://192.168.0.102:10080/jenkins/


## Troubleshooting


If you encounter an error looking like ...

	fatal: [host-dev-eap-01]: UNREACHABLE! => {"changed": false, "msg": "SSH encountered an unknown error during the connection. We recommend you re-run the command using -vvvv, which will enable SSH debugging output to help diagnose the issue", "unreachable": true}

... either your virtual machine is down and you need to start it:

  cd vagrant; vagrant up host-dev-eap-01; cd ..


... or you need to cleanup your .ssh/known_hosts file. For example like that:

  mv -n ~/.ssh/known_hosts{,_$(date +%s).orig}



## Extend

To re-run the provisioning, just execute:

		$ ansible-playbook -i inventory/hosts-dev site.yml


Here is a brief description of the structure of this projects:

* **bin** contains all binaries necessary for the SOE.
 - **bin/java_binaries** contains the java applications retrieved and built for the SOE.
 - **bin/java_code** contains the java code retrieved and built for the SOE.
 - **bin/rh_jboss_golden_images** contains everything required to build automatically a set of golden images for the versioned middleware platforms that are in the book of standards of your organization.
 - **bin/rh_jboss_binaries** contains the Red Hat JBoss binaries from the [Red Hat Customer Support Portal](https://www.redhat.com/wapps/sso/login.html?redirect=https%3A%2F%2Faccess.redhat.com%2Fjbossnetwork%2Frestricted%2FlistSoftware.html).
* **group_vars** contains the ansible [group variables](https://docs.ansible.com/ansible/playbooks_variables.html).
* **inventory** contains the [ansible inventory](https://docs.ansible.com/ansible/intro_inventory.html). "hosts-dev" lists the host for the development environment. At the same level, you can add a "host-int" or "host-prod" file listing your orchestrated hosts in the integration or production staging environments.
* **roles** contains the main roles of this SOE implementations:
 - **roles/rh_jboss_core** is the core role for all managed hosts.
 - **roles/rh_jboss_eap** is the basis role for JBoss EAP instances. The role is quite parametrizable, registers the instance as a service and supports multiple instances on a same host.
 - **roles/rh_jboss_eap__app__direct_copy** is a role extending rh_jboss_eap and deploying a simple application copying it from the host manager.
 - **roles/rh_jboss_eap__app__nexus** is a role extending rh_jboss_eap and deploying a simple application retrieving it from Nexus.
 - **roles/rh_jboss_web_server__apache** is a role installing a JWS apache (HTTPD) server.
 - **roles/rh_jboss_web_server__tomcat** is a role installing a JWS Tomcat server.
* **vagrant/Vagrantfile** contains a description of you virtual machines managed by vagrant.
