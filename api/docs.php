<?php
header('Content-Type: application/json');

include('neo.php');

function as_doc($data) {
  $objects = as_objects($data);
  $doc = $objects[0]['node'];
  $doc->id = $objects[0]['id'];

  return $doc;
}

function as_neo4j_node_literal($doc) {
  $neo_doc = '{';
  foreach($doc as $key => $value) {
    $neo_doc .= $key . ':';
    if(is_string($value)) {
      $neo_doc .= "'$value'";
    }
    else {
      $neo_doc .= $value;
    }
    $neo_doc .= ',';
  }
  $neo_doc = rtrim($neo_doc, ','); // remove trailing comma
  $neo_doc .= '}';

  return $neo_doc;
}


function create($doc) {
  $neo_doc = as_neo4j_node_literal($doc);

  // store a new TEA document and return it with its id attached
  $query = "CREATE (n:TEADoc $neo_doc) RETURN n AS node, id(n) AS id, labels(n) AS labels";
  return as_doc(cypher($query));
}

function read($id) {
  // return the TEA document having the given id
  $query = "MATCH (n:TEADoc) WHERE id(n) = $id RETURN n AS node, id(n) AS id, labels(n) AS labels";
  return as_doc(cypher($query));
}

function update($doc) {
  $id = $doc->id;

  // id is not a property in our Neo4j db, so it needs to be removed from the doc object
  unset($doc->id);
  $neo_doc = as_neo4j_node_literal($doc);

  // update the given TEA document and return it
  $query = "MATCH (n:TEADoc) WHERE id(n) = $id SET n += $neo_doc RETURN n AS node, id(n) AS id, labels(n) AS labels";
  return as_doc(cypher($query));
}

// FIXME method and presence of the id parameter are used to infer which CRUD method is requested
// FIXME no error handling at all!
switch($_SERVER['REQUEST_METHOD']) {
  case 'POST':
    if(!isset($_GET['id'])) {
      $doc = json_decode(file_get_contents('php://input'));
      echo json_encode(create($doc));
    }
    break;
  case 'GET':
    if(isset($_GET['id'])) {
      $id = $_GET['id'];
      echo json_encode(read($id));
    }
    break;
  case 'PUT':
    if(isset($_GET['id'])) {
      $id = $_GET['id'];
      $doc = json_decode(file_get_contents('php://input'));
      if($id == $doc->id) {
        echo json_encode(update($doc));
      }
    }
    break;
}
?>
