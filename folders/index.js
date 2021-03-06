// Generated by CoffeeScript 1.10.0
(function() {
  folders({
    api_location: 'api/',
    root_id: 819,
    types: {
      TEADoc: {
        "new": function(create) {
          var label, o;
          label = prompt("Insert a label for the new TEA document:");
          if (label != null) {
            o = {
              name: label,
              code: '',
              idDoc: label
            };
            return d3.json('http://wafi.iit.cnr.it:33065/ClaviusWeb-1.0.3/ClaviusGraph/create').post(JSON.stringify(o), function(error, d) {
              if ((d != null) && (d.id != null)) {
                return create({
                  labels: ['TEADoc'],
                  node: {
                    label: label,
                    code: '',
                    text: '',
                    index_id: d.id
                  }
                });
              }
            });
          }
        },
        icon: function(d) {
          return 'book';
        },
        tooltip: function(d) {
          return d.node.label + "\nTEA document " + d.id + "\nIndexed as " + d.node.index_id;
        },
        label: function(d) {
          return d.node.label;
        },
        href: function(d) {
          return "/webvis/dev/tea_nitaku#docs/" + d.id;
        }
      }
    }
  });

}).call(this);
