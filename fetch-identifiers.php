<?php

// http://www.pubmedcentral.nih.gov/oai/oai.cgi?verb=ListIdentifiers&set=elsevierwt&metadataPrefix=pmc

$params = array(
  'verb' => 'ListIdentifiers',
  'metadataPrefix' => 'pmc', // http://www.pubmedcentral.nih.gov/oai/oai.cgi?verb=ListMetadataFormats
  'set' => 'elsevierwt', // http://www.pubmedcentral.nih.gov/oai/oai.cgi?verb=ListSets 
);

$dom = new DOMDocument;
$output = fopen('identifiers.csv', 'w');

do {	
  $url = 'http://www.pubmedcentral.nih.gov/oai/oai.cgi?' . http_build_query($params);
  print "$url\n";

  $dom->load($url);

  $xpath = new DOMXPath($dom);
  $xpath->registerNamespace('oai', 'http://www.openarchives.org/OAI/2.0/');

  $root = $xpath->query('oai:' . $params['verb'])->item(0);

  foreach ($xpath->query('oai:header', $root) as $item) {
    $identifier = $xpath->query('oai:identifier', $item)->item(0)->textContent;	

    $nodes = $xpath->query('oai:setSpec[text()="pmc-open"]', $item);
    if (!$nodes->length) {
      print "Not in pmc-open set: $identifier\n";
      continue;
    }

    fputcsv($output, array($identifier));
  }

  $token = $xpath->query('oai:resumptionToken', $root);
  if (!$token->length) break;

  $params = array(
    'verb' => $params['verb'],
    'resumptionToken' => $token->item(0)->textContent,
    );
} while (1);

// wc -l identifiers.csv
