<?php

// http://www.pubmedcentral.nih.gov/oai/oai.cgi?verb=GetRecord&metadataPrefix=pmc&identifier={identifier}

$dir = __DIR__ . '/data/nlm-2.0';
if (!file_exists($dir)) mkdir($dir, 0700, true);

$params = array(
  'verb' => 'GetRecord',
  'metadataPrefix' => 'pmc', // http://www.pubmedcentral.nih.gov/oai/oai.cgi?verb=ListMetadataFormats
);

$dom = new DOMDocument;
$dom->preserveWhiteSpace = false;

$connection = curl_init();

curl_setopt_array($connection, array(
  CURLOPT_RETURNTRANSFER => true,
  CURLOPT_ENCODING => 'gzip,deflate',
));

$input = fopen('identifiers.csv', 'r'); // https://gist.github.com/1875622

while (($row = fgetcsv($input)) !== false) {
  list($identifier) = $row;

  $file = $dir . '/' . base64_encode($identifier) . '.xml';
  print "$file\n";
  if (file_exists($file)) continue;

  $params['identifier'] = $identifier;

  $url = 'http://www.pubmedcentral.nih.gov/oai/oai.cgi?' . http_build_query($params);
  print "$url\n";
  
  curl_setopt($connection, CURLOPT_URL, $url);
  $data = curl_exec($connection);
  if (!$data) continue;

  $dom->loadXML($data, LIBXML_NOENT | LIBXML_NOCDATA);

  $xpath = new DOMXPath($dom);
  $xpath->registerNamespace('oai', 'http://www.openarchives.org/OAI/2.0/');

  $root = $xpath->query('oai:' . $params['verb'])->item(0);

  $article = $xpath->query('oai:record/oai:metadata', $root)->item(0)->firstChild;

  $dom->formatOutput = true;
  file_put_contents($file, $dom->saveXML($article));
}

// ls -al articles | wc -l

