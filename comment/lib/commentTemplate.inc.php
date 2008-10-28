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


class commentTemplate extends db_entity {
  public $data_table = "commentTemplate";
  public $display_field_name = "commentTemplateName";
  public $key_field = "commentTemplateID";
  public $data_fields = array("commentTemplateName"
                             ,"commentTemplateText"
                             ,"commentTemplateType"
                             ,"commentTemplateModifiedTime"
                             );


  function get_populated_template($entity, $entityID=false) {
    // Gets a populated template for this->commentTemplateName
    $str = $this->get_value("commentTemplateText");
    return commentTemplate::populate_string($str, $entity, $entityID);
  }

  function populate_string($str, $entity, $entityID=false) {
    // Actually do the text substitution
    global $current_user;
    $swap["cu"] = person::get_fullname($current_user->get_id());

    if ($entity == "timeSheet" && $entityID) {
      $timeSheet = new timeSheet;
      $timeSheet->set_id($entityID);
      $timeSheet->select();
      $swap["mi"] = $timeSheet->get_id();
      $projectID = $timeSheet->get_value("projectID");
    }

    if ($entity == "task" && $entityID) {
      $task = new task;
      $task->set_id($entityID);
      $task->select();
      $swap["ti"] = $task->get_id();
      $swap["to"] = person::get_fullname($task->get_value("creatorID"));
      $swap["ta"] = person::get_fullname($task->get_value("personID"));
      $swap["tm"] = person::get_fullname($task->get_value("managerID"));
      $swap["tc"] = person::get_fullname($task->get_value("closerID"));
      $swap["tn"] = $task->get_value("taskName");
      $swap["td"] = $task->get_value("taskDescription");
      $swap["tu"] = config::get_config_item("allocURL")."task/task.php?taskID=".$task->get_id();
      $swap["tp"] = $task->get_priority_label();
      $projectID = $task->get_value("projectID");
    }

    if (($entity == "project" && $entityID) || $projectID) {
      $project = new project;
      if($projectID) {
        $project->set_id($projectID);
      } else {
        $project->set_id($entityID);
      }
      $project->select();
      $swap["pn"] = $project->get_value("projectName");
      $swap["pi"] = $project->get_id();
      $clientID = $project->get_value("clientID");
    }

    if (($entity == "client" && $entityID) || $clientID) {
      $client = new client;
      if($clientID) {
        $client->set_id($clientID);
      } else {
        $client->set_id($entityID);
      }
      $client->select();
      $swap["li"] = $client->get_id();
      $swap["cc"] = $client->get_value("clientName");
    }

    $swap["cd"] = config::get_config_item("companyContactAddress");
    $swap["cd"].= " ".config::get_config_item("companyContactAddress2");
    $swap["cd"].= " ".config::get_config_item("companyContactAddress3");
    $swap["cd"].= "\nP: ".config::get_config_item("companyContactPhone");
    $swap["cd"].= "\nF: ".config::get_config_item("companyContactFax");
    $swap["cd"].= "\nE: ".config::get_config_item("companyContactEmail");
    $swap["cd"].= "\nW: ".config::get_config_item("companyContactHomePage");

    $swap["cn"] = config::get_config_item("companyName");

    $swap["c1"] = config::get_config_item("companyContactAddress");
    $swap["c2"] = config::get_config_item("companyContactAddress2");
    $swap["c3"] = config::get_config_item("companyContactAddress3");
    $swap["ce"] = config::get_config_item("companyContactEmail");
    $swap["cp"] = config::get_config_item("companyContactPhone");
    $swap["cf"] = config::get_config_item("companyContactFax");
    $swap["cw"] = config::get_config_item("companyContactHomePage");

    foreach ($swap as $k => $v) {
      $str = str_replace("%".$k,$v,$str);
    }
    return $str;
  }




}
?>
