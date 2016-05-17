<?php
header('Content-Type: application/json');

include('neo.php');

function read($id) {
  // return the TEA document having the given id
  $query = "MATCH (n:TEADoc) WHERE id(n) = $id RETURN n AS node, id(n) AS id, labels(n) AS labels";

  $objects = as_objects(cypher($query));
  $doc = $objects[0]['node'];
  $doc->id = $objects[0]['id'];

  return $doc;
}

switch($_SERVER['REQUEST_METHOD']) {
  case 'POST':
    break;
  case 'GET':
    echo json_encode(read($_GET['id']));
    break;
  case 'PUT':
    echo 'PUT' . $_GET['id'];
    break;
}

?>
