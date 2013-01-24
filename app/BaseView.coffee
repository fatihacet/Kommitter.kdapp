KD.enableLogs(); #TODO: Remove line

class BaseView extends JView
  constructor: (options = {}) ->
    @ace = options.ace
    options.cssClass = "kommitter-app"
    
    super options
    
    @branchName = new KDView
      cssClass : "kommitter-branch-name"
      partial  : "Current branch: ... "
      
      
    @workingDirView = new KDView
      
      
    @stagedFilesView = new KDView
      
      
    @diffView = new KDView
      
    
    buttonsView = new KDView
    
    
    buttonsView.addSubView @commitButton = new KDButtonView
      title    : "Commit"
      callback : =>
        @commit()
    
    
    buttonsView.addSubView @pushButton = new KDButtonView
      title    : "Push"
      callback : =>
        @push()
        
    
    buttonsView.addSubView @refreshButton = new KDButtonView
      title    : "Refresh"
      callback : =>
        @refresh()
      
    
    @kommitMessageTextarea = new KDInputView
      type        : "textarea"
      placeholder : "Commit message"
    
    
    @kommitView = new KDSplitView
      type        : "vertical"
      resizable   : no
      sizes       : [ 100, null ]
      views       : [ buttonsView, @kommitMessageTextarea ]
      
      
    @leftView = new KDSplitView
      cssClass    : "left-view"
      type        : "horizontal"
      resizable   : yes
      sizes       : [ "75%", null ]
      views       : [ @workingDirView, @stagedFilesView ]
      
      
    @rightView = new KDSplitView
      cssClass    : "left-view"
      type        : "horizontal"
      resizable   : yes
      sizes       : [ "75%", null ]
      views       : [ @diffView, @kommitView ]
      
      
    @baseView = new KDSplitView
      cssClass    : "base-view"
      type        : "vertical"
      resizable   : yes
      sizes       : [ "25%", null ]
      views       : [ @leftView, @rightView ]
    
    
    @kommitter = new Kommitter "Applications/Kommitter.kdapp", @ # TODO: Passing @ as an argument ?
    
    
    @on "status", (res) =>
      @updateBranchName res.branch[0]
      delete res.branch # TODO: Remove that line
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

        
  updateBranchName: (branchName) ->
    @branchName.updatePartial "Current branch: #{branchName}"   
  
  
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
    {{> @branchName }}
    {{> @baseView }}
  """ 