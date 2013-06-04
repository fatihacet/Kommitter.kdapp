class BaseView extends JView

  constructor: (options = {}, data) ->
    
    options.cssClass = "kommitter-app"
    
    super options, data
    
    @container      = new KDView         cssClass : "kommitter-base-container"
    @reposView      = new ReposView      delegate : @
    @navigationPane = new NavigationPane delegate : @
    @fileDiffView   = new FileDiffView   delegate : @, ace : @getOptions().ace
    
    @createRepoTabView()
    
    @mainStage      = new KDSplitView
      cssClass      : "main-stage"
      type          : "horizontal"
      resizable     : yes
      sizes         : [ "30%", "70%" ]
      views         : [ @repoTabView, @fileDiffView ]
    
    @container.addSubView @baseView = new KDSplitView
      cssClass      : "base-view"
      type          : "vertical"
      resizable     : yes
      sizes         : [ "25%", null ]
      views         : [ @navigationPane, @mainStage ]
    
    @on "status", (res) =>
      @navigationPane.emit "UpdateBranchList", res.branch[0]
      delete res.branch
      @updateWorkingDir res
    
    @on "updateStatus", (res) =>
      @removeLeftPanelSubViews()
      @updateWorkingDir res
    
    @on "stageOrUnstage", (item) =>
      eventName = if item.getStagedStatus() then "stage" else "unstage"
      @[eventName] item
      @kommitter.emit eventName, item
    
    @on "diff", (path) =>
      @kommitter.emit "diff", path
    
    @on "kommitted", =>
      @stagedFilesView.destroySubViews()
      @kommitMessageTextarea.setValue ""
      
  initialize: ->
    @kommitter = new Kommitter
      delegate: @
    , @getData()
    
    height = @getHeight()
    @reposView.$().css "top", -height
    @container.$().css "top", -height

  stage: (item) ->
    @workingDirView.removeSubView item
    initialType = item.getOptions().type
    newItem     = new FileItem
      delegate  : @
      path      : item.getOptions().path
      type      : "added"
      oldType   : initialType
      
    @stagedFilesView.addSubView newItem
    
  unstage: (item) ->
    @stagedFilesView.removeSubView item
    newItem     = new FileItem
      delegate  : @
      path      : item.getOptions().path
      type      : item.getOptions().oldType
      
    @workingDirView.addSubView newItem
    
  commit: ->
    if @kommitMessageTextarea.getValue() isnt ""
      @kommitter.emit "commit", FSHelper.escapeFilePath @kommitMessageTextarea.getValue()
    else 
      new KDNotificationView
        title    : "Commit message cannot be empty."
        cssClass : "error"
        type     : "mini"
    
  push: ->
    @kommitter.emit "push"
    
  refresh: ->
    @workingDirView.destroySubViews()
    @stagedFilesView.destroySubViews()
    @kommitter.emit "refresh"
    
  updateWorkingDir: (files) =>
    for fileList of files
      for file in files[fileList]
        do (file) =>
          item       = new FileItem
            delegate : @
            path     : file
            type     : fileList # TODO: naming confusion
            
          target =  if fileList == "added" then @stagedFilesView else @workingDirView
          target.addSubView item
          
  createRepoTabView: ->
    @repoTabView    = new KDTabView
      cssClass      : "repo-tabs"
      height        : "auto"
      hideHandleCloseIcons : yes
      
    @repoTabView.addPane statusTab = new KDTabPaneView
      name          : "Status"
      cssClass      : "status-tab"
      
    @repoTabView.addPane commits   = new KDTabPaneView
      name          : "Commits"
      cssClass      : "commits-tab"
      partial       : "Commits feature will be added soon!"
    
    @repoTabView.addPane browseTab = new KDTabPaneView
      name          : "Browse"
      cssClass      : "browse-tab"
      partial       : "Browse feature will be added soon!"
      
    @repoTabView.showPaneByIndex 0
    
  pistachio: ->
    """
      {{> @reposView}}
      {{> @container}}
    """ 