class StatusList extends JView
    
  constructor: (options = {}, data) ->
    
    super options, data
    
    @header    = new KDHeaderView
      cssClass : "status-list-header"
      
    @container = new KDView
      cssClass : "status-list-container"
    
    @createHeaderItem "Staged"
    @createHeaderItem "Status"
    @createHeaderItem "File Path"
    
    @createItems @getData()
    
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
      
    @container.addSubView item
  
  pistachio: -> 
    """
      {{> @header}}
      {{> @container}}
    """