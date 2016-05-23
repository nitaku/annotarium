d3.select '#search_panel input'
  .on 'keydown', () ->
    if d3.event.keyCode is 13
      wikidata_search this.value

d3.select '#search_button'
  .on 'click', () ->
    user_input = d3.select('#search_panel input').node().value

    wikidata_search user_input    


wikidata_search = (user_input) ->
  # retrieve Wikidata instances and concepts
  d3.json "api/wikidata.php?text=#{user_input}", (err_1, wd_data) ->
    query = JSON.stringify(wd_data.map (d) -> {uri: "http://www.wikidata.org/entity/#{d.id}"})

    index = {}
    wd_data.forEach (d) -> index[d.id] = d

    d3.json "http://wafi.iit.cnr.it:33065/ClaviusWeb-1.0.3/ClaviusSearch/count"
      .post query, (err_2, cs_data) ->

        redraw_boxes((cs_data.filter (d) -> d.count > 0).map (d) -> 
          index[d.uri.split('/').slice(-1)].count = d.count
          return index[d.uri.split('/').slice(-1)])

clavius_search = (uri) ->
  query = '{luceneQuery: "concept:\\"' + uri + '\\""}'

  d3.json 'http://wafi.iit.cnr.it:33065/ClaviusWeb-1.0.3/ClaviusSearch/search'
    .post query, (err, data) ->
      redraw_docs data

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

redraw_boxes = (data) ->
  results = d3.select('#boxes').selectAll '.box'
    .data data, (d) -> d.concepturi

  enter_results = results.enter().append 'div'
    .attr
      class: 'box'
    .on 'click', (d) -> clavius_search d.concepturi

  results.order()

  resource = enter_results.append 'div'
    .attr
      class: 'resource'

  resource.html (d) -> "<span class='label'>#{d.label}</span> <span>(<a target='_blank' class='link' href='#{d.concepturi}'>#{d.id}</a>)</span><div class='description'>#{d.description}</div>"

  count = enter_results.append 'div'
    .attr
      class: 'count'
    .text (d) -> d.count

  results.exit().remove()

redraw_docs = (data) ->
  d3.select '#docs'
    .html ""

  container = d3.select '#docs'

  aggregated_data = d3.nest()
    .key (d) -> d.idDoc
    .entries data

  results = container.selectAll '.doc'
    .data aggregated_data

  results.enter().append 'div'
    .attr
      class: 'doc'

  # Annotations
  results.append 'div'
    .attr
      class: 'label'
    .text (d) -> d.key

  match = results.append 'div'
    .attr
      class: 'annotations'

  annotations = match.selectAll '.annotation'
    .data (d) -> d.values

  annotations.enter().append 'div'
    .attr
      class: 'annotation'

  annotations
    .html (d) -> "...#{d.leftContext.replace(/\n/g, '<br>')} <span class='matched'>#{d.matched.replace(/\n/g, '<br>')}</span> #{d.rightContext.replace(/\n/g, '<br>')}..."