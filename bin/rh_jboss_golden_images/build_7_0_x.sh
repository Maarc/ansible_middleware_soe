#!/bin/sh
#
# This script builds the company specific Red Hat JBoss EAP gold-master distribution.
#

if [ "$#" -ne 2 ]
then
  echo "Usage: $0 <LOG_FILE> <JBOSS_EAP_7_VERSION>"
  echo "Example: $0 build.log 7.0.1"
  exit 1
fi

readonly VERSION="jboss-eap-${2}"
readonly TARGET_EAP="${VERSION}_GI"
readonly DIR_IN_ZIP="jboss-eap-7.0"
readonly FILE_EAP_BASIS="jboss-eap-7.0.0.zip"
readonly DIR_CURRENT=`pwd`
readonly DIR_SOURCE="${DIR_CURRENT}/../rh_jboss_binaries"
readonly DIR_MODULES="${DIR_CURRENT}/eap_modules"
readonly FILE_SOURCE_EAP="${DIR_SOURCE}/${FILE_EAP_BASIS}"
readonly FILE_SOURCE_EAP_PATCH="${DIR_SOURCE}/${VERSION}-patch.zip"

readonly DIR_TARGET="${DIR_CURRENT}/target"
readonly FILE_LOG="${1}"
readonly SEPARATOR="==============================================================================================="
readonly DIR_TARGET_EAP="${DIR_TARGET}/${TARGET_EAP}"
readonly FILE_TARGET_EAP="${TARGET_EAP}.zip"
readonly FILE_CLI="${DIR_CURRENT}/build.cli"
readonly CMD_JBOSS_CLI="${DIR_TARGET_EAP}/bin/jboss-cli.sh"

declare COMMAND

export JBOSS_HOME="${DIR_TARGET_EAP}"

echo "\n[${VERSION}] Unpack JBoss EAP binaries (${FILE_EAP_BASIS}) \n${SEPARATOR}"

#set -x

COMMAND="rm -Rf ${DIR_TARGET}; mkdir -p ${DIR_TARGET}"
echo ${COMMAND}
eval ${COMMAND}

COMMAND="unzip ${FILE_SOURCE_EAP} -d ${DIR_TARGET} 2>> ${FILE_LOG} 1>> /dev/null"
echo ${COMMAND}
eval ${COMMAND}
COMMAND="mv ${DIR_TARGET}/${DIR_IN_ZIP} ${DIR_TARGET_EAP} 2>&1 >> ${FILE_LOG}"
echo ${COMMAND}
eval ${COMMAND}

echo "\n[${VERSION}] Patch to ${VERSION}\n${SEPARATOR}"

COMMAND="${CMD_JBOSS_CLI} --command=\"patch apply ${FILE_SOURCE_EAP_PATCH}\" 2>&1 >> ${FILE_LOG}"
echo ${COMMAND}
eval ${COMMAND}

echo "\n[${VERSION}] Apply customizations\n${SEPARATOR}"

echo '' > $FILE_CLI
CLIS=( "delete_ExampleDS_7.cli" "delete_mail_outbound.cli" "disable_deployment_scanner.cli" )
for CLI in "${CLIS[@]}"
do
  cat $DIR_CURRENT/cli/$CLI >> $FILE_CLI
done

cat $FILE_CLI >> ${FILE_LOG}

EAP_CONFIGURATIONS=( "standalone-full-ha.xml" )
for EAP_CONFIG in "${EAP_CONFIGURATIONS[@]}"
do
  COMMAND="bash -c \"nohup ${JBOSS_HOME}/bin/standalone.sh -c ${EAP_CONFIG} --admin-only 2>>${FILE_LOG} 1>>${FILE_LOG} &\" && sleep 10 && ${CMD_JBOSS_CLI} -c --file=${FILE_CLI} 2>&1 >> ${FILE_LOG} && pkill -TERM -f \"(.*)standalone(.*)admin-only\""
  echo ${COMMAND}
  eval ${COMMAND}
done

CLIS=( "delete_console_logger.cli" )
for CLI in "${CLIS[@]}"
do
  cat $DIR_CURRENT/cli/$CLI >> $FILE_CLI
done

cat $FILE_CLI >> ${FILE_LOG}

EAP_CONFIGURATIONS=( "standalone.xml" "standalone-full.xml" "standalone-ha.xml" )
for EAP_CONFIG in "${EAP_CONFIGURATIONS[@]}"
do
  COMMAND="bash -c \"nohup ${JBOSS_HOME}/bin/standalone.sh -c ${EAP_CONFIG} --admin-only 2>>${FILE_LOG} 1>>${FILE_LOG} &\" && sleep 10 && ${CMD_JBOSS_CLI} -c --file=${FILE_CLI} 2>&1 >> ${FILE_LOG} && pkill -TERM -f \"(.*)standalone(.*)admin-only\""
  echo ${COMMAND}
  eval ${COMMAND}
done

rm $FILE_CLI

COMMAND="cp -Rfp ${DIR_MODULES}/ojdbc_modules/* ${JBOSS_HOME}/modules/. 2>&1 >> ${FILE_LOG}"
echo ${COMMAND}
eval ${COMMAND}

# Renaming for staying consistent with EAP 6.x
COMMAND="mv ${DIR_TARGET_EAP}/bin/init.d/jboss-eap-rhel.sh ${DIR_TARGET_EAP}/bin/init.d/jboss-as-standalone.sh 2>&1 >> ${FILE_LOG}"
echo ${COMMAND}
eval ${COMMAND}

# Renaming for staying consistent with EAP 6.x
COMMAND="sed -i.bak s/jboss.management.http.port/'jboss.management.native.port'/g ${DIR_TARGET_EAP}/standalone/configuration/standalone*.xml"
echo ${COMMAND}
eval ${COMMAND}

COMMAND="rm -f ${DIR_TARGET_EAP}/standalone/configuration/*.bak 2>&1 >> ${FILE_LOG}"
echo ${COMMAND}
eval ${COMMAND}

echo "\n[${VERSION}] Package and cleanup\n${SEPARATOR}"

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
COMMAND="cd ${DIR_TARGET}; zip -r ${FILE_TARGET_EAP} ${TARGET_EAP} 2>> ${FILE_LOG} 1>> /dev/null; mv ${FILE_TARGET_EAP} ${DIR_CURRENT}/builds 2>&1 >> ${FILE_LOG}"
echo ${COMMAND}
eval ${COMMAND}

# Cleanup the target directory
COMMAND="cd ${DIR_CURRENT}; rm -Rf ${DIR_TARGET} 2>&1 >> ${FILE_LOG}"
echo ${COMMAND}
eval ${COMMAND}
