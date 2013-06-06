class StatusList extends JView
    
  constructor: (options = {}, data) ->
    
    super options, data
    
    @items     = []
    @header    = new KDView
      cssClass : "working-dir-clean"
      partial  : "Nothing to kommit, nothing to say."
      
    @container = new KDView
      cssClass : "status-list-container"
    
    @createItems @getData()
    
    @createHeaders() if @items.length
    
    @on "KommitDone", (staged) =>
      for path in staged
        item.destroy() for item in @items when item.path is path
    
  createHeaders: ->
    @header    = new KDHeaderView
      cssClass : "status-list-header"
    
    @createHeaderItem "Staged"
    @createHeaderItem "Status"
    @createHeaderItem "File Path"
  
  createHeaderItem: (title) ->
    @header.addSubView new KDView
      cssClass : @utils.curryCssClass "header-item", title.replace(" ", "").toLowerCase()
      partial  : title
      
  createItems: (files) ->
    for fileList of files
      for file in files[fileList]
        do (file) =>
          @createFileItem file, fileList
        
  createFileItem: (path, type) ->
    item       = new FileItem {
      delegate : @getDelegate()
      path
      type
    }
      
    item.on "click", => 
      item.setClass "selected" 
      @selectedItem?.unsetClass "selected"
      @selectedItem = item
      
    @items.push item
    @container.addSubView item
  
  pistachio: -> 
    """
      {{> @header}}
      {{> @container}}
    """