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
      sizes         : [ "40%", null ]
      views         : [ @repoTabView, @fileDiffView ]
    
    @container.addSubView @baseView = new KDSplitView
      cssClass      : "base-view"
      type          : "vertical"
      resizable     : no
      sizes         : [ "15%", null ]
      views         : [ @navigationPane, @mainStage ]
      
    @on "Status", (res) =>
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
    
    @on "Diff", (path, isHash = no) =>
      @kommitter.emit "Diff", path, isHash
      
    @on "ShowDiff", (diff) =>
      @fileDiffView.emit "ShowDiff", diff
    
    @on "GetFileContent", (path) =>
      @kommitter.emit "GetFileContent", path
      
    @on "ShowFileContent", (content) =>
      @fileDiffView.emit "ShowDiff", content, yes
    
    @on "Kommitted", (staged) =>
      @kommitView.emit   "KommitDone"
      @statusList.emit   "KommitDone", staged
      @fileDiffView.emit "KommitDone"
      
    @on "ShowKommitDialog", =>
      if @kommitter.staged.length is 0
        return @notify "Stage a file to commit", 4000, "error" 
      @kommitView.setActive()
      
    @on "ChangeRepo", =>
      @slideViews yes
      @statusList.destroySubViews()
      @fileDiffView.emit "KommitDone"
      {repoTabView} = @
      repoTabView.getPaneByName("Commits").destroySubViews()
      repoTabView.showPaneByIndex 0
      
    @on "NoRepoSelected", =>
      @notify "Easy! Select a repo first!", 2000, "error"
      
    @on "NotImplementedYet", =>
      @notify "This feature is not implemented yet. Stay tuned!", 2000, "info"
      
    @on "Refresh", =>
      @kommitter.emit "Refresh"
      @fileDiffView.emit "KommitDone"
      
    @on "Clone", =>
      new CloneModal delegate: @
      
    @on "Push", =>
      @kommitter.emit "Push"
    
    @on "Exit", =>
      kodingAppManager.quit appManager.getFrontApp()
      
    @on "ShowTerminal", =>
      {repoPath}    = @kommitter
      isSameRepo    = repoPath is @lastRepoPath
      @lastRepoPath = repoPath
      @sendCommandToTerminal if @terminal and isSameRepo then "" else "cd ~/#{@lastRepoPath}"
      
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
      
  refresh: ->
    @workingDirView.destroySubViews()
    @stagedFilesView.destroySubViews()
    @kommitter.emit "refresh"
    
  updateStatusList: (files) ->
    @statusTab.destroySubViews()
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
      
    @repoTabView.addPane @commitsTab = new KDTabPaneView
      name          : "Commits"
      cssClass      : "commits-tab"
    
    @repoTabView.addPane @statsTab = new KDTabPaneView
      name          : "Stats"
      cssClass      : "stats-tab"
      
    @repoTabView.showPaneByIndex 0
    
    @repoTabView.on "PaneDidShow", (pane) =>
      paneNameByClass =
        Commits       :
          paneClass   : LogView
          container   : @commitsTab
          name        : "logView"
        Stats         : 
          paneClass   : StatsView
          container   : @statsTab
          name        : "statsView"
      
      meta = paneNameByClass[pane.getOptions().name]
      if meta and pane.getSubViews().length is 0
        meta.container.addSubView @[meta.name] = new meta.paneClass delegate: @
    
  notify: (title, duration = 2000, cssClass = "success", type = "mini") ->
    return unless title
    new KDNotificationView {
      type
      title
      duration
      cssClass
    }
    
  sendCommandToTerminal: (command) ->
    return @addSubView @terminal = new TerminalView { command } unless @terminal
    @terminal.runCommand command
    
  viewAppended: ->
    super
    @utils.wait 3000, =>
      @kommitView.show() # to make a smooth animation, it will be unvisible.
      
  bindMenuEvents: ->
    eventNameMap   = 
      changeRepo   : "ChangeRepo"
      refresh      : "Refresh"
      clone        : "Clone"
      pull         : "NotImplementedYet"
      kommit       : "ShowKommitDialog"
      push         : "Push"
      ignore       : "IgnoreChanges"
      saveStash    : "NotImplementedYet"
      applyStash   : "NotImplementedYet"
      about        : "ShowAbout"
      showTerminal : "ShowTerminal"
      exit         : "Exit"
    
    for eventKey, eventName of eventNameMap
      do (eventKey, eventName) => 
        appView.on "#{eventKey}MenuItemClicked", (menuItem) =>
          isRepoSelected = @isARepoSelected()
          isRepoRequired = not (menuItem is "exit" or menuItem is "about" or menuItem is "clone")
          if not isRepoSelected and isRepoRequired
            return @emit "NoRepoSelected" 
          @emit eventName

  pistachio: ->
    """
      {{> @reposView}}
      {{> @container}}
      {{> @kommitView}}
    """ 