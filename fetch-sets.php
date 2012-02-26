<?php

// http://www.pubmedcentral.nih.gov/oai/oai.cgi?verb=ListSets

$params = array('verb' => 'ListSets');
$dom = new DOMDocument;

$output = fopen('sets.csv', 'w');
fputcsv($output, array('id', 'name', 'publisher'));

do {
  $url = 'http://www.pubmedcentral.nih.gov/oai/oai.cgi?' . http_build_query($params);
  print "$url\n";

  $dom->load($url);

  $xpath = new DOMXPath($dom);
  $xpath->registerNamespace('oai', 'http://www.openarchives.org/OAI/2.0/');
  $xpath->registerNamespace('oai_dc', 'http://www.openarchives.org/OAI/2.0/oai_dc/');
  $xpath->registerNamespace('dc', 'http://purl.org/dc/elements/1.1/');

  $root = $xpath->query('oai:' . $params['verb'])->item(0);

  foreach ($xpath->query('oai:set', $root) as $set) {
    $publisher = $xpath->query('oai:setDescription/oai_dc:dc/dc:publisher', $set);

    $item = array(
      'id' => $xpath->query('oai:setSpec', $set)->item(0)->textContent,
      'name' => $xpath->query('oai:setName', $set)->item(0)->textContent,
      'publisher' => $publisher->length ? $publisher->item(0)->textContent : null,
      );

    print_r($item);
    fputcsv($output, array_values($item));
  }

  $token = $xpath->query('oai:resumptionToken', $root);
  if (!$token->length) break;

  $params = array(
    'verb' => $params['verb'],
    'resumptionToken' => $token->item(0)->textContent,
    );
} while (1);
