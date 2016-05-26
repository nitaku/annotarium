d3.select '#search input'
  .on 'keydown', () ->
    if d3.event.keyCode is 13
      wikidata_search this.value

d3.select '#search_button'
  .on 'click', () ->
    user_input = d3.select('#search input').node().value

    wikidata_search user_input


wikidata_search = (user_input) ->
  # retrieve Wikidata instances and concepts
  d3.json "api/wikidata.php?text=#{user_input}", (err_1, wd_data) ->
    query = JSON.stringify(wd_data.map (d) -> {uri: "http://www.wikidata.org/entity/#{d.id}"})

    index = {}
    wd_data.forEach (d) -> index[d.id] = d

    d3.json "http://wafi.iit.cnr.it:33065/ClaviusWeb-1.0.3/ClaviusSearch/count"
      .post query, (err_2, cs_data) ->

        redraw_concepts((cs_data.filter (d) -> d.count > 0).map (d) ->
          index[d.uri.split('/').slice(-1)].count = d.count
          return index[d.uri.split('/').slice(-1)])

clavius_search = (uri) ->
  query = '{luceneQuery: "concept:\\"' + uri + '\\""}'

  d3.json 'http://wafi.iit.cnr.it:33065/ClaviusWeb-1.0.3/ClaviusSearch/search'
    .post query, (err, results) ->
      result_docs = d3.nest()
        .key (d) -> d.idNeo4j
        .entries results

      result_docs_index = {}
      result_docs.forEach (d) ->
        result_docs_index[parseInt(d.key)] = d

      # augment each result doc with the corresponding TEA document
      d3.json "api/get_docs_by_index_ids.php?index_ids=[#{result_docs.map((d) -> d.key).join(',')}]", (docs) ->
        docs.forEach (d) ->
          result_docs_index[d.node.index_id].doc = d

        redraw_docs result_docs

camelify = (str) ->
  camel_str = ""
  upper_char_index = []

  for char, index in str
    if char is ['-']
      upper_char_index.push index+1
    else if index in upper_char_index
      camel_str += char.toUpperCase()
    else
      camel_str += char

  return camel_str

redraw_concepts = (data) ->
  d3.select('#concepts .counter').remove()
  d3.select('#concepts').append 'div'
    .attr
      class: 'counter'
    .text (d) -> "#{data.length} #{if data.length is 1 then 'Concept' else 'Concepts'} found."

  results = d3.select('#concepts').selectAll '.concept'
    .data data, (d) -> d.concepturi

  enter_results = results.enter().append 'div'
    .attr
      class: 'concept'
    .on 'click', (d) -> clavius_search d.concepturi

  results.order()

  enter_results.append 'div'
    .attr
      class: 'icon'
    .append 'i'
      .attr
        class: 'fa fa-circle-o'
        'aria-hidden': 'true'

  resource = enter_results.append 'div'
    .attr
      class: 'resource'

  resource.append 'span'
    .attr
      class: 'label'
    .text (d) -> d.label
  resource.append 'span'
    .html (d) -> " (<a target='_blank' class='link' href='#{d.concepturi}'>wd:#{d.id}</a>)"
  resource.append 'div'
    .attr
      class: 'description'
    .text (d) -> d.description
  resource.append 'div'
    .attr
      class: 'count'
    .text (d) -> "#{d.count} #{if d.count is 1 then 'Occurrence' else 'Occurrences'} found."

  ###count = enter_results.append 'div'
    .attr
      class: 'count'
    .text (d) -> d.count###

  results.exit().remove()

redraw_docs = (data) ->
  container = d3.select '#docs'
  container.html ""

  container.append 'div'
    .attr
      class: 'counter'
    .text (d) -> "#{data.length} #{if data.length is 1 then 'Document' else 'Documents'} found."

  results = container.selectAll '.doc'
    .data data

  results.enter().append 'div'
    .attr
      class: 'doc'

  # Annotations
  results.append 'div'
    .attr
      class: 'icon'
    .append 'i'
      .attr
        class: 'fa fa-file-o'
        'aria-hidden': 'true'

  right_container = results.append 'div'
  
  right_container.append 'div'
    .attr
      class: 'label'
    .append 'a'
      .attr
        href: (d) ->
          "http://wafi.iit.cnr.it/webvis/dev/tea_nitaku/#docs/#{d.doc.id}"
      .text (d) -> d.doc.node.label

  match = right_container.append 'div'
    .attr
      class: 'annotations'

  annotations = match.selectAll '.annotation'
    .data (d) -> d.values

  annotations.enter().append 'div'
    .attr
      class: 'annotation'

  annotations
    .html (d) -> "...#{d.leftContext.replace(/\n/g, '<br>')} <span class='matched'>#{d.matched.replace(/\n/g, '<br>')}</span> #{d.rightContext.replace(/\n/g, '<br>')}..."
