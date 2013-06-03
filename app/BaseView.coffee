class BaseView extends JView

  constructor: (options = {}, data) ->
    
    @ace             = options.ace
    options.cssClass = "kommitter-app"
    
    super options, data
    
    @reposView = new ReposView
      delegate : @
    
    @container = new KDView
      cssClass : "kommitter-base-container"
    
    #@container.addSubView @branchName = new KDView
      #cssClass : "kommitter-branch-name"
      #partial  : "Current branch: ... "
      
    #@workingDirView = new KDView
      
    #@stagedFilesView = new KDView
      
    #@diffView = new KDView
    
    #@kommitView = new KDView
    
    #@kommitView.addSubView buttonsView = new KDView
      #cssClass : "kommitter-buttons-view"
    #
    #buttonsView.addSubView @refreshButton = new KDButtonView
      #title    : "Refresh"
      #callback : => @refresh()
    #
    #buttonsView.addSubView @commitButton = new KDButtonView
      #title    : "Commit"
      #callback : => @commit()
    #
    #buttonsView.addSubView @pushButton = new KDButtonView
      #title    : "Push"
      #callback : => @push()
    #
    #@kommitView.addSubView @kommitMessageTextarea = new KDInputView
      #type        : "textarea"
      #placeholder : "Commit message"
      
    #@leftView = new KDSplitView
      #cssClass    : "left-view"
      #type        : "horizontal"
      #resizable   : yes
      #sizes       : [ "75%", null ]
      #views       : [ @workingDirView, @stagedFilesView ]
      #
    #@rightView = new KDSplitView
      #cssClass    : "left-view"
      #type        : "horizontal"
      #resizable   : yes
      #sizes       : [ "75%", null ]
      #views       : [ @diffView, @kommitView ]
      #
    
    @navigationPane = new NavigationPane
    @fileDiffView   = new FileDiffView
    @repoTabView    = new RepoTabView
    
    @mainStage      = new KDSplitView
      cssClass    : "main-stage"
      type        : "horizontal"
      resizable   : yes
      sizes       : [ "30%", "70&" ]
      views       : [ @repoTabView, @fileDiffView ]
    
    @container.addSubView @baseView = new KDSplitView
      cssClass    : "base-view"
      type        : "vertical"
      resizable   : yes
      sizes       : [ "25%", null ]
      views       : [ @navigationPane, @mainStage ]
    
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
    newItem = new FileItem
      delegate : @
      path     : item.getOptions().path
      type     : "added"
      oldType  : initialType
      
    @stagedFilesView.addSubView newItem
    
  unstage: (item) ->
    @stagedFilesView.removeSubView item
    newItem = new FileItem
      delegate : @
      path     : item.getOptions().path
      type     : item.getOptions().oldType
      
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
          item = new FileItem
            delegate : @
            path     : file
            type     : fileList # TODO: naming confusion
            
          target =  if fileList == "added" then @stagedFilesView else @workingDirView
          target.addSubView item
    
  pistachio: -> """
    {{> @reposView}}
    {{> @container}}
  """ 