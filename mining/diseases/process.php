<?php

$dir = __DIR__ . '/../../data/whatizit-ukpmcdisease';
if (!file_exists($dir)) mkdir($dir, 0700, true);

$dom = new DOMDocument;
$client = new SoapClient('http://www.ebi.ac.uk/webservices/whatizit/ws?wsdl');

foreach(glob(__DIR__ . '/../../data/html/*.html') as $file){
  print $file . "\n";

  $output = $dir . '/' . basename($file, '.html') . '.xml';
  if (file_exists($output)) continue;

  $dom->load($file);

  $text = $dom->documentElement->textContent;
  $params = array('text' => $text, 'pipelineName' => 'whatizitUkPmcDisease', 'convertToHtml' => false);

  try {
    $data = $client->contact($params);
  } 
  catch (SoapFault $e) { 
    continue; 
  }

  if (!$data->return) throw new Exception('No results from Whatizit');

  file_put_contents($output, $data->return);

}
