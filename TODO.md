Here is a short todo-list:

[priority 1]

* Add apache and cleanup httpd
  -> configure httpd+mod_cluster to work with the EAP instances


* Graceful orchestration
  -> any change should imply a removal of the instance (the --check option of ansible is not an option. Better to have all files used for an instance checked and work with conditions)
  -> updates (application 1.0 -> 1.2) / (application server 6.4 -> 7.0) / ...
  -> make sure that only the application(s) listed in app_list are deployed (remove the others ...)


* Add capability to use CLI to configure an instance (e.g. add datasource for ticket-monster application)
  - should be done on a similar way than what has been done for the golden images
  - use ticket-monster as test application (datasource ExampleDS needs to be added)

* Update according to ... http://hakunin.com/six-ansible-practices#teach-ansible-to-talk-to-github-on-your-behalf


[priority 2]

* Add native libraries to downloads the EAP zips locally

* Harden all profiles (./build -> run for all standalone-*) (easy to do once the prio 1 are done)

* Prepare an example over several environments (dev/int/prod) on different types of machines
  - different icons / images / colors for each environment (different properties files / static files / ...)

* Extend service scripts to add capabilities similar to ... (cf. Roeland)

  alias eap_{{ jboss_eap_instance_name }}_restart='rm -Rf {{ jboss_eap_instance_log_dir }}/*; sudo service {{ jboss_eap_instance_service_name }} restart'
  alias eap_{{ jboss_eap_instance_name }}_log='less {{ jboss_eap_instance_log_dir }}/server.log'
  alias eap_{{ jboss_eap_instance_name }}_ports='netstat -tulpn | grep java'

* Add monitoring and log centralization capabilities

* Integration with Ansible Tower
  -> Extend local play for the golden-images and so on ...

* Integrate with the ansible variable vault (https://docs.ansible.com/ansible/playbooks_best_practices.html)



[priority 3]

* Find other applications and cool use-cases over several application servers (cf. quick-start)

* Integration with Nexus (retrieving applications and application configuration as maven bundles)
  - Use https://docs.ansible.com/ansible/maven_artifact_module.html to retrieve applications
  - Consider a standard format for generic applications to be transformed into ansible roles easily ...
  (this is nearly implemented ... but depends on the priority 1)


* Add switch capability for applications to override the application server configuration by overriding standalone.xml or using a CLI script
