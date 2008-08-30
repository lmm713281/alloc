<?php

/*
 * Copyright (C) 2006, 2007, 2008 Alex Lance, Clancy Malcolm, Cybersource
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


require_once(ALLOC_MOD_DIR."email/lib/token.inc.php");
require_once(ALLOC_MOD_DIR."email/lib/tokenAction.inc.php");
require_once(ALLOC_MOD_DIR."email/lib/email.inc.php");
require_once(ALLOC_MOD_DIR."email/lib/email_receive.inc.php");
require_once(ALLOC_MOD_DIR."email/lib/mime_parser.inc.php");
require_once(ALLOC_MOD_DIR."email/lib/sentEmailLog.inc.php");


class email_module extends module {
  var $db_entities = array("token");

  function register_home_items() {
    global $current_user;

  }
}




?>
