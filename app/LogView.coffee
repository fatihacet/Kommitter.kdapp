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
    @container.addSubView new LogItem {}, kommit for kommit in log
    
  viewAppended: ->
    super
    @loader.show()
  
  pistachio: ->
    """
      {{> @loader}}
      {{> @container}}
      {{> @loadMore}}
    """