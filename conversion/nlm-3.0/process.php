<?php

$dir = __DIR__ . '/../../data/nlm-3.0';
if (!file_exists($dir)) mkdir($dir, 0700, true);

$xsl = new DOMDocument;
$xsl->load('2archiving3.xsl'); // http://dtd.nlm.nih.gov/tools/tools.html

$xsltproc = new XSLTProcessor;
$xsltproc->importStyleSheet($xsl);

$doc = new DOMDocument;

foreach (glob('../../data/nlm-2.0/*.xml') as $file) {
  $output = $dir . '/' . basename($file);
  if (file_exists($output)) continue;
  
  print "$file\n";
  $doc->load($file);

  $xml = $xsltproc->transformToDoc($doc);
  $xml->save($output);
}
