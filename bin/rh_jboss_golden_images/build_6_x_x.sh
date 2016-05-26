#!/bin/sh
#
# This script builds the company specific Red Hat JBoss EAP gold-master distribution.
#

#set -x

if [ "$#" -ne 1 ]
then
  echo "Usage: $0 <JBOSS_EAP_6_VERSION>"
  echo "Example: $0 6.4.8"
  exit 1
fi

readonly PATCH_VERSION="jboss-eap-${1}"

readonly TARGET_EAP="${PATCH_VERSION}_GI"
readonly DIR_IN_ZIP="jboss-eap-6.4"
readonly FILE_EAP_BASIS="jboss-eap-6.4.0.zip"

readonly DIR_CURRENT=`pwd`
readonly DIR_SOURCE="${DIR_CURRENT}/../rh_jboss_binaries"
readonly DIR_MODULES="${DIR_CURRENT}/eap_modules"
readonly FILE_SOURCE_EAP="${DIR_SOURCE}/${FILE_EAP_BASIS}"
readonly FILE_SOURCE_EAP_PATCH="${DIR_SOURCE}/${PATCH_VERSION}-patch.zip"
readonly FILE_SOURCE_EAP_NATIVE="${DIR_SOURCE}/jboss-eap-native-6.4.0-RHEL6-x86_64.zip"

readonly DIR_TARGET="${DIR_CURRENT}/target"
readonly FILE_LOG="${DIR_CURRENT}/build.log"
readonly SEPARATOR="==============================================================================================="
readonly DIR_TARGET_EAP="${DIR_TARGET}/${TARGET_EAP}"
readonly FILE_TARGET_EAP="${TARGET_EAP}.zip"
readonly FILE_CLI="${DIR_CURRENT}/${PATCH_VERSION}_golden_image.cli"
readonly CMD_JBOSS_CLI="${DIR_TARGET_EAP}/bin/jboss-cli.sh"

declare COMMAND

export JBOSS_HOME="${DIR_TARGET_EAP}"

echo "\n[${PATCH_VERSION}] Unpack JBoss EAP binaries (${FILE_EAP_BASIS}) \n${SEPARATOR}"

COMMAND="rm -Rf ${DIR_TARGET}; mkdir -p ${DIR_TARGET}"
echo ${COMMAND}
eval ${COMMAND}


COMMAND="unzip ${FILE_SOURCE_EAP} -d ${DIR_TARGET} 2>&1 > ${FILE_LOG}"
echo ${COMMAND}
eval ${COMMAND}

COMMAND="unzip ${FILE_SOURCE_EAP_NATIVE} -d ${DIR_TARGET} 2>&1 > ${FILE_LOG}"
echo ${COMMAND}
eval ${COMMAND}

COMMAND="mv ${DIR_TARGET}/${DIR_IN_ZIP} ${DIR_TARGET_EAP} >> ${FILE_LOG}"
echo ${COMMAND}
eval ${COMMAND}

echo "\n[${PATCH_VERSION}] Patch to ${PATCH_VERSION}\n${SEPARATOR}"

COMMAND="${CMD_JBOSS_CLI} --command=\"patch apply ${FILE_SOURCE_EAP_PATCH}\" 2>&1 >> ${FILE_LOG}"
echo ${COMMAND}
eval ${COMMAND}

echo "\n[${PATCH_VERSION}] Apply customizations\n${SEPARATOR}"

# Iteration on a "CLI" directory is optional / A separate profile might have to be chosen
EAP_CONFIG="standalone-full.xml"
COMMAND="bash -c \"nohup ${JBOSS_HOME}/bin/standalone.sh -c ${EAP_CONFIG} --admin-only 2>>${FILE_LOG} 1>>${FILE_LOG} &\" && sleep 10 && ${CMD_JBOSS_CLI} -c --file=${FILE_CLI} 2>&1 >> ${FILE_LOG}"
echo ${COMMAND}
eval ${COMMAND}

COMMAND="killall java"
echo ${COMMAND}
eval ${COMMAND}

EAP_CONFIG="standalone-full.xml"
COMMAND="bash -c \"nohup ${JBOSS_HOME}/bin/standalone.sh -c ${EAP_CONFIG} --admin-only 2>>${FILE_LOG} 1>>${FILE_LOG} &\" && sleep 10 && ${CMD_JBOSS_CLI} -c --file=${FILE_CLI} 2>&1 >> ${FILE_LOG}"
echo ${COMMAND}
eval ${COMMAND}

COMMAND="killall java"
echo ${COMMAND}
eval ${COMMAND}

COMMAND="cp -Rfp ${DIR_MODULES}/ojdbc_modules/* ${JBOSS_HOME}/modules/. 2>&1 >> ${FILE_LOG}"
echo ${COMMAND}
eval ${COMMAND}

echo "\n[${PATCH_VERSION}] Package and cleanup\n${SEPARATOR}"

# Domain mode excluded
COMMAND="rm -Rf ${DIR_TARGET_EAP}/domain 2>&1 >> ${FILE_LOG}"
echo ${COMMAND}
eval ${COMMAND}

# Generated file
COMMAND="rm -Rf ${DIR_TARGET_EAP}/standalone/configuration/logging.properties 2>&1 >> ${FILE_LOG}"
echo ${COMMAND}
eval ${COMMAND}

# Folder cleanup
COMMAND="rm -Rf ${DIR_TARGET_EAP}/standalone/log/* ${DIR_TARGET_EAP}/standalone/data/* ${DIR_TARGET_EAP}/standalone/deployments/*  ${DIR_TARGET_EAP}/standalone/configuration/standalone_xml_history"
echo ${COMMAND}
eval ${COMMAND}

# Packing the EAP golden image
COMMAND="cd ${DIR_TARGET}; zip -r ${FILE_TARGET_EAP} ${TARGET_EAP} 2>&1 >> ${FILE_LOG}; mv ${FILE_TARGET_EAP} ${DIR_CURRENT}/builds 2>&1 >> ${FILE_LOG}"
echo ${COMMAND}
eval ${COMMAND}

# Cleanup the target directory
COMMAND="cd ${DIR_CURRENT}; rm -Rf ${DIR_TARGET} 2>&1 >> ${FILE_LOG}"
echo ${COMMAND}
eval ${COMMAND}
