get_data = (user_input) ->
  query = JSON.stringify {"luceneQuery": user_input}

  #redraw examples

  d3.json 'http://wafi.iit.cnr.it:33065/ClaviusWeb-1.0.2/ClaviusSearch/search'
    .post query, (err, data) ->
      redraw data

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

d3.select '#search_panel input'
  .on 'keydown', () ->
    if d3.event.keyCode is 13
      get_data this.value

d3.select '#search_button'
  .on 'click', () ->
    user_input = d3.select('#search_panel input').node().value

    get_data user_input    

redraw = (data) ->
  d3.select '#search_results'
    .html ""

  container = d3.select '#search_results'

  # FIXME replace the aggregation with d3.nest function
  aggregated_data = d3.nest()
    .key (d) -> d.idDoc
    .entries data

  # FIXME use data binding identification function
  results = container.selectAll '.doc'
    .data aggregated_data

  results.enter().append 'div'
    .attr
      class: 'doc'

  # DOC id and image
  span = results.append 'div'

  span.append 'div'
    .attr
      class: 'id'
    .text (d) -> "#{d.key}"
  span.append 'a'
    .attr
      href: (d) -> "http://claviusontheweb.it/dualView/?docId=#{d.key.split('_')[1]}"
      target: '_blank'
    .append 'img'
      .attr
        src: (d) -> "http://claviusontheweb.it/exist/rest/db/clavius/documents/#{d.key.split('_')[1]}/thumbnail.jpg"
        title: 'Visualize the manuscript'

  # Annotations
  match = results.append 'div'
    .attr
      class: 'annotations'

  annotations = match.selectAll '.annotation'
    .data (d) -> d.values

  annotations.enter().append 'div'
    .attr
      class: 'annotation'

  annotations.append 'div'
    .attr
      class: 'match'
    .html (d) -> "...#{d.leftContext.replace(/\n/g, '<br>')} <span class='matched'>#{d.matched.replace(/\n/g, '<br>')}</span> #{d.rightContext.replace(/\n/g, '<br>')}..."

  annotations.append 'div'
    .attr
      class: 'concepts'
    
    .html (d) -> 
      if d.concept is '' then '' else '(' + (d.concept.split(' ').map((c,i) -> "#{if i > 0 then ', ' else ''}<span class='concept'>#{camelify(c)}</span>").slice(0,-1).join('')) + ')'

  d3.selectAll '.concept'
    .on 'click', (d) -> 
      d3.select('#search_panel input').node().value = "concept:#{this.textContent}"
      get_data "concept:#{this.textContent}"