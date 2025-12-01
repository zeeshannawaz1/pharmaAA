<?php

$dbstr=" 
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.10.245)(PORT = 1521))
    (CONNECT_DATA = (SID = ORCL))
  )";
  global $conn;
  $conn=oci_connect("mednew","mednew",$dbstr);
  if (!$conn){
	  $e=oci_error();
	  trigger_error(htmlentities($e['message'],ENT_QUOTES),E_USER_ERROR);
  }
  global $conn;
  
	
    $p_userid = $_GET['p_userid'];
	//$p_pincode = $_GET['p_pincode'];
  
	$q = "select userid, username, prcode, prgcode, pincode from web_users where userid = " .$p_userid ;
	//$q .= " and pincode = " .$p_pincode;
	
$sql  = oci_parse($conn,  $q);

oci_execute($sql);

$rows = array();
while($r = oci_fetch_assoc($sql)) {
$rows[] = $r;
 }
 if (empty($rows)) {
 echo '[{"USERID":"No ID","USERNAME":"No User","PRCODE":"No PRCODE","PRGCODE":"No PRGCODE","PINCODE":"No PINCODE"}]';
 }
$locations =(json_encode($rows));
echo $locations;
?>