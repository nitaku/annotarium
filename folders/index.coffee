folders
  api_location: 'api/'
  root_id: 819
  types:
    TEADoc:
      new: (create) ->
        label = prompt("Insert a label for the new TEA document:")
        if label?
          # create a new entry in ILC's index
          o = {
            name: label,
            code: '',
            idDoc: label
          }
          d3.json 'http://wafi.iit.cnr.it:33065/ClaviusWeb-1.0.3/ClaviusGraph/create'
            .post JSON.stringify(o), (error, d) ->
              if d? and d.id?
                create
                  labels: ['TEADoc']
                  node:
                    label: label
                    code: ''
                    text: ''
                    index_id: d.id

      icon: (d) -> 'book'
      tooltip: (d) -> "#{d.node.label}\nTEA document #{d.id}\nIndexed as #{d.node.index_id}"
      label: (d) -> d.node.label
      href: (d) -> "/webvis/dev/tea_nitaku#docs/#{d.id}"
