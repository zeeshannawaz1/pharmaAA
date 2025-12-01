<?php
  <?php
 if ($c = oci_connect("mednew", "mednew", "orcl1")) {
   echo "Successfully connected to Oracle.";
   oci_close($c);
 } else {
   $err = oci_error();
   echo "Oracle Connect Error " . $err['text'];
 }
 
 
phpinfo();
?>