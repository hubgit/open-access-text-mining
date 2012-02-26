<?php

$dir = __DIR__ . '/../../data/biolabeler-all';
if (!file_exists($dir)) mkdir($dir, 0700, true);

$dom = new DOMDocument;
$request = new DOMDocument;
$data = new DOMDocument;
$data->preserveWhitespace = false;

$requestXML = <<<END
<request email="test@example.com" maxConcepts="100">
 <sources>
  <source sab="HUGO"/>
  <source sab="AIR"/>
  <!--
  <source sab="NCI"/>
  <source sab="GO"/>
  <source sab="MSH"/>
  <source sab="NCBI"/>
  <source sab="OMIM"/>
  <source sab="SNOMEDCT"/>
  -->
 </sources>
 <semanticTypes>
  <semanticType>Disease</semanticType>
  <semanticType>Genetic entity</semanticType>
  <!--
  <semanticType>Biological class</semanticType>
  <semanticType>Chemical drugs</semanticType>
  <semanticType>Anatomy</semanticType>
  -->
 </semanticTypes>
 <abstractText></abstractText>
</request>
END;

$curl = curl_init('http://www.biolabeler.com/bioLabeler/rest/request');

foreach(glob(__DIR__ . '/../../data/html/*.html') as $file){
  print "\n$file\n";

  $output = $dir . '/' . basename($file, '.html') . '.xml';
  if (file_exists($output)) continue;

  $dom->load($file);
  $text = $dom->documentElement->textContent;
  
  $request->loadXML($requestXML);  
  $abstractText = $request->createElement('abstractText', htmlspecialchars($text));
  $request->documentElement->appendChild($abstractText);
  
  curl_setopt_array($curl, array(
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_HTTPHEADER => array('Content-Type: text/xml'),
    CURLOPT_POST => true,
    CURLOPT_POSTFIELDS => $request->saveXML($request->documentElement),
  ));

  $response = curl_exec($curl);
  if (!preg_match('/^\s*</', $response)) print "Error loading XML from Biolabeler: $response\n";
  
  try {
    //set_error_handler(xmlErrorHandler);
    $data->loadXML($response);
    $data->formatOutput = true;
    $data->save($output);
  }
  catch (Exception $e){
    print "Error loading XML from Biolabeler: $response\n";
  }
  
  //restore_error_handler();
}

/*
function xmlErrorHandler($code, $message){
  if (preg_match('/^DOMDocument::loadXML\(\): (.+)$/', $message, $matches)) {
    throw new Exception($matches[1]);
  }
}
*/
