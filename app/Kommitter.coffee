class Kommitter extends KDObject
  
  constructor: (options, data) ->
    
    super options, data
    
    @repoPath  = @getData()
    @statusObj = @getNewStatusObj()
    @staged    = []
    
    @on "stage", (item) =>
      @staged.push item.getOptions().path
      
    @on "unstage", (item) =>
      @staged.splice @staged.indexOf(item.getOptions().path), 1
      
    @on "Diff", (path) =>
      @doKiteRequest "cd #{@repoPath} ; git diff #{path}", (res) =>
        @getDelegate().emit "ShowDiff", res
        
    @on "kommit", (message) =>
      commitedFiles = @staged.join " "
      if commitedFiles.length is 0
        new KDNotificationView
          title    : "No file staged to commit!"
          cssClass : "error"
          type     : "mini"
        return no
      
      commitText   = "git commit -m #{message} #{commitedFiles}"
      
      @doKiteRequest "cd #{@repoPath} ; #{commitText}", (res) =>
        # TODO: Error check
        new KDNotificationView
          type     : "mini"
          title    : res.split("\n")[1]
          duration : 5000
        
        @delegate.emit "Kommitted", @staged
        @staged.length = 0
      
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
    
  getStatus: =>
    @doKiteRequest "cd #{FSHelper.escapeFilePath @repoPath.replace "./", ""} ; git branch ; git status -s", (res) =>
      @parseOutput res
      @getDelegate().emit "status", @statusObj
      
  fetchLog: ->
    command = """git log --pretty=format:'{ "id": "%H", "name": "%an", "email": "%ae", "date": "%ad", "message": "%s"}' --max-count=20"""
    @doKiteRequest "cd #{@repoPath} ; #{command}", (res) =>
      parsed = res.split("\n").join(",")
      gitLog = JSON.parse "[#{parsed}]"
      @getDelegate().emit "GitLogFetched", gitLog
      
  statusKeys  : 
    branch    : "* "
    modified  : " M"
    added     : "A "
    deleted   : " D"
    untracked : "??"
  
  parseOutput: (res) ->
    results = res.split "\n"
    keys    = @statusKeys;
    
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
  