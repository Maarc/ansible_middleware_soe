# JBoss middleware orchestration with Ansible

This project is an example showing how to implement a Red Hat middleware Standard Operating Environment (SOE) using Ansible and Ansible Tower.

## Prerequisites

To get started quickly with your SOE, you will need to install Ansible, Vagrant and VirtualBox locally. In addition to this, you will have to download and copy the Red Hat JBoss binaries from the [Red Hat Customer Support Portal](https://www.redhat.com/wapps/sso/login.html?redirect=https%3A%2F%2Faccess.redhat.com%2Fjbossnetwork%2Frestricted%2FlistSoftware.html)

*1) Install [Vagrant](https://www.vagrantup.com/)*

Please follow [those instructions](https://www.vagrantup.com/docs/installation/) to setup [Vagrant](https://www.vagrantup.com/).

*2) Install [Ansible](https://www.ansible.com/)*

* *Centos / RHEL / Other* - Please follow [the official](https://docs.ansible.com/ansible/intro_installation.html) instructions.
* *MacOS* - Please follow [those instructions](https://valdhaus.co/writings/ansible-mac-osx/).

*3) Retrieve the required Red Hat JBoss binaries*

Please download the following Red Hat JBoss binaries from the [Red Hat Customer Support Portal](https://www.redhat.com/wapps/sso/login.html?redirect=https%3A%2F%2Faccess.redhat.com%2Fjbossnetwork%2Frestricted%2FlistSoftware.html) in a local directory of your choice.

* jboss-eap-6.4.0.zip
* jboss-eap-6.4.8-patch.zip
* jboss-eap-6.4.9-patch.zip
* jboss-eap-native-6.4.0-RHEL7-x86_64.zip
* jboss-eap-7.0.0.zip
* jboss-eap-7.0.1-patch.zip
* jws-application-servers-3.0.3-RHEL7-x86_64.zip
* jws-httpd-3.0.3-RHEL.zip

... and edit the `group_vars/all-yml` file to set the `local_rh_bin_dir` to the folder containing your zip files. For example:

		local_rh_bin_dir: /opt/tools/jboss/bin

*4) (optional) Ansible Tower license*

If you wish to use Ansible Tower, you will need ...

* to obtain a valid [Ansible Tower license file](https://www.ansible.com/license)
* to save the license file as "./vagrant/tower/license"


## Setup

You have two options to provision your environment:

a) Without using Ansible Tower

	$ ./init.sh

b) Using Ansible Tower

	$ ./init.sh tower

In both cases, it will take a while to create all virtual machines and provision them.


## Ansible Tower

After having intialized the JBoss middleware Standard Operating Environment (using  `./init.sh tower`), you should follow these steps to provision the virtual machines.

Using the credentials displayed at the end of the installation, you will be able to log into Ansible Tower (https://192.168.0.200/) and there:

1. Import the current git repository as a project
    - name: ansible_middleware_soe
    - scm type: git
    - scm url: git@github.com:Maarc/ansible_middleware_soe.git
    - scm branch: master

2. Define a job template
    - name: Roll-out JBoss middleware
    - job-type: Run
    - inventory: Development virtual machines
    - project: ansible_middleware_soe
    - playbook: site.yml
    - machine credential: Vagrant virtual machines (ssh)
    - extra variables:  base_repo_dir: '/tmp/bin'

3. Run the defined job template


## Test

The deployed test applications can be accessed over the following URLs:

* Ticket-monster
  - host-dev-01 (load-balancer): http://192.168.0.101/ticket-monster/
  - host-dev-02 (JBoss EAP): http://192.168.0.102:8080/ticket-monster/
  - host-dev-03 (JBoss EAP) http://192.168.0.103:8080/ticket-monster/

* Petclinic
  - host-dev-01 (load-balancer): http://192.168.0.101/petclinic/
  - host-dev-02 (JBoss EAP): http://192.168.0.102:9080/petclinic/
  - host-dev-03 (JBoss EAP) http://192.168.0.103:9080/petclinic/

* Jenkins
  - host-dev-01 (load-balancer): http://192.168.0.101/jenkins/
  - host-dev-02 (JBoss EAP): http://192.168.0.102:10080/jenkins/
  - host-dev-03 (JBoss EAP) http://192.168.0.103:10080/jenkins/

* tomcat-sample
  - host-dev-01 (JWS): http://192.168.0.101:8000/tomcat-sample/


## Project structure

Here is a brief description of the structure of this projects:

* **files/cli** contains the CLI files used for configuring JBoss EAP.
* **group_vars** contains the ansible [group variables](https://docs.ansible.com/ansible/playbooks_variables.html).
* **inventory** contains the [ansible inventory](https://docs.ansible.com/ansible/intro_inventory.html). "hosts-dev" lists the host for the development environment. At the same level, you can add a "host-int" or "host-prod" file listing your orchestrated hosts in the integration or production staging environments.
* **roles** contains the main roles of this SOE implementations:
 - **roles/golden-image** creates Red Hat JBoss golden images.
 - **roles/java-demo-app** downloads and builds the demo Java applications.
 - **roles/Maarc.rh-jboss-common** is the core role for all managed hosts.
 - **roles/Maarc.rh-jboss-eap** is the basis role for JBoss EAP instances. The role is quite parametrizable, registers the instance as a service and supports multiple instances on a same host.
 - **roles/Maarc.rh-jboss-web-server-httpd** is a role installing a JWS apache (HTTPD) server.
 - **roles/Maarc.rh-jboss-web-server-tomcat** is a role installing a JWS Tomcat server.
* **vagrant/Vagrantfile** contains a description of you virtual machines managed by vagrant.



## Troubleshooting

If you encounter an error looking like ...

	 fatal: [host-dev-eap-01]: UNREACHABLE! => {"changed": false, "msg": "SSH encountered an unknown error during the connection. We recommend you re-run the command using -vvvv, which will enable SSH debugging output to help diagnose the issue", "unreachable": true}

... either your virtual machine is down and you need to start it:

    cd vagrant; vagrant up host-dev-01; cd ..

... or restart it ...

    cd vagrant; vagrant reload host-dev-01; cd ..

... or you need to cleanup your .ssh/known_hosts file. For example like that:

    mv -n ~/.ssh/known_hosts{,_$(date +%s).orig}
