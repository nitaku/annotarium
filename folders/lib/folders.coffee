# FIXME a folder inside itself is not working
# FIXME scroll to top when entering a new folder

open_folders = []

tipify = (d) ->
  # resolve known node labels as types
  # only one type per node
  d.labels.forEach (l) ->
    if l of types
      d.type = l

types = null # global
el = null # global
api_location = null # global

prop = (d, p, def) ->
   if d.type of types and p of types[d.type] then types[d.type][p](d) else def

type = (d) ->
  thumbnail: prop d, 'thumbnail', null
  icon: prop d, 'icon', 'file-o'
  tooltip: prop d, 'tooltip', "Node #{d.id}"
  label: prop d, 'label', if d.node? and d.node.label? then d.node.label else d.id # "label" protocol
  href: prop d, 'href', null


ls = (cwd, cb) ->
  d3.json "#{api_location}ls.js#{if cwd? then '?cwd='+cwd else ''}", (data) ->
    tipify data.cwd
    data.subnodes.forEach tipify

    cb(data)

window.folders = (conf) ->
  el = if conf.el? then d3.select(conf.el) else d3.select('body')
  types = if conf.types? then conf.types else {}
  root_id = if conf.root_id? then conf.root_id else null
  api_location = if conf.api_location? then conf.api_location else ''

  el.classed 'folders', true

  create_cb = (d) ->
    cwd_id = open_folders[open_folders.length-1].cwd.id
    d3.xhr("#{api_location}new_node.js?cwd_id=#{cwd_id}&labels=#{JSON.stringify(d.labels)}&props=#{JSON.stringify(d.node)}").post {}, () ->
      reload()

  # layout
  bar = el.append 'div'
    .attr
      class: 'bar'

  reload_btn = bar.append 'button'
    .html '<i class="icon fa fa-fw fa-refresh"></i>'
    .on 'click', reload
  up_btn = bar.append 'button'
    .html '<i class="icon fa fa-fw fa-level-up"></i>'
    .on 'click', cd__
  breadcrumb = bar.append 'div'
    .attr
      class: 'breadcrumb'

  cwd = el.append 'div'
    .attr
      class: 'cwd'

  subfolders_container = cwd.append 'div'
    .attr
      class: 'subfolders_container'

  files_container = cwd.append 'div'
    .attr
      class: 'files_container'

  # add buttons to create new "files"
  Object.keys(types).forEach (k) ->
    t = types[k]
    if t.new?
      icon = if t.icon? then t.icon() else 'file-o' # FIXME? this way, icons cannot be functions of data
      bar.append 'button'
        .html "<i class='icon fa fa-fw fa-#{icon}'></i>"
        .on 'click', () ->
          t.new create_cb

  new_folder_btn = bar.append 'button'
    .html '<i class="icon fa fa-fw fa-folder"></i>'
    .on 'click', mkdir

  ls root_id, (root) ->
    # status
    open_folders.push(root)
    redraw()


cd = (id) ->
  ls id, (sf) ->
    open_folders.push sf
    redraw()

cd__ = () ->
  if open_folders.length > 1
    open_folders.pop()
    redraw()

cut_path = (folder) ->
  if open_folders.length is 1 or open_folders[open_folders.length-1].cwd.id is folder.cwd.id
    redraw()
    return

  open_folders.pop()
  cut_path(folder)

reload = () ->
  ls open_folders[open_folders.length-1].cwd.id, (f) ->
    open_folders[open_folders.length-1] = f
    redraw()

redraw = () ->
  cwd_data = open_folders[open_folders.length-1]

  subfolders = el.select('.subfolders_container').selectAll('.subfolder')
    .data(cwd_data.subnodes.filter((d) -> d.is_folder), (d) -> d.id )

  subfolders.enter().append('div')
    .attr
      class: 'subfolder node'
    .html (d) ->
      if d.node.autoquery? # "autoquery" protocol
        overlay = '<i class="fa fa-bolt fa-stack-1x fa-inverse"></i>'
      else
        overlay = ''

      return "<span class='icon fa-stack'><i class='fa fa-folder fa-stack-2x'></i>#{overlay}</span> #{if d.node.label? then d.node.label else d.id}" # "label" protocol
    .on 'click', (d) -> cd d.id

  subfolders.exit().remove()

  subfolders.order()

  files_data = cwd_data.subnodes.filter (d) -> not d.is_folder
  files = el.select('.files_container').selectAll('.file')
    .data(files_data, (d) -> d.id )

  enter_files = files.enter().append('a')
    .attr
      class: 'file node'

  enter_previews = enter_files.append('div')
    .attr
      class: 'preview'

  enter_files.append('div')
    .attr
      class: 'filename'

  enter_files.each augment

  files.exit().remove()

  files.order()

  path_items = el.select('.breadcrumb').selectAll('.path_item')
    .data(open_folders, (d) -> d.cwd.id )

  path_items.enter().append('div')
    .attr
      class: 'path_item'
    .html (d) -> "<span>#{if d.cwd.node.label? then d.cwd.node.label else d.cwd.id}</span>" # "label" protocol
    .on 'click', (d) -> cut_path(d)

  path_items.exit().remove()

mkdir = () ->
  label = prompt('New folder name:','New Folder')
  if label?
    d3.xhr("#{api_location}mkdir.js?label=#{label}&cwd_id=#{open_folders[open_folders.length-1].cwd.id}").post {}, () ->
      reload()

augment = (d) ->
  d3el = d3.select(this)
  # add remote info to d, if specified
  if d.type? and types[d.type].get_remote?
    types[d.type].get_remote d, (remote) ->
      d.remote = remote

      decorate_file d3el
  else
    decorate_file d3el

decorate_file = (file) ->
  file
    .attr
      title: (d) -> type(d).tooltip
      href: (d) -> type(d).href

  file.select '.preview'
    .style
      'background-image': (d) -> if type(d).thumbnail? then "url(#{encodeURI(type(d).thumbnail)})" else null
    .html (d) -> if not type(d).thumbnail? then "<i class='icon fa fa-4x fa-#{type(d).icon}'></i>" else '' # thumbnails have priority over icons

  file.select '.filename'
    .html (d) -> "<span>#{coerce type(d).label}</span>"

L = 28
coerce = (txt) -> if txt.length > L then txt[...L-3] + '...' else txt
