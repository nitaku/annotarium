<?php
  header("Content-Type: application/json");
  
  $text = urlencode($_GET['text']);
  $final_result = array();

  /*  Making ASYNC call would support even more languages
  */
  $languages = array('en', 'it');
  
  /* A call to the wikidata API is perfomed until the search-continue attribute is present in the API result
  */
  foreach ($languages as $lang) {

    $offset = 0;

    do {
      $result = json_decode(file_get_contents("https://www.wikidata.org/w/api.php?action=wbsearchentities&type=item&search=$text&limit=max&continue=$offset&language=$lang&format=json"), true);

      if (isset($result['search-continue']))
        $offset = $result['search-continue'];

      $final_result = array_merge($final_result, $result['search']);

    } while (isset($result['search-continue']));

  }

  echo json_encode(array_merge(array_unique($final_result, SORT_REGULAR), array()));
?>