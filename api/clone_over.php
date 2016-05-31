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

function clone_over($s_id, $t_id) {
  // clone all data from source document to target
  $query = "MATCH (s:TEADoc) WHERE id(s) = {s_id} MATCH (d:TEADoc) WHERE id(d) = {t_id} SET d.text = s.text, d.label = s.label, d.code = s.code";
  $params = array(
    's_id' => intval($s_id),
    't_id' => intval($t_id)
  );
  cypher($query, $params);

  // retrieve images, if any
  $query = "MATCH (n:TEADoc)-[c:CONTAINS]->(i:Content:Image) WHERE id(n) = {s_id} RETURN id(i) AS id, i.tiled AS tiled ORDER BY c.order";
  $params = array(
    's_id' => intval($s_id)
  );
  $images = as_objects(cypher($query, $params));

  // create the target directory for images, if it does not exist yet
  mkdir("../data/images/$t_id");

  // create image nodes and copy image files
  foreach($images as $i => $s_image) {
    $query = "MATCH (t:TEADoc) WHERE id(t) = {t_id} CREATE (t)-[:CONTAINS {order: {i}}]->(i:Image:Content {tiled: false}) return id(i) as id";
    $params = array(
      't_id' => intval($t_id),
      'i' => $i
    );
    $t_image = as_objects(cypher($query, $params))[0];
    $s_image_id = $s_image['id'];
    $t_image_id = $t_image['id'];
    copy("../data/images/$s_id/$s_image_id.jpg","../data/images/$t_id/$t_image_id.jpg");
  }
}

clone_over($argv[1], $argv[2]);
?>
