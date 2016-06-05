Here is a short todo-list:

[priority 1]

* Add apache and cleanup httpd
  -> configure httpd+mod_cluster to work with the EAP instances

[priority 2]

* Update according to ... http://hakunin.com/six-ansible-practices#teach-ansible-to-talk-to-github-on-your-behalf

* Prepare an example over several environments (dev/int/prod) on different types of machines
  - different icons / images / colors for each environment (different properties files / static files / ...)

* Extend service scripts to add capabilities similar to ... (cf. Roeland)

  alias eap_{{ jboss_eap_instance_name }}_restart='rm -Rf {{ jboss_eap_instance_log_dir }}/*; sudo service {{ jboss_eap_instance_service_name }} restart'
  alias eap_{{ jboss_eap_instance_name }}_log='less {{ jboss_eap_instance_log_dir }}/server.log'
  alias eap_{{ jboss_eap_instance_name }}_ports='netstat -tulpn | grep java'

* Add monitoring and log centralization capabilities

* Integration with Ansible Tower -> Extend local play for the golden-images and so on ...
    -> Add native libraries (sabre1041.redhat-csp-download role) to downloads the EAP zips locally for Tower


[priority 3]

* Find other applications and cool use-cases over several application servers (cf. quick-start)

* Integration with Nexus (retrieving applications and application configuration as maven bundles)
  - Consider a standard format for generic applications to be transformed into ansible roles easily ...
  (this is nearly implemented ... but depends on the priority 1)

* Add switch capability for applications to override the application server configuration by overriding standalone.xml or using a CLI script

* Make sure that the "log" files are not deleted when a new version is installed ...

* cleanup task removing the JBoss instances that are no more supposed to be there (instance-inventory to be created ...)

* Integrate with the ansible variable vault (https://docs.ansible.com/ansible/playbooks_best_practices.html)

cf. for cleanup ... https://github.com/contiv/ansible/blob/master/roles/contiv_cluster/tasks/cleanup.yml
