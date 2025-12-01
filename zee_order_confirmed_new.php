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

// Build dynamic WHERE clause
$where = [];
$params = [];

// BMCODE filter
if (!empty($_GET['bmcode'])) {
    $where[] = "BMCODE = :bmcode";
    $params[':bmcode'] = (int)$_GET['bmcode'];
}
// CLIENTCODE filter
if (!empty($_GET['clientcode'])) {
    $where[] = "CLIENTCODE = :clientcode";
    $params[':clientcode'] = $_GET['clientcode'];
}
// Date filters (expects DD-MMM-YYYY format)
if (!empty($_GET['from_date'])) {
    $where[] = "V_DATE >= TO_DATE(:from_date, 'DD-MON-YYYY')";
    $params[':from_date'] = $_GET['from_date'];
}
if (!empty($_GET['to_date'])) {
    $where[] = "V_DATE <= TO_DATE(:to_date, 'DD-MON-YYYY')";
    $params[':to_date'] = $_GET['to_date'];
}

$sql = "SELECT * FROM BOOKED_ORDERS_ONLINE";
if ($where) {
    $sql .= " WHERE " . implode(" AND ", $where);
}
$sql .= " ORDER BY V_DATE DESC, BO_ID DESC";

$stid = oci_parse($conn, $sql);
// Bind parameters
foreach ($params as $key => $val) {
    oci_bind_by_name($stid, $key, $params[$key]);
}

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