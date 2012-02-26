<?php

$dir = __DIR__ . '/../../data/whatizit-ukpmcdisease';
$csv = $dir . '/diseases.csv';
$output = fopen($csv, 'w');

$dom = new DOMDocument;

foreach(glob($dir . '/*.xml') as $file){
  print $file . "\n";

  $dom->load($file);

  $xpath = new DOMXPath($dom);
  $xpath->registerNamespace('ebi', 'http://www.ebi.ac.uk/z');

  $unique = array();

  foreach ($xpath->query('//ebi:e[@sem="disease"]') as $node) {
    $text = $node->textContent;
    $unique[$text]++;
  }

  if (!$unique) continue;

  arsort($unique);

  $identifier = base64_decode(basename($file, '.xml'));
  foreach ($unique as $text => $count) {
    fputcsv($output, array($identifier, $text, $count));
  }
}

print "\n$csv\n";
