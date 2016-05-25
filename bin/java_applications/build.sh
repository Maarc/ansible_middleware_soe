#!/bin/sh
# Inialize the repository

set -x

CURRENT=$(pwd)

# Download the spring petclinic application
curl -o ${CURRENT}/../../roles/rh_jboss_eap_pet-clinic/files/deployments/petclinic-2.3.0.war http://central.maven.org/maven2/com/webcohesion/enunciate/enunciate-examples-spring-petclinic/2.3.0/enunciate-examples-spring-petclinic-2.3.0.war

# Downloads an example of ojdbc6 driver
curl -o ${CURRENT}/../rh_jboss_golden_images/install/eap_modules/ojdbc_modules/system/layers/base/com/oracle/main/ojdbc6.jar http://maven.novamens.com/com/oracle/ojdbc6/11.2.0.4.0/ojdbc6-11.2.0.4.0.jar

# Download and build ticket-monster
git clone https://github.com/jboss-developer/ticket-monster.git
cd ticket-monster/demo
mvn clean package
cp target/ticket-monster.war ${CURRENT}/../../roles/rh_jboss_eap_ticket-monster/files/deployments
