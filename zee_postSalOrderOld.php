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
// Connection test mode
if (isset($_GET['test_connection']) && $_GET['test_connection'] == '1') {
    if ($conn) {
        echo json_encode(["status" => "success", "message" => "Oracle DB connection successful."]);
    } else {
        $e = oci_error();
        echo json_encode(["status" => "error", "message" => "DB connection failed", "details" => $e['message']]);
    }
    exit;
}

if (!$conn) {
    $e = oci_error();
    echo json_encode(["status" => "error", "message" => "DB connection failed", "details" => $e['message']]);
    exit;
}


$dt = date("Y-m-d H:i:s");

if (!isset($_POST['allSOrders'])) {
    echo "Error: No order data received.";
    exit;
}

$arr = json_decode($_POST['allSOrders'], true);
if (!$arr || !isset($arr['data'])) {
    echo "Error: Invalid order data format.";
    exit;
}

foreach ($arr['data'] as $value) {
    // Validate and cast numeric fields
    $ORDNO = isset($value['ORDNO']) ? $value['ORDNO'] : '';
    $id = isset($value['id']) ? $value['id'] : '';
    $BMCode = isset($value['BMCode']) ? $value['BMCode'] : '';
    $ClientCode = isset($value['ClientCode']) ? $value['ClientCode'] : '';
    $PrCode = isset($value['PrCode']) ? $value['PrCode'] : '';
    $PCode = isset($value['PCode']) ? $value['PCode'] : '';
    $PName = isset($value['PName']) ? $value['PName'] : '';
    $Qnty = isset($value['Qnty']) ? (is_numeric($value['Qnty']) ? (int)$value['Qnty'] : 0) : 0;
    $BQnty = isset($value['BQnty']) ? (is_numeric($value['BQnty']) ? (int)$value['BQnty'] : 0) : 0;
    $ODisc = isset($value['ODisc']) ? (is_numeric($value['ODisc']) ? (float)$value['ODisc'] : 0) : 0;
    $Amount = isset($value['Amount']) ? (is_numeric($value['Amount']) ? (float)$value['Amount'] : 0) : 0;

    $stid = oci_parse($conn, "INSERT INTO booked_orders_ONLINE (ORDER_REFRENCE, bo_id, bmcode, clientcode, prcode, pcode, pname, qnty, bqnty, odisc, amount,v_date) 
        VALUES (:c0, :c1, :c2, :c3, :c4, :c5, :c6, :c7, :c8, :c9, :c10)");

    oci_bind_by_name($stid, ':c0', $ORDNO);
    oci_bind_by_name($stid, ':c1', $id);
    oci_bind_by_name($stid, ':c2', $BMCode);
    oci_bind_by_name($stid, ':c3', $ClientCode);
    oci_bind_by_name($stid, ':c4', $PrCode);
    oci_bind_by_name($stid, ':c5', $PCode);
    oci_bind_by_name($stid, ':c6', $PName);
    oci_bind_by_name($stid, ':c7', $Qnty);
    oci_bind_by_name($stid, ':c8', $BQnty);
    oci_bind_by_name($stid, ':c9', $ODisc);
    oci_bind_by_name($stid, ':c10', $Amount);

    $r = oci_execute($stid);
    if (!$r) {
        $e = oci_error($stid);
        echo "Error: ".htmlentities($e['message'], ENT_QUOTES)."\n";
    }
}

// Optionally, you can return a JSON response
echo json_encode(["status" => "success", "message" => "Orders processed successfully."]);
exit;
?> 