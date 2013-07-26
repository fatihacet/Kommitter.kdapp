class LogView extends JView

  constructor: (options = {}, data) ->
    
    options.cssClass = "log-view"
    
    super options, data
    
    @loader    = new KDLoaderView
      size     : 
        width  : 36
    
    @loader.addSubView new KDCustomHTMLView
      partial  : "Fetching log..."
      
    @container = new KDView
      cssClass : "log-container"
      
    @loadMore  = new KDView
      cssClass : "load-more"
      partial  : "Show me more..."
      
    @getDelegate().emit "FetchLog"
    
    @on "CreateLogHistory", (logItems) =>
      @createItems logItems
      @loader.hide()
      @loadMore.show()
      
  createItems: (log) ->
    log.forEach (kommit) =>
      logItem = new LogItem {}, kommit
      logItem.on "LogItemClicked", =>
        @getDelegate().emit "Diff", logItem.getData().id, yes
      
      @container.addSubView logItem
    
  viewAppended: ->
    super
    @loader.show()
  
  pistachio: ->
    """
      {{> @loader}}
      {{> @container}}
      {{> @loadMore}}
    """