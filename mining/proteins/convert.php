<?php

date_default_timezone_set('Europe/London');
$date = date('Y-m-d');

$dir = __DIR__ . '/../../data/whatizit-swissprot';

$dom = new DOMDocument;

$proteins = array();

foreach (glob($dir . '/*.xml') as $i => $file) {
  print $file . "\n";
  
  $output_file = $dir . '/' . basename($file, '.xml') . '.ttl';
  //if (file_exists($output_file)) continue;
  
  $output = fopen($output_file, 'w');
  
  preg_match('/(\d+)$/', base64_decode(basename($file, '.xml')), $matches);
  $identifier = $matches[1];
  $articleURI = "http://www.ncbi.nlm.nih.gov/pmc/articles/PMC{$identifier}/";

  $dom->load($file);

  $xpath = new DOMXPath($dom);
  $xpath->registerNamespace('ebi', 'http://www.ebi.ac.uk/z');

  foreach ($xpath->query('//ebi:uniprot') as $j => $node) {
    $uri = sprintf('%d-%d', $i, $j);
    
    $annotationURI = '_:annotation-' . $uri;
    
    write_triple($output, array($annotationURI, '<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>', '<http://purl.org/ao/Qualifier>'));
    //write_triple($output, array($annotationURI, '<http://purl.org/pav/createdOn>', sprintf('"%s"', $date)));
    //write_triple($output, array($annotationURI, '<http://purl.org/pav/createdWith>', '<http://www.ebi.ac.uk/webservices/whatizit/>'));
    write_triple($output, array($annotationURI, '<http://purl.org/ao/annotatesResource>', "<$articleURI>"));
    
    $ids = trim($node->getAttribute('ids'));
    if ($ids) {
      //foreach (explode(',', $ids) as $id) {
        //if (!preg_match('/^\w+$/', $id)) continue;
        //$proteins[$id] = true;
        //write_triple($output, array($annotationURI, '<http://purl.org/ao/hasTopic>', "<http://www.uniprot.org/uniprot/{$id}>"));
      //}
      $topicURI = $topics[$ids] ?: '_:topic-' . md5($ids);
      write_triple($output, array($annotationURI, '<http://purl.org/ao/hasTopic>', $topicURI));
      $topics[$ids] = $topicURI;      
    }
    
    $contextURI = '_:context-' . $uri;
    write_triple($output, array($annotationURI, '<http://purl.org/ao/context>', $contextURI));
    write_triple($output, array($contextURI, '<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>', '<http://purl.org/ao/TextSelector>'));
    write_triple($output, array($contextURI, '<http://purl.org/ao/exact>', sprintf('"%s"', $node->textContent)));
    //write_triple($output, array($contextURI, '<http://purl.org/x-ao/lowercase>', sprintf('"%s"', strtolower($node->textContent))));
    write_triple($output, array($contextURI, '<http://purl.org/ao/onResource>', "<$articleURI>"));
  }
  
  fclose($output);
}

$output = fopen($dir . '/topics.ttl', 'w');
write_triple($output, array('<http://www.ebi.ac.uk/webservices/whatizit/>', '<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>', '<http://purl.obolibrary.org/obo/IAO_0000010>'));

foreach ($topics as $topicURI) {
  write_triple($output, array($topicURI, '<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>', '<http://purl.uniprot.org/core/Protein>'));
}

fclose($output);

function write_triple($file, $parts = array()) {
  fwrite($file, implode(' ', (array) $parts) . " .\n");
}
