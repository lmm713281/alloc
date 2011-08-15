<?php

define("NO_AUTH",1); 
require_once("../alloc.php");


function g($var) {
  $rtn = urldecode($_GET[$var]) or $rtn = $_POST[$var] or $rtn = $_REQUEST[$var];
  $var == "options"    and $rtn = alloc_json_decode($_POST[$var]); 
  return $rtn;
}

if (!version_compare(g("client_version"),get_alloc_version(),">=")) {
  die("Your alloc client needs to be upgraded.");
}

$sessID = g("sessID");

if (g("authenticate") && g("username") && g("password")) {
  $sessID = alloc_services::authenticate(g("username"), g("password"));
  die(alloc_json_encode(array("sessID"=>$sessID)));
}


$alloc_services = new alloc_services($sessID);
global $current_user;
if (!$current_user || !is_object($current_user) || !$current_user->get_id()) {
  die(alloc_json_encode(array("reauthenticate"=>"true")));
}


if ($sessID) {
  if (method_exists($alloc_services,g("method"))) {

    $modelReflector = new ReflectionClass('alloc_services');
    $method = $modelReflector->getMethod(g("method"));
    $parameters = $method->getParameters();

    foreach ((array)$parameters as $v) {
      $a[] = g((string)$v->name);
    }

    $method = g("method");

    // Ouch
    $n = count($parameters);
    if ($n == 9) {
      echo alloc_json_encode($alloc_services->$method($a[0],$a[1],$a[2],$a[3],$a[4],$a[5],$a[6],$a[7],$a[8]));
    } else if ($n == 8) {
      echo alloc_json_encode($alloc_services->$method($a[0],$a[1],$a[2],$a[3],$a[4],$a[5],$a[6],$a[7]));
    } else if ($n == 7) {
      echo alloc_json_encode($alloc_services->$method($a[0],$a[1],$a[2],$a[3],$a[4],$a[5],$a[6]));
    } else if ($n == 6) {
      echo alloc_json_encode($alloc_services->$method($a[0],$a[1],$a[2],$a[3],$a[4],$a[5]));
    } else if ($n == 5) {
      echo alloc_json_encode($alloc_services->$method($a[0],$a[1],$a[2],$a[3],$a[4]));
    } else if ($n == 4) {
      echo alloc_json_encode($alloc_services->$method($a[0],$a[1],$a[2],$a[3]));
    } else if ($n == 3) {
      echo alloc_json_encode($alloc_services->$method($a[0],$a[1],$a[2]));
    } else if ($n == 2) {
      echo alloc_json_encode($alloc_services->$method($a[0],$a[1]));
    } else if ($n == 1) {
      echo alloc_json_encode($alloc_services->$method($a[0]));
    } else if ($n == 0) {
      echo alloc_json_encode($alloc_services->$method());
    }
  }
}


?>
