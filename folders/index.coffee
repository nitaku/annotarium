folders
  api_location: 'api/'
  root_id: 819
  # types:
  #   Link:
  #     new: (create) ->
  #       href = prompt("Insert a URI to create a new link:")
  #       if href?
  #         create
  #           labels: ['Link']
  #           node:
  #             href: href
  #     icon: (d) -> 'external-link'
  #     tooltip: (d) -> "Link to #{d.node.href}\nNode #{d.id}"
  #     label: (d) -> d.node.href
  #     href: (d) -> d.node.href
  #   Gist:
  #     thumbnail: (d) -> "//wafi.iit.cnr.it/webvis/lab/workspace/#{d.node.id}/thumbnail.png"
  #     tooltip: (d) -> "Gist #{d.node.id}\nNode #{d.id}"
  #     label: (d) -> d.node.description
  #     href: (d) -> "//wafi.iit.cnr.it/webvis/lab/preview.php?gist_id=#{d.node.id}"
  #   Software:
  #     thumbnail: (d) -> "//wafi.iit.cnr.it/webvis/lab/images/thumbnails/#{d.node.id}.png"
  #     tooltip: (d) -> "Software #{d.node.id}\nNode #{d.id}"
  #     label: (d) -> d.node.title
  #     href: (d) -> d.node.href
  #   Publication:
  #     icon: (d) -> 'book'
  #     tooltip: (d) -> "Publication #{d.node.id}\nNode #{d.id}"
  #     label: (d) -> d.node.title
  #     href: (d) -> "//wafi.iit.cnr.it/webvis/lab/publications/#{d.node.id}.pdf"
  #   User:
  #     get_remote: (d, cb) ->
  #       d3.json "//api.github.com/users/#{d.node.name}", cb
  #     thumbnail: (d) -> d.remote.avatar_url
  #     tooltip: (d) -> "Github User ID: #{d.node.name}\nNode #{d.id}"
  #     label: (d) -> d.node.name
  #     href: (d) -> "//github.com/#{d.node.name}"
