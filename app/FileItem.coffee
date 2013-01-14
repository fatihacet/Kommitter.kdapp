class FileItem extends KDListItemView
  
  constructor: (options = {}) ->
    
    options.cssClass = "kommitter-file-item"
    
    super options
    
    @type     = @getOptions().type
    @path     = @getOptions().path
    @isStaged = @type == "added"
    
  
  getIcon: (type) ->
    """
      <div class="kommitter-icon kommitter-icon-#{type}"></div>
    """
  
  
  getStagedStatus: ->
    @isStaged
    
  
  partial: -> "#{ @getIcon @getOptions().type}#{ @getOptions().path}"
  
  
  click: (e) =>
    if $(e.target).hasClass 'kommitter-icon'
      @isStaged = !@isStaged
      @getDelegate().emit "stageOrUnstage", @
    else 
      @getDelegate().emit "diff", @path
  