<?php

$dbstr=" 
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.10.245)(PORT = 1521))
    (CONNECT_DATA = (SID = orcl))
  )";
  global $conn;
  $conn=oci_connect("mednew","mednew",$dbstr);
  if (!$conn){
	  $e=oci_error();
	  trigger_error(htmlentities($e['message'],ENT_QUOTES),E_USER_ERROR);
  }
  global $conn;
  
	
    $p_date = $_GET['p_date'];
	//$originalDate = "2010-03-21";		
	$p_prcode = $_GET['p_prcode'];
	$p_prgcode = $_GET['p_prgcode'];
	
	$newDate = date("d-m-Y", strtotime($p_date));
	//echo $newDate;
	
	//select pcode, pname,packing, tprice, opqty, nvl(purqty,0) - nvl(purrqty,0) purqty, nvl(salqty,0) - nvl(salrqty,0) sqlty, clqty
	//from DAILY_SSR s where prcode = 5 and prgcode = 1 and enddate = '01-May-2021';
	
	$q = "select pcode, pname,packing, tprice, opqty, nvl(purqty,0) - nvl(purrqty,0) purqty, nvl(salqty,0) - nvl(salrqty,0) sqlty, clqty";
	$q .= " from DAILY_SSR s where to_char(enddate,'dd-mm-yyyy') = '" .$newDate ."'";
	$q .= " and prcode = " .$p_prcode;
	//$q .= " and prgcode = " .$p_prgcode;
	$q .= " and prgcode = nvl(" .$p_prgcode .", prgcode)";
	$q .= " order by pname " ;
  
	//$q = "select userid, username, prcode, prgcode, pincode from web_users where userid = " .$p_userid ;
	//$q .= " and pincode = " .$p_pincode;
	
	//echo $q;
	
$sql  = oci_parse($conn,  $q);

oci_execute($sql);

$rows = array();
while($r = oci_fetch_assoc($sql)) {
$rows[] = $r;
 }
 if (empty($rows)) {
 echo '[{"PCODE":"No Data","PNAME":"No Data","PACKING":"-","TPRICE":"-","OPQTY":"0","PURQTY":"0","SQLTY":"0","CLQTY":"0"}]';
 }
$locations =(json_encode($rows));
echo $locations;
?>