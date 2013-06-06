class RepoItem extends JView 
  
  constructor: (options = {}, data) ->
    
    options.cssClass = "kommitter-repo-item"
    
    super options, data
    
    @image       = new KDCustomHTMLView
      tagName    : "img"
      cssClass   : "kommitter-repo-icon"
      bind       : "error"
      error      : => @setDefaultIcon()
      attributes : src : @getOptions().appIcon
    
  click: ->
    baseView = @getDelegate()
    baseView.setData @getData()
    baseView.initialize()
    
  setDefaultIcon: ->
    @image.getDomElement().attr "src", "https://koding.com/images/default.app.thumb.png"
    
  pistachio: ->
    data  = @getData()
    words = data.split "/"
    name  = words[words.length - 2]
    """
      {{> @image}}
      <span class="kommitter-repo-name">#{name}</span>
      <span class="kommitter-repo-path">#{data}</span>
    """
