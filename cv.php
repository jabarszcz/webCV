<?php
// --------------LOGGING--------------------
// Taken and adapted from http://www.ebrueggeman.com/blog/php_site_access_log

// This is a simple way of logging web page accesses without needing the priviledges
// to modify the apache server config.

//ASSIGN VARIABLES TO USER INFO
$time = date("M j G:i:s Y");
$ip = getenv('REMOTE_ADDR');
$host = $_SERVER['REMOTE_HOST'];
$userAgent = getenv('HTTP_USER_AGENT');
$referrer = $_SERVER['HTTP_REFERER'];
$query = $_SERVER['REQUEST_URI'];

//COMBINE VARS INTO OUR LOG ENTRY
$msg = "[" . $time . "] (" . $ip . " : " . $host . ") " . $query . " REFERRER: " . $referrer . " USERAGENT: " . $userAgent;

//CALL OUR LOG FUNCTION
writeToLogFile($msg);

function writeToLogFile($msg) {
     $today = date("Y_m_d");
     $logfile = $today."_log.txt";
     $dir = 'logs';
     $saveLocation=$dir . '/' . $logfile;
     if  (!$handle = @fopen($saveLocation, "a")) {
	  echo("Not able to open log file\r\n");
          exit;
     }
     else {
          if (@fwrite($handle,"$msg\r\n") === FALSE) {
               exit;
          }

          @fclose($handle);
     }
}

// -------------CALL PYTHON SCRIPT -----------------------
    if (strcasecmp($_GET["lang"],"EN") == 0) {
        $lang = "EN";
	$oppo = "FR";
    } else {
        $lang = "FR";
	$oppo = "EN";
    }
    passthru('./cv.py -p public -b 10 ' . (getenv('CVPATH') ? '-c ' . getenv('CVPATH') : '') . ' -l ' . $lang);
?>
