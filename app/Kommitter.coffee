class Kommitter extends KDObject
  
  constructor: (repoPath, parent) ->
    
    super 
    
    @delegate  = parent
    @repoPath  = repoPath
    @statusObj = @getNewStatusObj()
    @staged    = [];
    
    
    @on "stage", (item) =>
      @staged.push item.getOptions().path
      
      
    @on "unstage", (item) =>
      @staged.splice @staged.indexOf(item.getOptions().path), 1
      
      
    @on "diff", (path) =>
      @doKiteRequest "cd #{@repoPath} ; git diff #{path}", (res) =>
        @aceEditor = @delegate.ace.edit @delegate.diffView.domElement[0]
        @aceEditor.setTheme "ace/theme/monokai"
        @aceEditor.getSession().setMode "ace/mode/diff"
        @aceEditor.setReadOnly true
        @aceEditor.getSession().setValue res
        
        
    @on "commit", (message) =>
      commitedFiles = @staged.join " "
      if commitedFiles.length is 0
        new KDNotificationView
          title    : "No file staged to commit!"
          cssClass : "error"
          type     : "mini"
        return no
      
      commitText    = "git commit -m #{message} #{commitedFiles}"
      
      @doKiteRequest "cd #{@repoPath} ; #{commitText}", (res) =>
        # TODO: Error check
        new KDNotificationView
          type     : "mini"
          title    : res.split("\n")[1]
          duration : 5000
        
        @delegate.emit "kommitted"
      
    
    @on "push", =>
      @doKiteRequest "cd #{@repoPath} ; git push", (res) =>
        # handle response
        
        
    @on "refresh", =>
      @statusObj = @getNewStatusObj()
      @aceEditor?.getSession().setValue ""
      @getStatus()
        
    
    @getStatus()
  
  
  getNewStatusObj : ->
    branch        : []
    modified      : []
    added         : []
    deleted       : []
    untracked     : []
    
  
  getStatus: (repoPath) =>
    @doKiteRequest "cd #{FSHelper.escapeFilePath @repoPath} ; git branch ; git status -s", (res) =>
      @parseOutput res
      @getDelegate().emit "status", @statusObj
      
  
  statusKeys  : 
    branch    : "* "
    modified  : " M"
    added     : "A "
    deleted   : " D"
    untracked : "??"
  
  
  parseOutput: (res) ->
    results = res.split "\n"
    keys = @statusKeys;
    
    for result in results
      for key of @statusKeys
        currentKey = @statusKeys[key]
        if result.indexOf(currentKey) is 0
          @statusObj[key].push result.split(currentKey)[1]

  
  doKiteRequest: (command, callback) ->
    KD.getSingleton('kiteController').run command, (err, res) =>
      unless err
        callback(res) if callback
      else 
        new KDNotificationView
          title    : "An error occured while processing your request, please try again!",
          type     : "mini"
          cssClass : "error"
          duration : 3000
  