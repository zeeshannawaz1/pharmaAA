<?php
$dbstr=" 
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.10.245)(PORT = 1521))
    (CONNECT_DATA = (SID = orcl))
  )";
$conn = oci_connect("mednew","mednew",$dbstr);

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

if (!isset($_POST['allSOrders'])) {
    echo json_encode(["status" => "error", "message" => "No order data received."]);
    exit;
}

$arr = json_decode($_POST['allSOrders'], true);
if (!$arr || !isset($arr['data'])) {
    echo json_encode(["status" => "error", "message" => "Invalid order data format."]);
    exit;
}

$successCount = 0;
$errorList = [];

foreach ($arr['data'] as $value) {
    // Prepare and validate fields
    $BO_ID = isset($value['BO_ID']) ? (int)$value['BO_ID'] : time();
    $V_DATE = isset($value['V_DATE']) ? $value['V_DATE'] : date('d-M-Y');
    $BMCODE = isset($value['BMCODE']) ? (int)$value['BMCODE'] : 0;
    $CLIENTCODE = isset($value['CLIENTCODE']) ? $value['CLIENTCODE'] : '';
    $TCODE = isset($value['TCODE']) ? (int)$value['TCODE'] : 0;
    $TSCODE = isset($value['TSCODE']) ? (int)$value['TSCODE'] : 0;
    $CCODE = isset($value['CCODE']) ? (int)$value['CCODE'] : 0;
    $PRCODE = isset($value['PRCODE']) ? (int)$value['PRCODE'] : 0;
    $PCODE = isset($value['PCODE']) ? (int)$value['PCODE'] : 0;
    $PNAME = isset($value['PNAME']) ? $value['PNAME'] : '';
    $QNTY = isset($value['QNTY']) ? (int)$value['QNTY'] : 0;
    $BQNTY = isset($value['BQNTY']) ? (int)$value['BQNTY'] : 0;
    $ODISC = isset($value['ODISC']) ? (float)$value['ODISC'] : 0;
    $AMOUNT = isset($value['AMOUNT']) ? (float)$value['AMOUNT'] : 0;
    $ORD_STATUS = isset($value['ORD_STATUS']) ? $value['ORD_STATUS'] : 'N';
    $TPRICE = isset($value['TPRICE']) ? (float)$value['TPRICE'] : 0;
    $BTHNO = isset($value['BTHNO']) ? $value['BTHNO'] : '';
    $EXP_DATE = isset($value['EXP_DATE']) && $value['EXP_DATE'] ? $value['EXP_DATE'] : null;
    $RATE_ID = isset($value['RATE_ID']) ? (int)$value['RATE_ID'] : 0;
    $ORDER_REFRENCE = isset($value['ORDER_REFRENCE']) ? $value['ORDER_REFRENCE'] : '';

    if ($EXP_DATE) {
        $sql = "INSERT INTO BOOKED_ORDERS_ONLINE
            (BO_ID, V_DATE, BMCODE, CLIENTCODE, TCODE, TSCODE, CCODE, PRCODE, PCODE, PNAME, QNTY, BQNTY, ODISC, AMOUNT, ORD_STATUS, TPRICE, BTHNO, EXP_DATE, RATE_ID, ORDER_REFRENCE)
            VALUES (:bo_id, TO_DATE(:v_date, 'DD-MON-YYYY'), :bmcode, :clientcode, :tcode, :tscode, :ccode, :prcode, :pcode, :pname, :qnty, :bqnty, :odisc, :amount, :ord_status, :tprice, :bthno, TO_DATE(:exp_date, 'DD-MON-YYYY'), :rate_id, :order_refrence)";
    } else {
        $sql = "INSERT INTO BOOKED_ORDERS_ONLINE
            (BO_ID, V_DATE, BMCODE, CLIENTCODE, TCODE, TSCODE, CCODE, PRCODE, PCODE, PNAME, QNTY, BQNTY, ODISC, AMOUNT, ORD_STATUS, TPRICE, BTHNO, EXP_DATE, RATE_ID, ORDER_REFRENCE)
            VALUES (:bo_id, TO_DATE(:v_date, 'DD-MON-YYYY'), :bmcode, :clientcode, :tcode, :tscode, :ccode, :prcode, :pcode, :pname, :qnty, :bqnty, :odisc, :amount, :ord_status, :tprice, :bthno, NULL, :rate_id, :order_refrence)";
    }
    $stid = oci_parse($conn, $sql);

    oci_bind_by_name($stid, ':bo_id', $BO_ID);
    oci_bind_by_name($stid, ':v_date', $V_DATE);
    oci_bind_by_name($stid, ':bmcode', $BMCODE);
    oci_bind_by_name($stid, ':clientcode', $CLIENTCODE);
    oci_bind_by_name($stid, ':tcode', $TCODE);
    oci_bind_by_name($stid, ':tscode', $TSCODE);
    oci_bind_by_name($stid, ':ccode', $CCODE);
    oci_bind_by_name($stid, ':prcode', $PRCODE);
    oci_bind_by_name($stid, ':pcode', $PCODE);
    oci_bind_by_name($stid, ':pname', $PNAME);
    oci_bind_by_name($stid, ':qnty', $QNTY);
    oci_bind_by_name($stid, ':bqnty', $BQNTY);
    oci_bind_by_name($stid, ':odisc', $ODISC);
    oci_bind_by_name($stid, ':amount', $AMOUNT);
    oci_bind_by_name($stid, ':ord_status', $ORD_STATUS);
    oci_bind_by_name($stid, ':tprice', $TPRICE);
    oci_bind_by_name($stid, ':bthno', $BTHNO);
    if ($EXP_DATE) {
        oci_bind_by_name($stid, ':exp_date', $EXP_DATE);
    }
    oci_bind_by_name($stid, ':rate_id', $RATE_ID);
    oci_bind_by_name($stid, ':order_refrence', $ORDER_REFRENCE);

    $r = oci_execute($stid);
    if (!$r) {
        $e = oci_error($stid);
        $errorList[] = [
            "order_id" => $BO_ID,
            "error" => $e['message']
        ];
    } else {
        $successCount++;
    }
}

oci_commit($conn);

if (count($errorList) === 0) {
    echo json_encode(["status" => "success", "message" => "All orders processed successfully.", "count" => $successCount]);
} else {
    echo json_encode([
        "status" => "partial_success",
        "message" => "Some orders failed to process.",
        "success_count" => $successCount,
        "errors" => $errorList
    ]);
}
exit;
?> 