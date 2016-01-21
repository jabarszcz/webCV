<?php
    if (strcasecmp($_GET["lang"],"EN") == 0) {
        $lang = "EN";
	$oppo = "FR";
    } else {
        $lang = "FR";
	$oppo = "EN";
    }
    passthru('../cv/cv.py -p public -b 10 -c ../cv -l ' . $lang);
?>