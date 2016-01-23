<?php
    if (strcasecmp($_GET["lang"],"EN") == 0) {
        $lang = "EN";
	$oppo = "FR";
    } else {
        $lang = "FR";
	$oppo = "EN";
    }
    passthru('./cv.py -p public -b 10 ' . (getenv('CVPATH') ? '-p ' . getenv('CVPATH') : '') . ' -l ' . $lang);
?>