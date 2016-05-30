Here is a short todo-list:

* Add capability to use CLI to configure an instance (e.g. add datasource for ticket-monster application)
  - should be done on a similar way than what has been done for the golden images
  - use ticket-monster as test application (datasource ExampleDS needs to be added)

* Harden all profiles (./build -> run for all standalone-*)

* Add switch capability for applications to override the application server configuration by overriding standalone.xml or using a CLI script

* Orchestrate a graceful update (application 1.0 -> 1.2) / (application server 6.4 -> 7.0) / ...

* Add rh_jboss_web_server ... and a web application

* Prepare an example over several environments (dev/int/prod) on different types of machines
  - different icons / images / colors for each environment (different properties files / static files / ...)

* Find other applications and cool use-cases over several application servers (cf. quick-start)

* Extend service scripts to add capabilities similar to ... (cf. Roeland)

  alias eap_{{ jboss_eap_instance_name }}_restart='rm -Rf {{ jboss_eap_instance_log_dir }}/*; sudo service {{ jboss_eap_instance_service_name }} restart'
  alias eap_{{ jboss_eap_instance_name }}_log='less {{ jboss_eap_instance_log_dir }}/server.log'
  alias eap_{{ jboss_eap_instance_name }}_ports='netstat -tulpn | grep java'

* Add monitoring and log centralization capabilities

* Integration with Nexus (retrieving applications and application configuration as maven bundles)
  - Use https://docs.ansible.com/ansible/maven_artifact_module.html to retrieve applications
  - Consider a standard format for generic applications to be transformed into ansible roles easily ...

* Integration with Ansible Tower

* Integrate with the ansible variable vault (https://docs.ansible.com/ansible/playbooks_best_practices.html)
