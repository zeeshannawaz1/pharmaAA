<?php
$dbstr=" 
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = NISB-TSS-P4970)(PORT = 1521))
    (CONNECT_DATA = (SID = ORCL))
  )";
  global $conn;
  $conn=oci_connect("med","med",$dbstr);
  if (!$conn){
	  $e=oci_error();
	  trigger_error(htmlentities($e['message'],ENT_QUOTES),E_USER_ERROR);
  }
  global $conn;
  //$col2 = &_POST['col1'];
  //[
  //':c1' => $_POST['col']
  //]
  $stid = oci_parse($conn, "INSERT INTO mytab (col1, col2) VALUES (:c1,:c2)");

  oci_bind_by_name($stid, ':c1', $_POST['col1']);  
  oci_bind_by_name($stid, ':c2', $_POST['col2']);  
	
  oci_execute($stid);  // commits both 123 and 4
  
  echo "Successful-Asif";
  error_reporting(2);
  ?>