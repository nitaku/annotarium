// Generated by CoffeeScript 1.10.0
(function() {
  var neo, new_node;

  neo = require('/var/www/folders/api/neo.js');

  new_node = function(cwd_id, labels, props) {
    var labels_concat;
    labels_concat = labels.length === 0 ? '' : ':' + labels.join(':');
    return neo.cypher({
      query: "MATCH (cwd) WHERE id(cwd) = " + cwd_id + " CREATE (cwd)-[r:SUBNODE]->(n" + labels_concat + " { props }) RETURN n;",
      params: {
        props: props
      },
      callback: function(error, data) {
        if (error) {
          throw error;
        }
        return write('');
      }
    });
  };

  if ((request.query.cwd_id == null) || (request.query.labels == null) || (request.query.props == null)) {
    throw new Error('cwd_id, labels and props must be specified in order to execute the new_node function.');
  } else {
    new_node(request.query.cwd_id, JSON.parse(request.query.labels), JSON.parse(request.query.props));
  }

}).call(this);
