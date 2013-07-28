class FileItem extends KDListItemView
  
  constructor: (options = {}) ->
    
    options.cssClass = "kommitter-file-item"
    
    super options
    
    {@type, @path} = @getOptions()
    @isStaged      = @type == "added"
    
    @createElements()
    
  getStagedStatus: -> @isStaged
  
  typeToLetterMap: 
    "modified"  : "M"
    "added"     : "A"
    "deleted"   : "D"
    "untracked" : "U"
    
  createElements: ->
    @checkbox  = new KDInputView
      type     : "checkbox"
      click    : =>
        @isStaged = !@isStaged
        @getDelegate().emit "StageOrUnstage", @
      
    statusType = @getOptions().type
    @icon      = new KDView
      cssClass : "kommitter-icon kommitter-icon-#{statusType}"
      partial  : @typeToLetterMap[statusType] or ""
      tooltip  : 
        title  : statusType.capitalize()
    
    @name      = new KDView
      cssClass : "file-name"
      partial  : @getOptions().path
      click    : => 
        if @type is "untracked" then @getDelegate().emit "GetFileContent", @path
        else @getDelegate().emit "Diff", @path
    
    @checkbox.getDomElement().removeAttr "checked" unless @getStagedStatus()
  
  viewAppended: ->
    @setTemplate @pistachio()
  
  pistachio: -> 
    """
      {{> @checkbox}}
      {{> @icon}}
      {{> @name}}
    """