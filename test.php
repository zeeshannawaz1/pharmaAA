<?php
//$json = '{"1":"a","2":"b","3":"c","4":"d","5":"e"}';
$json = '{"data":[{"ODisc":"1","PCode":"1","ClientCode":"01","Amount":"95","Qnty":"1","BQnty":"1","PrCode":"1","BMCode":"1","PName":"AQUA VIT SACHETES"},{"ODisc":"0","PCode":"1","ClientCode":"1","Amount":"5225","Qnty":"55","BQnty":"0","PrCode":"1","BMCode":"1","PName":"AQUA VIT SACHETES"},{"ODisc":"0","PCode":"6","ClientCode":"1","Amount":"318","Qnty":"6","BQnty":"1","PrCode":"1","BMCode":"1","PName":"CALCEE FORTE SACHET"},{"ODisc":"3","PCode":"7","ClientCode":"1","Amount":"150","Qnty":"10","BQnty":"0","PrCode":"1","BMCode":"1","PName":"CALCIUM SYP"},{"ODisc":"0","PCode":"1","ClientCode":"1","Amount":"59500","Qnty":"1","BQnty":"0","PrCode":"2","BMCode":"1","PName":"ALIMTA 500MG INJ"},{"ODisc":"0","PCode":"4","ClientCode":"1","Amount":"19550","Qnty":"2","BQnty":"1","PrCode":"2","BMCode":"1","PName":"BYETTA PRE-FILLED PEN 10MCG"},{"ODisc":"0","PCode":"6","ClientCode":"1","Amount":"105","Qnty":"1","BQnty":"0","PrCode":"2","BMCode":"1","PName":"DISTALGESIC TAB"},{"ODisc":"0","PCode":"1","ClientCode":"0101001","Amount":"95","Qnty":"1","BQnty":"0","PrCode":"1","BMCode":"5","PName":"AQUA VIT SACHETES"},{"ODisc":"0","PCode":"60","ClientCode":"0101001","Amount":"1530","Qnty":"10","BQnty":"0","PrCode":"1","BMCode":"999","PName":"ORASAL- F"},{"ODisc":"0","PCode":"81","ClientCode":"0101001","Amount":"2550","Qnty":"5","BQnty":"0","PrCode":"1","BMCode":"999","PName":"SAVE 40MG TAB"},{"ODisc":"0","PCode":"30","ClientCode":"0801053","Amount":"520","Qnty":"10","BQnty":"0","PrCode":"1","BMCode":"999","PName":"EFFIMOX 250MG CAP"},{"ODisc":"0","PCode":"96","ClientCode":"0801053","Amount":"195","Qnty":"5","BQnty":"0","PrCode":"1","BMCode":"999","PName":"TRICOF SYP 120ML"},{"ODisc":"0","PCode":"1","ClientCode":"01010001","Amount":"95","Qnty":"1","BQnty":"0","PrCode":"1","BMCode":"1","PName":"AQUA VIT SACHETES"},{"ODisc":"0","PCode":"30","ClientCode":"01060040","Amount":"52","Qnty":"1","BQnty":"0","PrCode":"1","BMCode":"1","PName":"EFFIMOX 250MG CAP"},{"ODisc":"0","PCode":"1","ClientCode":"01010001","Amount":"95","Qnty":"1","BQnty":"0","PrCode":"1","BMCode":"1","PName":"AQUA VIT SACHETES"},{"ODisc":"0","PCode":"5","ClientCode":"01010001","Amount":"791","Qnty":"7","BQnty":"0","PrCode":"1","BMCode":"1","PName":"CALCEE - PLUS ORANGE"}]}';
 $obj = json_decode($json, TRUE);
//echo $obj;
foreach($obj['data'] as  $value) 
{
	echo $value['ODisc'];
	echo $value['PCode'];
	echo "<br>";
//echo 'Your key is: '.$key.' and the value of the key is:'.$value;
}

?>