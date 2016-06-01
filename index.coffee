### Search by key press
###
d3.select '#search input'
  .on 'keydown', () ->
    if d3.event.keyCode is 13
      d3.select '#concepts'
        .html '<div class="counter"><i class="fa fa-spinner fa-pulse fa-2x fa-fw"></i></div>'
      d3.select '#docs'
        .html '<div class="counter"><i class="fa fa-spinner fa-pulse fa-2x fa-fw"></i></div>'

      wikidata_search this.value
      clavius_search this.value, false

### Search by button click
###
d3.select '#search button'
  .on 'click', () ->
    d3.select '#concepts'
      .html '<div class="counter"><i class="fa fa-spinner fa-pulse fa-2x fa-fw"></i></div>'
    d3.select '#docs'
      .html '<div class="counter"><i class="fa fa-spinner fa-pulse fa-2x fa-fw"></i></div>'

    user_input = d3.select('#search input').node().value

    wikidata_search user_input
    clavius_search user_input, false

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

clavius_search = (input, conceptual) ->
  query = if conceptual then '{luceneQuery: "concept:\\"' + input + '\\""}' else JSON.stringify {"luceneQuery": input}

  d3.json 'http://wafi.iit.cnr.it:33065/ClaviusWeb-1.0.3/ClaviusSearch/search'
    .post query, (err, results) ->
      result_docs = d3.nest()
        .key (d) -> d.idDoc
        .entries results

      result_docs_index = {}
      result_docs.forEach (d) ->
        result_docs_index[parseInt(d.key)] = d

      # augment each result doc with the corresponding TEA document
      d3.json "api/get_docs_by_index_ids.php?index_ids=[#{result_docs.map((d) -> d.key).join(',')}]", (docs) ->
        docs.forEach (d) ->
          result_docs_index[d.node.index_id].doc = d

        redraw_docs result_docs

redraw_concepts = (data) ->
  container = d3.select '#concepts'
  container.html '<div class="counter"></div>'

  d3.select '#concepts .counter'
    .text (d) -> "#{data.length} #{if data.length is 1 then 'Concept' else 'Concepts'} found."

  results = d3.select('#concepts').selectAll '.concept'
    .data data, (d) -> d.concepturi

  enter_results = results.enter().append 'div'
    .attr
      class: 'concept'
    .on 'click', (d) ->
      d3.select('#search input').node().value=''
      clavius_search d.concepturi, true

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

  results.exit().remove()

redraw_docs = (data) ->
  container = d3.select '#docs'
  container.html '<div class="counter"></div>'

  container.select '#docs .counter'
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

  # Text with annotations
  match = right_container.append 'div'
    .attr
      class: 'annotations'
  
  annotations = match.selectAll '.annotation'
    .data (d) -> d.values

  annotations.enter().append 'div'
    .attr
      class: 'annotation'

  annotations
    .html (d) -> 
      if d.resourceObject is ''
        "<div>...#{d.leftContext.replace(/\n/g, '<br>')} <span class='matched'>#{d.matched.replace(/\n/g, '<br>')}</span> #{d.rightContext.replace(/\n/g, '<br>')}...</div>"
      else
        "<div>...#{d.leftContext.replace(/\n/g, '<br>')} <span class='matched'>#{d.matched.replace(/\n/g, '<br>')}</span> #{d.rightContext.replace(/\n/g, '<br>')}...</div><div class='wd_resource'><i class='fa fa-circle-o'></i> <a href='#{d.resourceObject}' target='_blank'>wd:#{d.resourceObject.split('/').slice(-1)}</a></div>"
