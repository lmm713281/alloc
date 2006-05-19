#!/bin/sh
#
#  Copyright 2006, Alex Lance, Clancy Malcolm, Cybersource Pty. Ltd.
#  
#  This file is part of allocPSA <info@cyber.com.au>.
#  
#  allocPSA is free software; you can redistribute it and/or modify it under the
#  terms of the GNU General Public License as published by the Free Software
#  Foundation; either version 2 of the License, or (at your option) any later
#  version.
#  
#  allocPSA is distributed in the hope that it will be useful, but WITHOUT ANY
#  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
#  A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License along with
#  allocPSA; if not, write to the Free Software Foundation, Inc., 51 Franklin
#  St, Fifth Floor, Boston, MA 02110-1301 USA
# 
#
#  Script to setup database, website permissions, cronjobs and generate alloc.inc
#



# Directory of this file
DIR="${0%/*}/"

# Source functions
. ${DIR}functions.sh


e "Beginning allocPSA Installation\n"

USAGE="Usage: ${0} [-B] FILE\n\n\t-B\tbatch mode, no prompting\n\tFILE\tconfiguration file\n"

if [ "0" != "$(id -u)" ]; then
  die "Please run this script as user root."
fi

if [ -f "${1}" ]; then
  CONFIG_FILE="${1}"
elif [ -f "${2}" ]; then
  CONFIG_FILE="${2}"
fi

# If -B is passed on the command line, skip the prompts and just install
if [ "${1}" = "-B" ] || [ "${2}" = "-B" ]; then
  DO_BATCH=1
fi

# Source the config file
[ ! -r "${CONFIG_FILE}" ] && die "${USAGE}"
. ${CONFIG_FILE}

# A list of all the variable set in this file, as a form of checking the install.cfg file
CONFIG_VARS="ALLOC_DB_NAME ALLOC_DB_USER ALLOC_DB_PASS ALLOC_DB_HOST ALLOC_WEB_USER \
             ALLOC_DOCS_DIR ALLOC_BACKUP_DIR ALLOC_LOG_DIR ALLOC_PATCH_DIR ALLOC_WEB_URL_PREFIX"

# Get config vars
while [ "${DO_INSTALL:0:1}" != "y" ]; do
  DO_INSTALL=""

  # Quick check all the values are in the config file
  for i in ${CONFIG_VARS}; do 
    get_user_var "${i}" "Please enter ${i}" "${!i}"; done

  # Print out config values
  for i in ${CONFIG_VARS}; do echo "  ${i}: ${!i}"; done

  # Determine whether to continue
  get_user_var "DO_INSTALL" "Does the config look correct to you?" "yes"

done

# Determine whether to install the db 
get_user_var DO_DB "Install the database?" "yes"

# Install the db
if [ "${DO_DB:0:1}" = "y" ]; then

  get_user_var DB_PASS "Enter the MySQL root password" "" "1"
  echo ""

  [ -n "${DB_PASS}" ] && DB_PASS=" -p${DB_PASS} "
 
  # MySQL administrative tables 
  mysql -v -u root ${DB_PASS} mysql <<EOMYSQL
  DROP DATABASE IF EXISTS ${ALLOC_DB_NAME};
  CREATE DATABASE ${ALLOC_DB_NAME};
  DELETE FROM user WHERE User = "${ALLOC_DB_USER}";
  DELETE FROM db WHERE User = "${ALLOC_DB_USER}";
  INSERT INTO user (Host, User, Password) values ("${ALLOC_DB_HOST}","${ALLOC_DB_USER}",PASSWORD("${ALLOC_DB_PASS}"));
  INSERT INTO db (Host, Db, User, Select_priv, Insert_priv, Update_priv, Delete_priv) values ("${ALLOC_DB_HOST}","${ALLOC_DB_NAME}", "${ALLOC_DB_USER}","y","y","y","y");
  FLUSH PRIVILEGES;
EOMYSQL
  [ "${?}" -ne "0" ] && fucked=1
  mysql -u root ${DB_PASS} ${ALLOC_DB_NAME} < ${DIR}db_structure.sql
  [ "${?}" -ne "0" ] && fucked=1
  mysql -u root ${DB_PASS} ${ALLOC_DB_NAME} < ${DIR}db_data.sql
  [ "${?}" -ne "0" ] && fucked=1

  if [ "${fucked}" = 1 ]; then
    e_failed "There was a problem installing the database".
  else
    e_ok "Installed the database.".
  fi
fi


# Append a slash if need be
[ "${ALLOC_DOCS_DIR:(-1):1}" != "/" ] && ALLOC_DOCS_DIR=${ALLOC_DOCS_DIR}/; 
[ "${ALLOC_BACKUP_DIR:(-1):1}" != "/" ] && ALLOC_BACKUP_DIR=${ALLOC_BACKUP_DIR}/; 
[ "${ALLOC_LOG_DIR:(-1):1}" != "/" ] && ALLOC_LOG_DIR=${ALLOC_LOG_DIR}/; 
[ "${ALLOC_PATCH_DIR:(-1):1}" != "/" ] && ALLOC_PATCH_DIR=${ALLOC_PATCH_DIR}/; 

# Create the directories if need be
[ ! -d "${ALLOC_BACKUP_DIR}" ]       && run "mkdir -p ${ALLOC_BACKUP_DIR}"
[ ! -d "${ALLOC_LOG_DIR}" ]          && run "mkdir -p ${ALLOC_LOG_DIR}"
[ ! -d "${ALLOC_PATCH_DIR}" ]        && run "mkdir -p ${ALLOC_PATCH_DIR}"
[ ! -d "${ALLOC_DOCS_DIR}" ]         && run "mkdir -p ${ALLOC_DOCS_DIR}"
[ ! -d "${ALLOC_DOCS_DIR}clients" ]  && run "mkdir ${ALLOC_DOCS_DIR}clients"
[ ! -d "${ALLOC_DOCS_DIR}projects" ] && run "mkdir ${ALLOC_DOCS_DIR}projects"

# Fix group and perms
run "chgrp ${ALLOC_WEB_USER} ${ALLOC_DOCS_DIR}"
run "chgrp ${ALLOC_WEB_USER} ${ALLOC_DOCS_DIR}clients"
run "chgrp ${ALLOC_WEB_USER} ${ALLOC_DOCS_DIR}projects"
run "chgrp ${ALLOC_WEB_USER} ${ALLOC_LOG_DIR}"
run "chmod 775 ${ALLOC_BACKUP_DIR}"
run "chmod 775 ${ALLOC_DOCS_DIR}"
run "chmod 775 ${ALLOC_DOCS_DIR}clients"
run "chmod 775 ${ALLOC_DOCS_DIR}projects"
run "chmod 775 ${ALLOC_LOG_DIR}"
[ ! -f "${ALLOC_LOG_DIR}alloc_email.log" ] && run "touch ${ALLOC_LOG_DIR}alloc_email.log"
run "chgrp ${ALLOC_WEB_USER} ${ALLOC_LOG_DIR}alloc_email.log"
run "chmod 775 ${ALLOC_LOG_DIR}alloc_email.log"

find ${DIR}.. -type f -path ${DIR}../.bzr -prune -exec chmod 664 {} \; # Files to rw-rw-r--
find ${DIR}.. -type d -path ${DIR}../.bzr -prune -exec chmod 775 {} \; # Dirs  to rwxrwxr-x

run "chmod 777 ${DIR}../images/"                          # php created images
run "chmod 777 ${DIR}../images/*"                         # php created images
run "chmod 777 ${DIR}../stylesheets/*"                    # rwxrwxrwx
run "chmod 755 ${DIR}dump_clean_db.sh"                    # rwxr-xr-x
run "chmod 754 ${DIR}stylesheet_regen.py"                 # rwxr-xr--
run "chmod 754 ${DIR}gpl_header.py"                       # rwxr-xr--
run "chmod 600 ${CONFIG_FILE}"                            # rw-------
run "chmod 700 ${DIR}install.sh"                          # rwx------

run "chmod 600 ${DIR}patch.sh"                            # rwxr-xr--
run "chown root ${DIR}patch.sh"                           # chown root


# Make the alloc.inc file
e "Creating alloc.inc"
cat ${DIR}templates/alloc.inc.tpl \
| sed -e "s/CONFIG_VAR_ALLOC_DB_NAME/${ALLOC_DB_NAME}/" \
| sed -e "s/CONFIG_VAR_ALLOC_DB_USER/${ALLOC_DB_USER}/" \
| sed -e "s/CONFIG_VAR_ALLOC_DB_PASS/${ALLOC_DB_PASS}/" \
| sed -e "s/CONFIG_VAR_ALLOC_DB_HOST/${ALLOC_DB_HOST}/" \
| sed -e "s/CONFIG_VAR_ALLOC_DOCS_DIR/${ALLOC_DOCS_DIR//\//\/}/" \
| sed -e "s/CONFIG_VAR_ALLOC_LOG_DIR/${ALLOC_LOG_DIR//\//\/}/" \
> ${DIR}alloc.inc

if [ -f "${DIR}alloc.inc" ]; then 
  e_ok "Created alloc.inc"
  run "chmod 640 ${DIR}alloc.inc"                           
  run "chgrp ${ALLOC_WEB_USER} ${DIR}alloc.inc"             
else 
  e_failed "Could not create alloc.inc"; 
fi

e "Creating alloc_DB_backup.sh"
cat ${DIR}templates/alloc_DB_backup.sh.tpl \
| sed -e "s/CONFIG_VAR_ALLOC_DB_NAME/${ALLOC_DB_NAME}/" \
| sed -e "s/CONFIG_VAR_ALLOC_DB_USER/${ALLOC_DB_USER}/" \
| sed -e "s/CONFIG_VAR_ALLOC_DB_PASS/${ALLOC_DB_PASS}/" \
| sed -e "s/CONFIG_VAR_ALLOC_DB_HOST/${ALLOC_DB_HOST}/" \
| sed -e "s/CONFIG_VAR_ALLOC_DOCS_DIR/${ALLOC_DOCS_DIR//\//\/}/" \
| sed -e "s/CONFIG_VAR_ALLOC_BACKUP_DIR/${ALLOC_BACKUP_DIR//\//\/}/" \
> ${DIR}alloc_DB_backup.sh

if [ -f "${DIR}alloc_DB_backup.sh" ]; then 
  e_ok "Created alloc_DB_backup.sh"
  run "chmod 755 ${DIR}alloc_DB_backup.sh"            
  run "mv ${DIR}alloc_DB_backup.sh ${ALLOC_BACKUP_DIR}"
else 
  e_failed "Could not create alloc_DB_backup.sh"; 
fi

# Append a slash if need be
[ "${ALLOC_WEB_URL_PREFIX:(-1):1}" != "/" ] && ALLOC_WEB_URL_PREFIX="${ALLOC_WEB_URL_PREFIX}/"


e "Creating cron_checkRepeatExpenses.sh"
cat ${DIR}templates/cron_checkRepeatExpenses.sh.tpl \
| sed -e "s/CONFIG_VAR_ALLOC_WEB_URL_PREFIX/${ALLOC_WEB_URL_PREFIX//\//\/}/" \
| sed -e "s/CONFIG_VAR_ALLOC_LOG_DIR/${ALLOC_LOG_DIR//\//\/}/" \
> ${DIR}cron_checkRepeatExpenses.sh

if [ -f "${DIR}cron_checkRepeatExpenses.sh" ]; then 
  e_ok "Created cron_checkRepeatExpenses.sh"
  run "chmod 755 ${DIR}cron_checkRepeatExpenses.sh"     
else 
  e_failed "Could not create cron_checkRepeatExpenses.sh"; 
fi


e "Creating cron_sendEmail.sh"
cat ${DIR}templates/cron_sendEmail.sh.tpl \
| sed -e "s/CONFIG_VAR_ALLOC_WEB_URL_PREFIX/${ALLOC_WEB_URL_PREFIX//\//\/}/" \
| sed -e "s/CONFIG_VAR_ALLOC_LOG_DIR/${ALLOC_LOG_DIR//\//\/}/" \
> ${DIR}cron_sendEmail.sh

if [ -f "${DIR}cron_sendEmail.sh" ]; then 
  e_ok "Created cron_sendEmail.sh"
  run "chmod 755 ${DIR}cron_sendEmail.sh"     
else 
  e_failed "Could not create cron_sendEmail.sh"; 
fi


e "Creating cron_sendReminders.sh"
cat ${DIR}templates/cron_sendReminders.sh.tpl \
| sed -e "s/CONFIG_VAR_ALLOC_WEB_URL_PREFIX/${ALLOC_WEB_URL_PREFIX//\//\/}/" \
| sed -e "s/CONFIG_VAR_ALLOC_LOG_DIR/${ALLOC_LOG_DIR//\//\/}/" \
> ${DIR}cron_sendReminders.sh

if [ -f "${DIR}cron_sendReminders.sh" ]; then 
  e_ok "Created cron_sendReminders.sh"
  run "chmod 755 ${DIR}cron_sendReminders.sh"     
else 
  e_failed "Could not create cron_sendReminders.sh"; 
fi







if [ -z "${FAILED}" ]; then
  
  f="$(basename ${CONFIG_FILE})"
  if [ ! -f "${ALLOC_BACKUP_DIR}${f}" ] || ([ -f "${ALLOC_BACKUP_DIR}${f}" ] && [ -n "$(diff ${CONFIG_FILE} ${ALLOC_BACKUP_DIR}${f})" ]); then

    get_user_var MOVE_FILE "Move ${CONFIG_FILE} to ${ALLOC_BACKUP_DIR}?" "yes"

    if [ "${MOVE_FILE:0:1}" = "y" ]; then
      [ -f "${ALLOC_BACKUP_DIR}${f}" ] && run "mv ${ALLOC_BACKUP_DIR}${f} ${ALLOC_BACKUP_DIR}${f}.bak"
      run "mv ${CONFIG_FILE} ${ALLOC_BACKUP_DIR}" "yes"
      CONFIG_FILE="${ALLOC_BACKUP_DIR}${CONFIG_FILE}"
    fi

  fi

  e "To repeat this installation run ${0} ${CONFIG_FILE/\.\//}"
  e_good "Installation Successful!"

  DIR_FULL=${PWD}/${DIR}
  DIR_FULL=${DIR_FULL/\.\//}

  echo
  echo " To complete the installation:                                  " 
  echo "                                                                " 
  echo "   1) Move the ${DIR}alloc.inc file into the PHP include_path.  "
  echo "                                                                "
  echo "   2) Install these into cron to be run as root:                "
  echo "                                                                "
  echo "     25  4 * * * ${ALLOC_BACKUP_DIR}alloc_DB_backup.sh          "
  echo "     */5 * * * * ${DIR_FULL}cron_sendReminders.sh               "
  echo "     35  4 * * * ${DIR_FULL}cron_sendEmail.sh                   "
  echo "     45  4 * * * ${DIR_FULL}cron_checkRepeatExpenses.sh         "
  echo

else 
  e_bad "Installation has not completed successfully!"
  echo 
fi


