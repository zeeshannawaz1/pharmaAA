<?php
error_reporting(0);
ini_set('display_errors', 0);
header('Content-Type: text/plain');

$dbstr=" 
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = AASERVER)(PORT = 1521))
    (CONNECT_DATA = (SID = orcl))
  )";
$conn = oci_connect("mednew","mednew",$dbstr);

if (!$conn){
    $e=oci_error();
    trigger_error(htmlentities($e['message'],ENT_QUOTES),E_USER_ERROR);
}

$dt = date("Y-m-d");
$arr = json_decode($_POST['allSOrders'],true);

foreach ($arr['data'] as $value) {
    $stid = oci_parse($conn, "INSERT INTO BOOKED_ORDERS_ONLINE (
        BO_ID, V_DATE, BMCODE, CLIENTCODE, TCODE, TSCODE, CCODE, PRCODE, PCODE, PNAME, QNTY, BQNTY, ODISC, AMOUNT, ORD_STATUS, TPRICE, BTHNO, EXP_DATE, RATE_ID, ORDER_REFRENCE
    ) VALUES (
        :bo_id, TO_DATE(:v_date, 'YYYY-MM-DD'), :bmcode, :clientcode, :tcode, :tscode, :ccode, :prcode, :pcode, :pname, :qnty, :bqnty, :odisc, :amount, :ord_status, :tprice, :bthno, TO_DATE(:exp_date, 'YYYY-MM-DD'), :rate_id, :order_refrence
    )");
    
    // Use the same keys as Dart (all uppercase)
    $bo_id = $value['BO_ID'];
    $v_date = isset($value['V_DATE']) && $value['V_DATE'] ? $value['V_DATE'] : $dt;
    $bmcode = $value['BMCODE'];
    $clientcode = $value['CLIENTCODE'];
    $tcode = isset($value['TCODE']) ? $value['TCODE'] : null;
    $tscode = isset($value['TSCODE']) ? $value['TSCODE'] : null;
    $ccode = isset($value['CCODE']) ? $value['CCODE'] : null;
    $prcode = $value['PRCODE'];
    $pcode = $value['PCODE'];
    $pname = $value['PNAME'];
    $qnty = $value['QNTY'];
    $bqnty = $value['BQNTY'];
    $odisc = $value['ODISC'];
    $amount = $value['AMOUNT'];
    $ord_status = isset($value['ORD_STATUS']) ? $value['ORD_STATUS'] : null;
    $tprice = isset($value['TPRICE']) ? $value['TPRICE'] : null;
    $bthno = isset($value['BTHNO']) ? $value['BTHNO'] : null;
    $exp_date = isset($value['EXP_DATE']) && $value['EXP_DATE'] ? $value['EXP_DATE'] : $dt;
    $rate_id = isset($value['RATE_ID']) ? $value['RATE_ID'] : null;
    $order_refrence = $value['ORDER_REFRENCE'];
    
    // Bind all variables
    oci_bind_by_name($stid, ':bo_id', $bo_id);
    oci_bind_by_name($stid, ':v_date', $v_date);
    oci_bind_by_name($stid, ':bmcode', $bmcode);
    oci_bind_by_name($stid, ':clientcode', $clientcode);
    oci_bind_by_name($stid, ':tcode', $tcode);
    oci_bind_by_name($stid, ':tscode', $tscode);
    oci_bind_by_name($stid, ':ccode', $ccode);
    oci_bind_by_name($stid, ':prcode', $prcode);
    oci_bind_by_name($stid, ':pcode', $pcode);
    oci_bind_by_name($stid, ':pname', $pname);
    oci_bind_by_name($stid, ':qnty', $qnty);
    oci_bind_by_name($stid, ':bqnty', $bqnty);
    oci_bind_by_name($stid, ':odisc', $odisc);
    oci_bind_by_name($stid, ':amount', $amount);
    oci_bind_by_name($stid, ':ord_status', $ord_status);
    oci_bind_by_name($stid, ':tprice', $tprice);
    oci_bind_by_name($stid, ':bthno', $bthno);
    oci_bind_by_name($stid, ':exp_date', $exp_date);
    oci_bind_by_name($stid, ':rate_id', $rate_id);
    oci_bind_by_name($stid, ':order_refrence', $order_refrence);
    
    oci_execute($stid);
    oci_free_statement($stid);
}
oci_close($conn);
echo "Successful - zee";
?>
