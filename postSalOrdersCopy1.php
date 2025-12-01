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

$dt = date("Y-m-d H:i:s");
$arr = json_decode($_POST['allSOrders'],true);

foreach ($arr['data'] as $value) {
    $stid = oci_parse($conn, "INSERT INTO BOOKED_ORDERS_ONLINE (
        BO_ID, V_DATE, BMCODE, CLIENTCODE, TCODE, TSCODE, CCODE, PRCODE, PCODE, PNAME, QNTY, BQNTY, ODISC, AMOUNT, ORD_STATUS, TPRICE, BTHNO, EXP_DATE, RATE_ID, ORDER_REFRENCE
    ) VALUES (
        :bo_id, TO_DATE(:v_date, 'YYYY-MM-DD') , :bmcode, :clientcode, :tcode, :tscode, :ccode, :prcode, :pcode, :pname, :qnty, :bqnty, :odisc, :amount, :ord_status, :tprice, :bthno, TO_DATE(:exp_date, 'YYYY-MM-DD'), :rate_id, :order_refrence
    )");
    oci_bind_by_name($stid, ':bo_id', $value['id']);
    oci_bind_by_name($stid, ':v_date', $value['V_DATE'] ?? $dt);
    oci_bind_by_name($stid, ':bmcode', $value['BMCode']);
    oci_bind_by_name($stid, ':clientcode', $value['ClientCode']);
    oci_bind_by_name($stid, ':tcode', $value['TCODE'] ?? null);
    oci_bind_by_name($stid, ':tscode', $value['TSCODE'] ?? null);
    oci_bind_by_name($stid, ':ccode', $value['CCODE'] ?? null);
    oci_bind_by_name($stid, ':prcode', $value['PrCode']);
    oci_bind_by_name($stid, ':pcode', $value['PCode']);
    oci_bind_by_name($stid, ':pname', $value['PName']);
    oci_bind_by_name($stid, ':qnty', $value['Qnty']);
    oci_bind_by_name($stid, ':bqnty', $value['BQnty']);
    oci_bind_by_name($stid, ':odisc', $value['ODisc']);
    oci_bind_by_name($stid, ':amount', $value['Amount']);
    oci_bind_by_name($stid, ':ord_status', $value['ORD_STATUS'] ?? null);
    oci_bind_by_name($stid, ':tprice', $value['TPRICE'] ?? null);
    oci_bind_by_name($stid, ':bthno', $value['BTHNO'] ?? null);
    oci_bind_by_name($stid, ':exp_date', $value['EXP_DATE'] ?? $dt);
    oci_bind_by_name($stid, ':rate_id', $value['RATE_ID'] ?? null);
    oci_bind_by_name($stid, ':order_refrence', $value['ORDNO']);
    oci_execute($stid);
    oci_free_statement($stid);
}
oci_close($conn);
echo "Successful - zee";
?>