<?php

// http://www.pubmedcentral.nih.gov/oai/oai.cgi?verb=GetRecord&metadataPrefix=pmc&identifier={identifier}

$dir = __DIR__ . '/data/nlm-2.0';
if (!file_exists($dir)) mkdir($dir, 0700, true);

$files = array();

$curl = curl_multi_init();

$params = array(
  'verb' => 'GetRecord',
  'metadataPrefix' => 'pmc', // http://www.pubmedcentral.nih.gov/oai/oai.cgi?verb=ListMetadataFormats
);

// https://gist.github.com/1875622
$identifiers = file('identifiers.csv', FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
print count($identifiers) . " identifiers\n";

$finished = 0;

foreach (array_chunk($identifiers, 10) as $chunk){
  $connections = array();
  $handles = array();
  
  foreach ($chunk as $i => $identifier) {
    $file = $dir . '/' . base64_encode($identifier) . '.xml';
    print "$file\n";

    $params['identifier'] = $identifier;
    $url = 'http://www.pubmedcentral.nih.gov/oai/oai.cgi?' . http_build_query($params);

    $connections[$i] = curl_init($url);
    $handles[$i] = fopen($file, 'wb');
    $files[$i] = $file;

    curl_setopt_array($connections[$i], array(
      CURLOPT_HEADER => false,
      CURLOPT_FILE => $handles[$i],
    ));

    curl_multi_add_handle($curl, $connections[$i]);
  }

  do {
    curl_multi_exec($curl, $active);
    usleep(200000);
  } while ($active);

  foreach ($connections as $i => $connection) {
    curl_multi_remove_handle($curl, $connection);
    curl_close($connection);
    fclose($handles[$i]);
  }
  
  $finished += count($connections);
  print "Fetched $finished files\n";
}

curl_multi_close($curl);

$dom = new DOMDocument;
$dom->preserveWhiteSpace = false;

foreach ($files as $file) {
  print "$file\n";

  $dom->load($file, LIBXML_NOENT | LIBXML_NOCDATA);

  $xpath = new DOMXPath($dom);
  $xpath->registerNamespace('oai', 'http://www.openarchives.org/OAI/2.0/');

  $root = $xpath->query('oai:' . $params['verb'])->item(0);
  $article = $xpath->query('oai:record/oai:metadata', $root)->item(0)->firstChild;

  $dom->formatOutput = true;
  file_put_contents($file, $dom->saveXML($article));
}

// ls -al data/nlm-2.0 | wc -l

