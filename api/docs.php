<?php
header('Content-Type: application/json');

include('neo.php');

function as_doc($data) {
  $objects = as_objects($data);

  if(count($objects) > 0) {
    $doc = $objects[0]['node'];
    $doc->id = strval($objects[0]['id']);
    return $doc;
  }
  else {
    return null;
  }
}

function create($doc) {
  // store a new TEA document and return it with its id attached
  $query = "CREATE (n:TEADoc {label: {label}, code: {code}, text: {text}}) RETURN n AS node, id(n) AS id, labels(n) AS labels";
  $params = array(
    'label' => $doc->label,
    'code' => $doc->code,
    'text' => $doc->text
  );
  return as_doc(cypher($query, $params));
}

function read($id) {
  // return the TEA document having the given id
  $query = "MATCH (n:TEADoc) WHERE id(n) = {id} RETURN n AS node, id(n) AS id, labels(n) AS labels";
  $params = array(
    'id' => intval($id)
  );
  $doc = as_doc(cypher($query, $params));

  // retrieve images, if any
  $query = "MATCH (n:TEADoc)-[c:CONTAINS]->(i:Content:Image) WHERE id(n) = {id} RETURN id(i) AS id, i.tiled AS tiled ORDER BY c.order";
  $params = array(
    'id' => intval($id)
  );
  $doc->images = as_objects(cypher($query, $params));

  return $doc;
}

function update($doc) {
  $id = $doc->id;

  // update the given TEA document and return it
  $query = "MATCH (n:TEADoc) WHERE id(n) = {id} SET n += {label: {label}, code: {code}, text: {text}} RETURN n AS node, id(n) AS id, labels(n) AS labels";
  $params = array(
    'id' => intval($id),
    'label' => $doc->label,
    'code' => $doc->code,
    'text' => $doc->text
  );
  return as_doc(cypher($query, $params));
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
      $retrieved_doc = read($id);
      if(is_null($retrieved_doc)) {
        http_response_code(404);
      }
      else {
        echo json_encode($retrieved_doc);
      }
    }
    else {
      http_response_code(400);
    }
    break;
  case 'PUT':
    if(isset($_GET['id'])) {
      $id = $_GET['id'];
      $doc = json_decode(file_get_contents('php://input'));
      if($id == $doc->id) {
        $retrieved_doc = update($doc);
        if(is_null($retrieved_doc)) {
          http_response_code(404);
        }
        else {
          echo json_encode($retrieved_doc);
        }
      }
      else {
        http_response_code(400);
      }
    }
    else {
      http_response_code(400);
    }
    break;
}
?>
