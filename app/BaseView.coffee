class BaseView extends JView

  constructor: (options = {}, data) ->
    
    options.cssClass = "kommitter-app"
    
    super options, data
    
    @container      = new KDView         cssClass : "kommitter-base-container"
    @reposView      = new ReposView      delegate : @
    @kommitView     = new KommitView     delegate : @
    @navigationPane = new NavigationPane delegate : @
    @fileDiffView   = new FileDiffView   delegate : @
    
    @createRepoTabView()
    
    @mainStage      = new KDSplitView
      cssClass      : "main-stage"
      type          : "horizontal"
      resizable     : no
      sizes         : [ "30%", null ]
      views         : [ @repoTabView, @fileDiffView ]
    
    @container.addSubView @baseView = new KDSplitView
      cssClass      : "base-view"
      type          : "vertical"
      resizable     : no
      sizes         : [ "15%", null ]
      views         : [ @navigationPane, @mainStage ]
      
    @on "status", (res) =>
      @navigationPane.emit "UpdateBranchList", res.branch[0]
      delete res.branch
      @updateStatusList res
      
    @on "Kommit", (message) =>
      @kommit message
    
    @on "updateStatus", (res) =>
      @removeLeftPanelSubViews()
      @updateStatusList res
    
    @on "StageOrUnstage", (item) =>
      eventName = if item.getStagedStatus() then "stage" else "unstage"
      item.emit eventName
      @kommitter.emit eventName, item
    
    @on "Diff", (path) =>
      @kommitter.emit "Diff", path
      
    @on "ShowDiff", (diff) =>
      @fileDiffView.emit "ShowDiff", diff
    
    @on "Kommitted", (staged) =>
      @kommitView.emit   "KommitDone"
      @statusList.emit   "KommitDone", staged
      @fileDiffView.emit "KommitDone"
      
    @on "ShowKommitDialog", =>
      @kommitView.setActive()
      
    @on "ChangeRepo", =>
      @slideViews yes
      
    @on "NoRepoSelected", =>
      @notify "Easy! Select a repo first!", 2000, "error"
      
    @on "NotImplementedYet", =>
      @notify "This feature is not implemented yet. Stay tuned!", 2000, "info"
      
    @on "Exit", =>
      kodingAppManager.quit appManager.getFrontApp()
      
    @on "FetchLog", => 
      @kommitter.fetchLog()
      
    @on "LogFetched", (log) =>
      @logView.emit "CreateLogHistory", log
      
    @bindMenuEvents()
      
  initialize: ->
    @kommitter = new Kommitter
      delegate: @
    , @getData()
    
    @slideViews no
    
  slideViews: (showReposView) ->
    height = if showReposView then 0 else -@getHeight()
    @reposView.$().css "top", height
    @container.$().css "top", height

  kommit: (message) ->
    @kommitter.emit "kommit", FSHelper.escapeFilePath message
    
  push: ->
    @kommitter.emit "push"
    
  refresh: ->
    @workingDirView.destroySubViews()
    @stagedFilesView.destroySubViews()
    @kommitter.emit "refresh"
    
  updateStatusList: (files) ->
    @statusTab.addSubView @statusList = new StatusList { delegate: @ }, files
    
  isARepoSelected: ->
    return @kommitter
          
  createRepoTabView: ->
    @repoTabView    = new KDTabView
      cssClass      : "repo-tabs"
      height        : "auto"
      hideHandleCloseIcons : yes
      
    @repoTabView.addPane @statusTab = new KDTabPaneView
      name          : "Status"
      cssClass      : "status-tab"
      
    @repoTabView.addPane commitsTab = new KDTabPaneView
      name          : "Commits"
      cssClass      : "commits-tab"
    
    @repoTabView.addPane browseTab = new KDTabPaneView
      name          : "Browse"
      cssClass      : "browse-tab"
      
    browseTab.addSubView new KDView
      partial       : "Browse feature will be added soon!"
      
    @repoTabView.showPaneByIndex 0
    
    @repoTabView.on "PaneDidShow", (pane) =>
      if pane.getOptions().name is "Commits" and pane.getSubViews().length is 0
        commitsTab.addSubView @logView = new LogView delegate: @
    
  notify: (title, duration = 2000, cssClass = "success", type = "mini") ->
    return unless title
    new KDNotificationView {
      type
      title
      duration
      cssClass
    }
    
  viewAppended: ->
    super
    @utils.wait 3000, =>
      @kommitView.show() # to make a smooth animation, it will be unvisible.
      
  bindMenuEvents: ->
    eventNameMap = 
      changeRepo : "ChangeRepo"
      refresh    : "Refresh"
      pull       : "NotImplementedYet"
      kommit     : "ShowKommitDialog"
      push       : "NotImplementedYet"
      ignore     : "IgnoreChanges"
      saveStash  : "NotImplementedYet"
      applyStash : "NotImplementedYet"
      about      : "ShowAbout"
      exit       : "Exit"
    
    for eventKey, eventName of eventNameMap
      do (eventKey, eventName) => 
        appView.on "#{eventKey}MenuItemClicked", (menuItem) =>
          isRepoSelected = @isARepoSelected()
          isRepoRequired = not (menuItem is "exit" or menuItem is "about")
          if not isRepoSelected and isRepoRequired
            return @emit "NoRepoSelected" 
          @emit eventName

    
  pistachio: ->
    """
      {{> @reposView}}
      {{> @container}}
      {{> @kommitView}}
    """ 