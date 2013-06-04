class FileItem extends KDListItemView
  
  constructor: (options = {}) ->
    
    options.cssClass = "kommitter-file-item"
    
    super options
    
    @type     = @getOptions().type
    @path     = @getOptions().path
    @isStaged = @type == "added"
    
  getStagedStatus: -> @isStaged
  
  click: (e) =>
    if $(e.target).hasClass 'kommitter-icon'
      @isStaged = !@isStaged
      @getDelegate().emit "stageOrUnstage", @
    else 
      @getDelegate().emit "diff", @path
      
  getIcon: (type) ->
    """
      <div class="kommitter-icon kommitter-icon-#{type}"></div>
    """
  
  partial: -> "#{ @getIcon @getOptions().type}#{ @getOptions().path}"