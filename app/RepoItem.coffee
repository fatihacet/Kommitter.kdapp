class RepoItem extends JView 
  
  constructor: (options = {}, data) ->
    
    options.cssClass = "kommitter-repo-item"
    
    super options, data
    
    @image = new KDCustomHTMLView
      tagName: "span"
    
    if @getOptions().appIcon
      @image = new KDCustomHTMLView
        tagName    : "img"
        cssClass   : "kommitter-repo-icon"
        attributes :
          src      : @getOptions().appIcon
    
  click: ->
    baseView = @getDelegate()
    baseView.setData @getData()
    baseView.initialize()
    
  pistachio: ->
    data  = @getData()
    words = data.split("/")
    name  = words[words.length - 2]
    """
      {{> @image}}
      <span class="kommitter-repo-name">#{name}</span>
      <span class="kommitter-repo-path">#{data}</span>
    """
