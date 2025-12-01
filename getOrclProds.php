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
    
  $q = "select prcode , pcode, replace(replace(pname,',', '-'),'''','`') PNAME, nvl(tprice,0) TPRICE, nvl(DISTDISC,0) PDISC from c_prod WHERE NVL(ACTIVE_STATUS,'Y') = 'Y'";  
  
$sql  = oci_parse($conn, $q);

oci_execute($sql);

$rows = array();
while($r = oci_fetch_assoc($sql)) {
$rows[] = $r;
 }
$prod =(json_encode($rows));
echo $prod;
?>