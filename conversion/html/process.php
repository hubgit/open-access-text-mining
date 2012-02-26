<?php

$dir = __DIR__ . '/../../data/html';
if (!file_exists($dir)) mkdir($dir, 0700, true);

$xsl = new DOMDocument;
$xsl->load('html.xsl');

$xsltproc = new XSLTProcessor;
$xsltproc->importStyleSheet($xsl);

$doc = new DOMDocument;
$doc->preserveWhitespace = false;

foreach (glob('../../data/nlm-3.0/*.xml') as $file) {
  $output = $dir . '/' . basename($file, '.xml') . '.html';
  if (file_exists($output)) continue;
  
  print "$file\n";
  $doc->load($file);

  $html = $xsltproc->transformToDoc($doc);
  $html->formatOutput = true;
  $html->save($output);
}
