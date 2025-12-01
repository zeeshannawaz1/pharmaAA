<?php
$dbstr=" 
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.10.245)(PORT = 1521))
    (CONNECT_DATA = (SID = orcl))
  )";
  global $conn;
$conn = oci_connect("mednew","mednew",$dbstr);

if (!$conn){
    $e=oci_error();
    trigger_error(htmlentities($e['message'],ENT_QUOTES),E_USER_ERROR);
}
global $conn;

$dt = date("Y-m-d H:i:s");
$arr = json_decode($_POST['allSOrders'], true);

foreach ($arr['data'] as $value)

$success = true;
$errors = [];
foreach ($arr['data'] as $value) {
    $stid = oci_parse($conn, "INSERT INTO booked_orders_ONLINE 
        (ORDER_REFRENCE, bo_id, bmcode, clientcode, prcode, pcode, pname, qnty, bqnty, odisc, amount, V_DATE) 
        VALUES (:c0, :c1, :c2, :c3, :c4, :c5, :c6, :c7, :c8, :c9, :c10, TO_DATE(:c11, 'YYYY-MM-DD\"T\"HH24:MI:SS'))");
    oci_bind_by_name($stid, ':c0', $value['ORDNO']);
    oci_bind_by_name($stid, ':c1', $value['id']);
    oci_bind_by_name($stid, ':c2', $value['BMCode']);
    oci_bind_by_name($stid, ':c3', $value['ClientCode']);
    oci_bind_by_name($stid, ':c4', $value['PrCode']);
    oci_bind_by_name($stid, ':c5', $value['PCode']);
    oci_bind_by_name($stid, ':c6', $value['PName']);
    oci_bind_by_name($stid, ':c7', $value['Qnty']);
    oci_bind_by_name($stid, ':c8', $value['BQnty']);
    oci_bind_by_name($stid, ':c9', $value['ODisc']);
    oci_bind_by_name($stid, ':c10', $value['Amount']);
    oci_bind_by_name($stid, ':c11', $value['V_DATE']);

    if (!oci_execute($stid)) {
        $e = oci_error($stid);
        $errors[] = $e['message'];
        $success = false;
    }
    oci_free_statement($stid);
}

oci_close($conn);

if ($success) {
    echo json_encode(["status"=>"success", "message"=>"Inserted successfully"]);
} else {
    echo json_encode(["status"=>"error", "message"=>$errors]);
}
?> 