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

$sql = "SELECT * FROM BOOKED_ORDERS_ONLINE ORDER BY V_DATE DESC, BO_ID DESC";
$stid = oci_parse($conn, $sql);
$r = oci_execute($stid);

if (!$r) {
    $e = oci_error($stid);
    echo json_encode(["status" => "error", "message" => $e['message']]);
    exit;
}

$orders = [];
while ($row = oci_fetch_assoc($stid)) {
    $orders[] = $row;
}

oci_free_statement($stid);
oci_close($conn);

echo json_encode([
    "status" => "success",
    "count" => count($orders),
    "orders" => $orders
]);
exit;
?> 