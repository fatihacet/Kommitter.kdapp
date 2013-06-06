class BaseView extends JView

  constructor: (options = {}, data) ->
    
    options.cssClass = "kommitter-app"
    
    super options, data
    
    @container      = new KDView         cssClass : "kommitter-base-container"
    @reposView      = new ReposView      delegate : @
    @kommitView     = new KommitView     delegate : @
    @navigationPane = new NavigationPane delegate : @
    @fileDiffView   = new FileDiffView   delegate : @, ace : @getOptions().ace
    
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
    
    @on "kommitted", =>
      @stagedFilesView.destroySubViews()
      @kommitMessageTextarea.setValue ""
      
    @on "ShowKommitDialog", =>
      @kommitView.setActive()
      
  initialize: ->
    @kommitter = new Kommitter
      delegate: @
    , @getData()
    
    height = @getHeight()
    @reposView.$().css "top", -height
    @container.$().css "top", -height

  kommit: (message) ->
    @kommitter.emit "kommit", FSHelper.escapeFilePath message
    
  push: ->
    @kommitter.emit "push"
    
  refresh: ->
    @workingDirView.destroySubViews()
    @stagedFilesView.destroySubViews()
    @kommitter.emit "refresh"
    
  updateStatusList: (files) ->
    @statusTab.addSubView new StatusList { delegate: @ }, files
          
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
    
    commitsTab.addSubView new KDView
      partial       : "Commits feature will be added soon!"
    
    @repoTabView.addPane browseTab = new KDTabPaneView
      name          : "Browse"
      cssClass      : "browse-tab"
      
    browseTab.addSubView new KDView
      partial       : "Browse feature will be added soon!"
      
    @repoTabView.showPaneByIndex 0
    
  viewAppended: ->
    super
    @utils.wait 3000, =>
      @kommitView.show() # to make a smooth animation, it will be unvisible.
    
  pistachio: ->
    """
      {{> @reposView}}
      {{> @container}}
      {{> @kommitView}}
    """ 