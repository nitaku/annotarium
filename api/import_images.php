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

function import_images($doc_label) {
  // return the TEA document having the given label
  $query = "MATCH (n:TEADoc) WHERE n.label = {doc_label} RETURN n AS node, id(n) AS id, labels(n) AS labels";
  $params = array(
    'doc_label' => $doc_label
  );
  $doc = as_doc(cypher($query, $params));
  $doc_id = $doc->id;

  // create the target directory for images, if it does not exist yet
  mkdir("../images/$doc_id");

  // create image nodes and copy image files
  $found_files = [];
  $dir = new DirectoryIterator($doc_label);
  foreach ($dir as $fileinfo) {
    if (!$fileinfo->isDot()) {
      $found_files[] = $fileinfo->getFilename();
    }
  }
  asort($found_files);
  $i = 0;
  foreach($found_files as $s_image_filename) {
    $query = "MATCH (t:TEADoc) WHERE id(t) = {doc_id} CREATE (t)-[:CONTAINS {order: {i}}]->(i:Image:Content {tiled: false}) return id(i) as id";
    $params = array(
      'doc_id' => intval($doc_id),
      'i' => $i
    );
    $t_image = as_objects(cypher($query, $params))[0];
    $t_image_id = $t_image['id'];
    copy("$doc_label/$s_image_filename","../images/$doc_id/$t_image_id.jpg");

    $i++;
  }
}

function import_image_folders() {
  $dir = new DirectoryIterator(getcwd());
  foreach ($dir as $fileinfo) {
    if (!$fileinfo->isDot()) {
      import_images($fileinfo->getFilename());
    }
  }
}

import_image_folders();
?>
