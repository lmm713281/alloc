#!/usr/bin/env php
<?php

/*
 * Copyright (C) 2006-2011 Alex Lance, Clancy Malcolm, Cyber IT Solutions
 * Pty. Ltd.
 * 
 * This file is part of the allocPSA application <info@cyber.com.au>.
 * 
 * allocPSA is free software: you can redistribute it and/or modify it
 * under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or (at
 * your option) any later version.
 * 
 * allocPSA is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public
 * License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with allocPSA. If not, see <http://www.gnu.org/licenses/>.
*/

/*
 * This script may need to be run via:
 * sudo -u apache php pipe.php
 *
 * This is because we need to read alloc_config.php
 * which may only be readable by the webserver.
*/

define("NO_AUTH",1);
//require_once(dirname(__FILE__)."/../alloc.php");
require_once(dirname($_SERVER["SUDO_COMMAND"])."/../alloc.php");
singleton("errors_fatal",true);
singleton("errors_format","text");
singleton("errors_logged",true);
singleton("errors_thrown",true);
unset($current_user);


$info = inbox::get_mail_info();

if (!$info["host"]) {
  alloc_error("Email mailbox host not defined, assuming email receive function is inactive.");
}

// Read an email from stdin
while (FALSE !== ($line = fgets(STDIN))) {
  $email[] = $line;
}

// Nuke any mbox header that sendmail/postfix may have prepended.
if ($email[0] == "") {
  array_shift($email);
}
if (preg_match("/^From /i",$email[0])) {
  array_shift($email);
}

$email = implode("", (array)$email);
$email or alloc_error("Empty email message, halting.");

$email_receive = new email_receive($info);
$email_receive->open_mailbox(config::get_config_item("allocEmailFolder"));
$email_receive->set_msg_text($email);
$email_receive->get_msg_header();
$keys = $email_receive->get_hashes();

  try {

    if (!$keys) {
      inbox::convert_email_to_new_task($email_receive,true);
    } else {
      inbox::process_one_email($email_receive);
    }

  } catch (Exception $e) {

    // There may have been a database error, so let the database know it can run this next bit
    db_alloc::$stop_doing_queries = false;

    // Try forwarding the errant email
    try {
      $email_receive->forward(
           config::get_config_item("allocEmailAdmin"),"Email command failed","\n".$e->getMessage()."\n\n".$e->getTraceAsString());

      // If that fails, try last-ditch email send
    } catch (Exception $e) {
      mail(config::get_config_item("allocEmailAdmin"),"Email command failed(2)","\n".$e->getMessage()."\n\n".$e->getTraceAsString());
    }
  }

// Commit the db, and move the email into its storage location eg: INBOX.task1234
$db->commit();
//$email_receive->archive();
$email_receive->expunge();
$email_receive->close();

?>
