<?php

// http://www.pubmedcentral.nih.gov/oai/oai.cgi?verb=GetRecord&metadataPrefix=pmc&identifier={identifier}

$dir = __DIR__ . '/data/nlm-2.0';
if (!file_exists($dir)) mkdir($dir, 0700, true);

$dom = new DOMDocument;
$dom->preserveWhiteSpace = false;

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
  $files = array();
  
  foreach ($chunk as $i => $identifier) {
    $file = $dir . '/' . base64_encode($identifier) . '.xml';   
    if (file_exists($file)) continue;

    $files[$i] = $file;

    $params['identifier'] = $identifier;
    $url = 'http://www.pubmedcentral.nih.gov/oai/oai.cgi?' . http_build_query($params);
    print "$url\n"; 

    $connection = curl_init($url);
    curl_setopt($connection, CURLOPT_RETURNTRANSFER, true);
    curl_multi_add_handle($curl, $connection);
    
    $connections[$i] = $connection;
  }

  do {
    curl_multi_exec($curl, $active);
    usleep(100000);
  } while ($active);

  foreach ($connections as $i => $connection) {
    // TODO: check status code
    
    $xml = curl_multi_getcontent($connection);
    curl_multi_remove_handle($curl, $connection);
    curl_close($connection);
    
    $dom->loadXML($xml, LIBXML_NOENT | LIBXML_NOCDATA);

    $xpath = new DOMXPath($dom);
    $xpath->registerNamespace('oai', 'http://www.openarchives.org/OAI/2.0/');

    $root = $xpath->query('oai:' . $params['verb'])->item(0);
    $article = $xpath->query('oai:record/oai:metadata', $root)->item(0)->firstChild;

    $dom->formatOutput = true;
    file_put_contents($files[$i], $dom->saveXML($article));
  }
  
  $finished += count($connections);
  print "Fetched $finished files\n";
}

curl_multi_close($curl);

// ls -al data/nlm-2.0 | wc -l

