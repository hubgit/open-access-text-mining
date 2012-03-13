<?php

$dir = __DIR__ . '/../../data/whatizit-swissprot';
if (!file_exists($dir)) mkdir($dir, 0700, true);

$dom = new DOMDocument;
$client = new SoapClient('http://www.ebi.ac.uk/webservices/whatizit/ws?wsdl');

foreach(glob(__DIR__ . '/../../data/html/*.html') as $file){
  $output = $dir . '/' . basename($file, '.html') . '.xml';
  if (file_exists($output)) continue;

  print $file . "\n";

  $dom->load($file);
  
  $params = array(
    'pipelineName' => 'whatizitSwissprot', 
    'convertToHtml' => false,
    'text' => $dom->documentElement->textContent, 
  );

  try {
    $data = $client->contact($params);
  } 
  catch (SoapFault $e) { 
	  print $e->getMessage() . "\n";
    continue; 
  }

  if (!$data->return) throw new Exception('No results from Whatizit');

  file_put_contents($output, $data->return);

}
