#!/bin/sh
#
# This script builds the company specific Red Hat JBoss EAP gold-master distribution.
#

# Todo - now working so far ... needs to be fixed

readonly PATCH_VERSION="jboss-eap-7.0.0"

readonly TARGET_EAP="jboss-eap"
readonly DIR_IN_ZIP="jboss-eap-7.0"

readonly DIR_CURRENT=`pwd`
readonly DIR_SOURCE="${DIR_CURRENT}/../rh_jboss_binaries"
readonly DIR_MODULES="${DIR_CURRENT}/eap_modules"
readonly FILE_SOURCE_EAP="${DIR_SOURCE}/jboss-eap-7.0.0.zip"

readonly DIR_TARGET="${DIR_CURRENT}/target"
readonly FILE_LOG="${DIR_CURRENT}/build.log"
readonly SEPARATOR="==============================================================================================="
readonly DIR_TARGET_EAP="${DIR_TARGET}/${TARGET_EAP}"
readonly FILE_TARGET_EAP="${PATCH_VERSION}_golden_image.zip"
readonly FILE_CLI="${DIR_CURRENT}/${PATCH_VERSION}_golden_image.cli"
readonly CMD_JBOSS_CLI="${DIR_TARGET_EAP}/bin/jboss-cli.sh"

declare COMMAND

export JBOSS_HOME="${DIR_TARGET_EAP}"

echo "\nUnpacking JBoss EAP binaries\n${SEPARATOR}"

set -x

rm -Rf ${DIR_TARGET}; mkdir -p ${DIR_TARGET}
unzip ${FILE_SOURCE_EAP} -d ${DIR_TARGET} 2>&1 > ${FILE_LOG}
mv ${DIR_TARGET}/${DIR_IN_ZIP} ${DIR_TARGET_EAP} >> ${FILE_LOG}

echo "\nCustomizing\n${SEPARATOR}"

# Iteration on a "CLI" directory is optional / A separate profile might have to be chosen
#COMMAND="bash -c \"nohup ${JBOSS_HOME}/bin/standalone.sh -P /tmp/app.props --admin-only 2>/dev/null 1>/dev/null &\" && sleep 10 && ${CMD_JBOSS_CLI} -c --file=${FILE_CLI} && killall java"
bash -c "nohup ${JBOSS_HOME}/bin/standalone.sh -c standalone-full.xml --admin-only 2>>${FILE_LOG} 1>>${FILE_LOG} &" && sleep 10 && ${CMD_JBOSS_CLI} -c --file=${FILE_CLI} 2>&1 >> ${FILE_LOG} && killall java
bash -c "nohup ${JBOSS_HOME}/bin/standalone.sh -c standalone.xml --admin-only 2>>${FILE_LOG} 1>>${FILE_LOG} &" && sleep 10 && ${CMD_JBOSS_CLI} -c --file=${FILE_CLI} 2>&1 >> ${FILE_LOG} && killall java
cp -Rfp ${DIR_MODULES}/ojdbc_modules/* ${JBOSS_HOME}/modules/.

echo "\nPackaging and cleanup\n${SEPARATOR}"

# Domain mode excluded
rm -Rf ${DIR_TARGET_EAP}/domain 2>&1 >> ${FILE_LOG}
# Generated file
rm -Rf ${DIR_TARGET_EAP}/standalone/configuration/logging.properties 2>&1 >> ${FILE_LOG}
# Folder cleanup
rm -Rf ${DIR_TARGET_EAP}/standalone/log/* ${DIR_TARGET_EAP}/standalone/data/* ${DIR_TARGET_EAP}/standalone/deployments/*  ${DIR_TARGET_EAP}/standalone/configuration/standalone_xml_history
# Packing the EAP golden image
cd ${DIR_TARGET}; zip -r ${FILE_TARGET_EAP} ${TARGET_EAP} 2>&1 >> ${FILE_LOG}; mv ${FILE_TARGET_EAP} ${DIR_CURRENT}/builds

cd ${DIR_CURRENT}
rm -Rf ${DIR_TARGET}
