<?php

$dbstr=" 
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = Famous)(PORT = 1521))
    (CONNECT_DATA = (SID = orcl))
  )";
  global $conn;
  $conn=oci_connect("med","med123",$dbstr);
  if (!$conn){
	  $e=oci_error();
	  trigger_error(htmlentities($e['message'],ENT_QUOTES),E_USER_ERROR);
  }
  global $conn;
  
$sql  = oci_parse($conn, "select prcode, pcode, pname, tprice, distdisc PDISC from c_prod");

oci_execute($sql);

$rows = array();
while($r = oci_fetch_assoc($sql)) {
$rows[] = $r;
 }
$locations =(json_encode($rows));
echo $locations;
?>