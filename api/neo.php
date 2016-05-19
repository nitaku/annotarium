<?php

function cypher($statement, $parameters) {
  $parameters_string = json_encode($parameters);
  $payload = "{\"statements\":[{\"statement\":\"$statement\",\"parameters\":$parameters_string}]}";

  $curl = curl_init('http://localhost:7474/db/data/transaction/commit');
  curl_setopt($curl, CURLOPT_CUSTOMREQUEST, "POST");
  curl_setopt($curl, CURLOPT_POSTFIELDS, $payload);
  curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
  curl_setopt($curl, CURLOPT_HTTPHEADER, array(
      'Content-Type: application/json',
      'Content-Length: ' . strlen($payload))
  );

  return json_decode(curl_exec($curl));
}

function as_objects($data) {
  $array = [];
  foreach($data->results[0]->data as $d) {
    $o = array();
    foreach($d->row as $i => $p) {
      $o[$data->results[0]->columns[$i]] = $d->row[$i];
    }
    array_push($array, $o);
  }
  return $array;
}

?>
