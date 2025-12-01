<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

$dbstr=" 
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = AASERVER)(PORT = 1521))
    (CONNECT_DATA = (SID = orcl))
  )";

$conn=oci_connect("mednew","mednew",$dbstr);
if (!$conn){
    $e=oci_error();
    trigger_error(htmlentities($e['message'],ENT_QUOTES),E_USER_ERROR);
}

// Get town name from POST request
$townName = $_POST['town_name'] ?? '';

if (empty($townName)) {
    echo json_encode([]);
    exit;
}

// SQL query using the structure provided by user
$sql = oci_parse($conn, "
    SELECT DISTINCT 
        TS.TSCODE as AREACODE,
        TS.TSNAME as AREANAME,
        T.TCODE as TOWNCODE,
        T.TNAME as TOWNNAME
    FROM C_TOWN T, C_TOWNSUB TS
    WHERE T.TCODE = TS.TCODE 
    AND T.TNAME = :town_name
    ORDER BY TS.TSNAME
");

oci_bind_by_name($sql, ':town_name', $townName);
oci_execute($sql);

$rows = array();
while($r = oci_fetch_assoc($sql)) {
    $rows[] = $r;
}

echo json_encode($rows);
?> 