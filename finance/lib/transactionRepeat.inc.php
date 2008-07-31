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

class transactionRepeat extends db_entity {
  var $data_table = "transactionRepeat";
  var $display_field_name = "product";


  function transactionRepeat() {
    $this->db_entity();         // Call constructor of parent class
    $this->key_field = new db_field("transactionRepeatID");
    $this->data_fields = array("companyDetails"=>new db_field("companyDetails", array("empty_to_null"=>false))
                              ,"payToName"=>new db_field("payToName", array("empty_to_null"=>false))
                              ,"payToAccount"=>new db_field("payToAccount", array("empty_to_null"=>false))
                              ,"tfID"=>new db_field("tfID")
                              ,"fromTfID"=>new db_field("fromTfID")
                              ,"emailOne"=>new db_field("emailOne")
                              ,"emailTwo"=>new db_field("emailTwo")
                              ,"transactionStartDate"=>new db_field("transactionStartDate")
                              ,"transactionFinishDate"=>new db_field("transactionFinishDate")
                              ,"transactionRepeatModifiedUser"=>new db_field("transactionRepeatModifiedUser")
                              ,"reimbursementRequired"=>new db_field("reimbursementRequired",array("empty_to_null"=>false))
                              ,"transactionRepeatModifiedTime"=>new db_field("transactionRepeatModifiedTime")
                              ,"transactionRepeatCreatedTime"=>new db_field("transactionRepeatCreatedTime")
                              ,"transactionRepeatCreatedUser"=>new db_field("transactionRepeatCreatedUser")
                              ,"paymentBasis"=>new db_field("paymentBasis")
                              ,"amount"=>new db_field("amount")
                              ,"product"=>new db_field("product")
                              ,"status"=>new db_field("status")
                              ,"transactionType"=>new db_field("transactionType")


      );

  }

  function is_owner() {
    $tf = new tf;
    $tf->set_id($this->get_value("tfID"));
    $tf->select();
    return $tf->is_owner();
  }

}



?>
