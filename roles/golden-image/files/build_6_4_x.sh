#!/bin/sh
#
# This script builds the company specific Red Hat JBoss EAP gold-master distribution for EAP 6.4.x
#

if [ "$#" -ne 5 ]
then
  echo "Usage: $0 <LOG_FILE> <JBOSS_EAP_6_VERSION> <DIR_SOURCE> <DIR_TARGET> <DIR_CONF>"
  echo "Example: $0 build.log 6.4.9 /tmp/mw_repo/rh_jboss_binaries /tmp/mw_repo/conf /tmp/mw_repo/rh_jboss_golden_images"
  exit 1
fi

readonly VERSION="jboss-eap-${2}"
readonly TARGET_EAP="${VERSION}_GI"
readonly DIR_IN_ZIP="jboss-eap-6.4"
readonly FILE_EAP_BASIS="jboss-eap-6.4.0.zip"
readonly DIR_CONF="$5"
readonly DIR_SOURCE="${3}"
readonly DIR_MODULES="${DIR_CONF}/eap_custom_modules"
readonly FILE_SOURCE_EAP="${DIR_SOURCE}/${FILE_EAP_BASIS}"
readonly FILE_SOURCE_EAP_PATCH="${DIR_SOURCE}/${VERSION}-patch.zip"
readonly FILE_SOURCE_EAP_NATIVE="${DIR_SOURCE}/jboss-eap-native-6.4.0-RHEL7-x86_64.zip"

readonly DIR_TARGET="${4}/target"
readonly FILE_LOG="${1}"
readonly SEPARATOR="==============================================================================================="
readonly DIR_TARGET_EAP="${DIR_TARGET}/${TARGET_EAP}"
readonly FILE_TARGET_EAP="${TARGET_EAP}.zip"
readonly FILE_CLI="${DIR_TARGET}/build.cli"
readonly CMD_JBOSS_CLI="${DIR_TARGET_EAP}/bin/jboss-cli.sh"

echo "$SEPARATOR\n  Building ${VERSION} GI \n$SEPARATOR\n"

echo "DIR_CONF: $DIR_CONF" >> ${FILE_LOG}
echo "FILE_CLI: $FILE_CLI" >> ${FILE_LOG}
echo "DIR_MODULES: $DIR_MODULES" >> ${FILE_LOG}

declare COMMAND

export JBOSS_HOME="${DIR_TARGET_EAP}"

echo "\n[${VERSION}] Unpack JBoss EAP binaries (${FILE_EAP_BASIS}) \n${SEPARATOR}"

#set -x

COMMAND="rm -Rf ${DIR_TARGET}; mkdir -p ${DIR_TARGET}"
echo ${COMMAND} >> ${FILE_LOG}
eval ${COMMAND}

COMMAND="unzip ${FILE_SOURCE_EAP} -d ${DIR_TARGET} 2>> ${FILE_LOG} 1>> /dev/null"
echo ${COMMAND} >> ${FILE_LOG}
eval ${COMMAND}

COMMAND="mv ${DIR_TARGET}/${DIR_IN_ZIP} ${DIR_TARGET_EAP} 2>&1 >> ${FILE_LOG}"
echo ${COMMAND} >> ${FILE_LOG}
eval ${COMMAND}

echo "\n[${VERSION}] Patch to ${VERSION}\n${SEPARATOR}"
COMMAND="${CMD_JBOSS_CLI} --command=\"patch apply ${FILE_SOURCE_EAP_PATCH}\" 2>&1 >> ${FILE_LOG}"
echo ${COMMAND} >> ${FILE_LOG}
eval ${COMMAND}

COMMAND="unzip ${FILE_SOURCE_EAP_NATIVE} -d ${DIR_TARGET} 2>> ${FILE_LOG} 1>> /dev/null"
echo ${COMMAND} >> ${FILE_LOG}
eval ${COMMAND}

echo "\n[${VERSION}] Apply customizations\n${SEPARATOR}"

echo '' > ${FILE_CLI}
CLIS=( "delete_ExampleDS_6.cli" "delete_mail_outbound.cli" "enable_native_lib_6.cli" "disable_deployment_scanner.cli" "update_web_subsystem_6.cli")
for CLI in "${CLIS[@]}"
do
    cat ${DIR_CONF}/cli/$CLI >> ${FILE_CLI}
    echo "----->>>  ${DIR_CONF}/cli/$CLI" >> ${FILE_LOG}
done

echo ">>>>> Executed CLI " >> ${FILE_LOG}
cat ${FILE_CLI} >> ${FILE_LOG}
echo "<<<<< Executed CLI " >> ${FILE_LOG}

EAP_CONFIGURATIONS=( "standalone-full-ha.xml" )
for EAP_CONFIG in "${EAP_CONFIGURATIONS[@]}"
do
  COMMAND="bash -c \"nohup ${JBOSS_HOME}/bin/standalone.sh -c ${EAP_CONFIG} --admin-only 2>>${FILE_LOG} 1>>${FILE_LOG} &\" && sleep 10 && ${CMD_JBOSS_CLI} -c --file=${FILE_CLI} 2>&1 >> ${FILE_LOG} && pkill -TERM -f \"(.*)standalone(.*)admin-only\""
  echo ${COMMAND} >> ${FILE_LOG}
  eval ${COMMAND}
done

CLIS=( "delete_console_logger.cli" )
for CLI in "${CLIS[@]}"
do
    cat ${DIR_CONF}/cli/$CLI >> ${FILE_CLI}
    echo "----->>>  ${DIR_CONF}/cli/$CLI" >> ${FILE_LOG}
done

echo ">>>>> Executed CLI " >> ${FILE_LOG}
cat ${FILE_CLI} >> ${FILE_LOG}
echo "<<<<< Executed CLI " >> ${FILE_LOG}

EAP_CONFIGURATIONS=( "standalone.xml" "standalone-full.xml" "standalone-ha.xml" )
for EAP_CONFIG in "${EAP_CONFIGURATIONS[@]}"
do
  COMMAND="bash -c \"nohup ${JBOSS_HOME}/bin/standalone.sh -c ${EAP_CONFIG} --admin-only 2>>${FILE_LOG} 1>>${FILE_LOG} &\" && sleep 10 && ${CMD_JBOSS_CLI} -c --file=${FILE_CLI} 2>&1 >> ${FILE_LOG} && pkill -TERM -f \"(.*)standalone(.*)admin-only\""
  echo ${COMMAND} >> ${FILE_LOG}
  eval ${COMMAND}
done

rm ${FILE_CLI}

COMMAND="cp -Rfp ${DIR_MODULES}/ojdbc_modules/* ${JBOSS_HOME}/modules/. 2>&1 >> ${FILE_LOG}"
echo ${COMMAND} >> ${FILE_LOG}
eval ${COMMAND}

echo "\n[${VERSION}] Package and cleanup\n${SEPARATOR}"

# Domain mode excluded
COMMAND="rm -Rf ${DIR_TARGET_EAP}/domain 2>&1 >> ${FILE_LOG}"
echo ${COMMAND} >> ${FILE_LOG}
eval ${COMMAND}

# Generated file
COMMAND="rm -Rf ${DIR_TARGET_EAP}/standalone/configuration/logging.properties 2>&1 >> ${FILE_LOG}"
echo ${COMMAND} >> ${FILE_LOG}
eval ${COMMAND}

# Folder cleanup
COMMAND="rm -Rf ${DIR_TARGET_EAP}/standalone/log/* ${DIR_TARGET_EAP}/standalone/data/* ${DIR_TARGET_EAP}/standalone/deployments/*  ${DIR_TARGET_EAP}/standalone/configuration/standalone_xml_history"
echo ${COMMAND} >> ${FILE_LOG}
eval ${COMMAND}

# Packing the EAP golden image
COMMAND="cd ${DIR_TARGET}; zip -r ${FILE_TARGET_EAP} ${TARGET_EAP} 2>> ${FILE_LOG} 1>> /dev/null; mv ${FILE_TARGET_EAP} ${4} 2>&1 >> ${FILE_LOG}"
echo ${COMMAND} >> ${FILE_LOG}
eval ${COMMAND}

# Cleanup the target directory
COMMAND="rm -Rf ${DIR_TARGET} 2>&1 >> ${FILE_LOG}"
echo ${COMMAND} >> ${FILE_LOG}
eval ${COMMAND}
