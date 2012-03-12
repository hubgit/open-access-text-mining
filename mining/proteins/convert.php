<?php

date_default_timezone_set('Europe/London');
$date = date('Y-m-d');

$dir = __DIR__ . '/../../data/whatizit-swissprot';

$dom = new DOMDocument;

$proteins = array();

$topicsOutput = fopen($dir . '/topics.ttl', 'w');
write_triple($topicsOutput, array('<http://www.ebi.ac.uk/webservices/whatizit/>', '<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>', '<http://purl.obolibrary.org/obo/IAO_0000010>'));

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
  
  $annotations = array();

  foreach ($xpath->query('//ebi:uniprot') as $j => $node) {
	$ids = trim($node->getAttribute('ids'));
	if (!$ids) continue;
	
	/* context */
	$contextURI = "_:context-$i-$j";
    write_triple($output, array($contextURI, '<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>', '<http://purl.org/ao/TextSelector>'));
    write_triple($output, array($contextURI, '<http://purl.org/ao/exact>', sprintf('"%s"', $node->textContent)));
    write_triple($output, array($contextURI, '<http://purl.org/ao/onResource>', "<$articleURI>"));
	
	/* topic */
    $topicURI = $topics[$ids];
    if (!$topicURI) {
		$topicSuffix = md5($ids);
		$topicURI = 'http://www.ebi.ac.uk/webservices/whatizit/whatizitSwissprot/' . $topicSuffix;
		write_triple($topicsOutput, array("<$topicURI>", '<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>', '<http://purl.uniprot.org/core/Protein>'));
		$topics[$ids] = $topicURI;
	}
	
    /* annotation */
    $annotationURI = $annotations[$ids];
    if (!$annotationURI) {   
		$annotationURI = "_:annotation-$i-$j";
		write_triple($output, array($annotationURI, '<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>', '<http://purl.org/ao/Qualifier>'));
		write_triple($output, array($annotationURI, '<http://purl.org/ao/annotatesResource>', "<$articleURI>"));
		//write_triple($output, array($annotationURI, '<http://purl.org/pav/createdOn>', sprintf('"%s"', $date)));
		//write_triple($output, array($annotationURI, '<http://purl.org/pav/createdWith>', '<http://www.ebi.ac.uk/webservices/whatizit/>'));
		write_triple($output, array($annotationURI, '<http://purl.org/ao/hasTopic>', "<$topicURI>"));
		$annotations[$ids] = $annotationURI;
	}
	
	write_triple($output, array($annotationURI, '<http://purl.org/ao/context>', $contextURI));	
  }
  
  fclose($output);
}


function write_triple($file, $parts = array()) {
  fwrite($file, implode(' ', (array) $parts) . " .\n");
}
