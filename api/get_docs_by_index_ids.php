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

function get_docs_by_index_ids($ids) {
  $ids_string = json_encode($ids);

  // return the TEA document having the given index_id
  $query = "MATCH (n:TEADoc) WHERE n.index_id IN $ids_string RETURN n AS node, id(n) AS id, labels(n) AS labels";
  $docs = as_objects(cypher($query));

  return $docs;
}


if(isset($_GET['index_ids'])) {
  $index_ids = json_decode($_GET['index_ids'], true);
  $retrieved_docs = get_docs_by_index_ids($index_ids);
  if(is_null($retrieved_docs)) {
    http_response_code(404);
  }
  else {
    echo json_encode($retrieved_docs);
  }
}
else {
  http_response_code(400);
}

?>
