<?php

date_default_timezone_set('Europe/London');

$output_dir = __DIR__ . '/../../data/turtle';
if (!file_exists($output_dir)) mkdir($output_dir, 0700, true);

$doc = new DOMDocument;
$doc->preserveWhitespace = false;

foreach (glob('../../data/nlm-3.0/*.xml') as $file) {
  $output_file = $output_dir . '/' . basename($file, '.xml') . '.ttl';
  //if (file_exists($output_file)) continue;
  
  $output = fopen($output_file, 'w');
  
  print "$file\n";
  $doc->load($file);
  
  $xpath = new DOMXPath($doc);
  $xpath->registerNamespace('nlm', 'http://dtd.nlm.nih.gov/2.0/xsd/archivearticle');
  
  preg_match('/(\d+)$/', base64_decode(basename($file, '.xml')), $matches);
  $identifier = $matches[1];
  $articleURI = "<http://www.ncbi.nlm.nih.gov/pmc/articles/PMC{$identifier}/>";

  write_triple($output, array($articleURI, '<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>', '<http://purl.org/ontology/bibo/Article>'));
  
  $nodes = $xpath->query("nlm:front/nlm:article-meta/nlm:title-group/nlm:article-title");
  if ($nodes->length){
    $title = $nodes->item(0)->textContent;
    print "$title\n";
    write_triple($output, array($articleURI, '<http://purl.org/dc/terms/title>', sprintf('"%s"', $title)));
  }
  
  $nodes = $xpath->query("nlm:front/nlm:journal-meta/nlm:issn");
  if ($nodes->length){
    $issn = $nodes->item(0)->textContent;
    print "ISSN: $issn\n";
    write_triple($output, array($articleURI, '<http://purl.org/dc/terms/isPartOf>', "<urn:issn:$issn>"));
  }
  
  $nodes = $xpath->query("nlm:front/nlm:article-meta/nlm:article-id[@pub-id-type='pmid']");
  if ($nodes->length){
    $pmid = $nodes->item(0)->textContent;
    print "PMID: $pmid\n";
    write_triple($output, array($articleURI, '<http://purl.org/dc/terms/identifier>', "<info:pmid/$pmid>"));
  }
  
  $nodes = $xpath->query("nlm:front/nlm:article-meta/nlm:article-id[@pub-id-type='doi']");
  if ($nodes->length){
    $doi = $nodes->item(0)->textContent;
    print "DOI: $doi\n";
    write_triple($output, array($articleURI, '<http://purl.org/dc/terms/identifier>', "<info:doi/$doi>"));
  }
}

function write_triple($file, $parts = array()) {
  $parts = array_map('sanitise', (array) $parts);
  fwrite($file, implode(' ', $parts) . " .\n");
}

function sanitise($text) {
  return preg_replace('/\s+/', ' ', $text);
}
