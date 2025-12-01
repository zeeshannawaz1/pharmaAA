<?php
// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);
header('Content-Type: application/json');

try {
    $dbstr = " 
      (DESCRIPTION =
        (ADDRESS = (PROTOCOL = TCP)(HOST = AASERVER)(PORT = 1521))
        (CONNECT_DATA = (SID = orcl))
      )";
    $conn = oci_connect("mednew", "mednew", $dbstr);

    if (!$conn) {
        $e = oci_error();
        echo json_encode([
            'success' => false,
            'message' => 'Database connection failed: ' . $e['message']
        ]);
        exit;
    }

    $dt = date("Y-m-d");
    
    // Check if we have the allSOrders parameter
    if (!isset($_POST['allSOrders'])) {
        echo json_encode([
            'success' => false,
            'message' => 'Missing allSOrders parameter'
        ]);
        exit;
    }
    
    $arr = json_decode($_POST['allSOrders'], true);
    
    if ($arr === null) {
        echo json_encode([
            'success' => false,
            'message' => 'Invalid JSON data: ' . json_last_error_msg()
        ]);
        exit;
    }
    
    if (!isset($arr['data'])) {
        echo json_encode([
            'success' => false,
            'message' => 'Missing data array in request'
        ]);
        exit;
    }

    $inserted_count = 0;
    $errors = [];

    foreach ($arr['data'] as $index => $value) {
        try {
            $stid = oci_parse($conn, "INSERT INTO BOOKED_ORDERS_ONLINE (
                BO_ID, V_DATE, BMCODE, CLIENTCODE, TCODE, TSCODE, CCODE, PRCODE, PCODE, PNAME, QNTY, BQNTY, ODISC, AMOUNT, ORD_STATUS, TPRICE, BTHNO, EXP_DATE, RATE_ID, ORDER_REFRENCE
            ) VALUES (
                :bo_id, TO_DATE(:v_date, 'YYYY-MM-DD'), :bmcode, :clientcode, :tcode, :tscode, :ccode, :prcode, :pcode, :pname, :qnty, :bqnty, :odisc, :amount, :ord_status, :tprice, :bthno, TO_DATE(:exp_date, 'YYYY-MM-DD'), :rate_id, :order_refrence
            )");
            
            if (!$stid) {
                $e = oci_error($conn);
                $errors[] = "Parse error for item $index: " . $e['message'];
                continue;
            }
            
            // Extract and validate data
            $bo_id = isset($value['BO_ID']) ? $value['BO_ID'] : null;
            $v_date = isset($value['V_DATE']) && $value['V_DATE'] ? $value['V_DATE'] : $dt;
            $bmcode = isset($value['BMCODE']) ? $value['BMCODE'] : null;
            $clientcode = isset($value['CLIENTCODE']) ? $value['CLIENTCODE'] : null;
            $tcode = isset($value['TCODE']) ? $value['TCODE'] : null;
            $tscode = isset($value['TSCODE']) ? $value['TSCODE'] : null;
            $ccode = isset($value['CCODE']) ? $value['CCODE'] : null;
            $prcode = isset($value['PRCODE']) ? $value['PRCODE'] : null;
            $pcode = isset($value['PCODE']) ? $value['PCODE'] : null;
            $pname = isset($value['PNAME']) ? $value['PNAME'] : null;
            $qnty = isset($value['QNTY']) ? $value['QNTY'] : null;
            $bqnty = isset($value['BQNTY']) ? $value['BQNTY'] : $qnty; // Default to QNTY if BQNTY not provided
            $odisc = isset($value['ODISC']) ? $value['ODISC'] : 0;
            $amount = isset($value['AMOUNT']) ? $value['AMOUNT'] : null;
            $ord_status = isset($value['ORD_STATUS']) ? $value['ORD_STATUS'] : null;
            $tprice = isset($value['TPRICE']) ? $value['TPRICE'] : null;
            $bthno = isset($value['BTHNO']) ? $value['BTHNO'] : null;
            $exp_date = isset($value['EXP_DATE']) && $value['EXP_DATE'] ? $value['EXP_DATE'] : $dt;
            $rate_id = isset($value['RATE_ID']) ? $value['RATE_ID'] : null;
            $order_refrence = isset($value['ORDER_REFRENCE']) ? $value['ORDER_REFRENCE'] : null;
            
            // Validate required fields
            if (!$bo_id || !$clientcode || !$prcode || !$pcode || !$pname || !$qnty || !$amount) {
                $errors[] = "Missing required fields for item $index";
                continue;
            }
            
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
            
            $result = oci_execute($stid);
            
            if (!$result) {
                $e = oci_error($stid);
                $errors[] = "Execute error for item $index: " . $e['message'];
            } else {
                $inserted_count++;
            }
            
            oci_free_statement($stid);
            
        } catch (Exception $e) {
            $errors[] = "Exception for item $index: " . $e->getMessage();
        }
    }

    oci_close($conn);
    
    // Return JSON response
    if ($inserted_count > 0) {
        echo json_encode([
            'success' => true,
            'message' => "Successfully inserted $inserted_count orders" . (count($errors) > 0 ? " with " . count($errors) . " errors" : ""),
            'inserted_count' => $inserted_count,
            'errors' => $errors
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'No orders were inserted',
            'errors' => $errors
        ]);
    }

} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Server error: ' . $e->getMessage()
    ]);
}
?> 