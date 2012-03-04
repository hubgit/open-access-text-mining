<?php

date_default_timezone_set('Europe/London');
$date = date('Y-m-d');

$dir = __DIR__ . '/../../data/whatizit-ukpmcdisease';

$output = fopen($dir . '/diseases.ttl', 'w');
write_triple($output, array('<http://www.ebi.ac.uk/webservices/whatizit/>', 'a', '<http://purl.obolibrary.org/obo/IAO_0000010>'));

$dom = new DOMDocument;

foreach (glob($dir . '/*.xml') as $i => $file) {
  print $file . "\n";

  preg_match('/(\d+)$/', base64_decode(basename($file, '.xml')), $matches);
  $identifier = $matches[1];
  $articleURI = "http://www.ncbi.nlm.nih.gov/pmc/articles/PMC{$identifier}/";

  $dom->load($file);

  $xpath = new DOMXPath($dom);
  $xpath->registerNamespace('ebi', 'http://www.ebi.ac.uk/z');

  foreach ($xpath->query('//ebi:e[@sem="disease"]') as $j => $node) {
    $uri = sprintf('%d-%d', $i, $j);
    
    $annotationURI = '_:annotation-' . $uri;
    
    write_triple($output, array($annotationURI, 'a', '<http://purl.org/ao/Annotation>'));
    write_triple($output, array($annotationURI, '<http://purl.org/pav/createdOn>', sprintf('"%s"', $date)));
    write_triple($output, array($annotationURI, '<http://purl.org/pav/createdWith>', '<http://www.ebi.ac.uk/webservices/whatizit/>'));
    write_triple($output, array($annotationURI, '<http://purl.org/ao/annotatesResource>', "<$articleURI>"));
    
    $ids = trim($node->getAttribute('ids'));
    if ($ids) {
      foreach (explode(',', $ids) as $id) {
        if (!preg_match('/^\d+$/', $id)) continue;
        write_triple($output, array($annotationURI, '<http://purl.org/ao/hasTopic>', "<http://www.uniprot.org/uniprot/{$id}>"));
      }
    }
    
    $contextURI = '_:context-' . $uri;
    write_triple($output, array($annotationURI, '<http://purl.org/ao/context>', "<{$contextURI}>"));
    write_triple($output, array($contextURI, 'a', '<http://purl.org/ao/TextSelector>'));
    write_triple($output, array($contextURI, '<http://purl.org/ao/exact>', sprintf('"%s"', $node->textContent)));
    write_triple($output, array($contextURI, '<http://purl.org/ao/onResource>', "<$articleURI>"));
  }
}

fclose($output);

function write_triple($file, $parts = array()) {
  fwrite($file, implode(' ', (array) $parts) . ".\n");
}
