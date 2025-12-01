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
  
$sql  = oci_parse($conn, "select to_char(lpad(C.tcode,2,0)||lpad(C.tscode,2,0)||lpad(C.ccode,4,0)) CLIENTCODE,
replace(replace(C.cname,',',' ') ||'-' || REPLACE(replace(TS.TSNAME ,',',' '),'+',' ')||'-'|| REPLACE(replace(T.TNAME,',',' '),'+',' '),'''','`') CLIENTNAME, '.'  CLIENTADD 
from c_client C, C_TOWN T, C_TOWNSUB TS
where  
T.TCODE = TS.TCODE
AND TS.TCODE = C.TCODE
AND TS.TSCODE = C.TSCODE
and nvl(active_status,'Y') = 'Y'
AND C.cname is not null");

$result = oci_execute($sql);
if (!$result) {
    $e = oci_error($sql);
    echo json_encode(['error' => 'Query execution failed: ' . $e['message']]);
    exit;
}

$rows = array();
while($r = oci_fetch_assoc($sql)) {
$rows[] = $r;
 }

// Debug logging
error_log("Clients query returned " . count($rows) . " records");

$locations =(json_encode($rows));
echo $locations;
?>