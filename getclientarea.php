<?php

$dbstr=" 
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = AASERVER)(PORT = 1521))
    (CONNECT_DATA = (SID = orcl))
  )";
  global $conn;
  $conn=oci_connect("mednew","mednew",$dbstr);
  if (!$conn){
	  $e=oci_error();
	  trigger_error(htmlentities($e['message'],ENT_QUOTES),E_USER_ERROR);
  }
  global $conn;
  
$sql  = oci_parse($conn, "select to_char(lpad(TS.tScode,2,0)) AREACODE,
 REPLACE(replace(TS.TSNAME,',',' '),'+',' ') AREANAME, '.'  CLIENTADD 
from  C_TOWN T,C_TOWNSUB TS
WHERE t.tcode=ts.tcode");

oci_execute($sql);

$rows = array();
while($r = oci_fetch_assoc($sql)) {
$rows[] = $r;
 }
$locations =(json_encode($rows));
echo $locations;
?>