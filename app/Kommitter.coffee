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
      
    @on "Diff", (meta, isHash) =>
      meta = "#{meta}^!"  if isHash
      @doKiteRequest "cd #{@repoPath} ; git diff #{meta}", (res) =>
        @getDelegate().emit "ShowDiff", res
        
    @on "GetFileContent", (path) =>
      file = FSHelper.createFileFromPath """#{@repoPath}#{path.replace /^ /, ""}"""
      file.fetchContents (err, res) =>
        return if err
        @getDelegate().emit "ShowFileContent", res
        
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
      
    @on "Push", =>
      kiteController.run "cd #{@repoPath} ; git push", (err, res) =>
        if err
          return @kiteNotify() unless res
          if res.indexOf("Permission denied (publickey)") > -1
            @showPublicKeyWarning()
          else
            @kiteNotify()
        else
          @getDelegate().notify "Pushed successfully!", 3000, "success"
        
    @on "Refresh", =>
      @statusObj = @getNewStatusObj()
      @getStatus()
      
    @on "FetchLog", =>
      @fetchLog()
      
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
      @getDelegate().emit "Status", @statusObj
      
  fetchLog: ->
    command = """git log --pretty=format:'{ "id": "%h", "name": "%an", "email": "%ae", "date": "%ad", "message": "%s"}' --max-count=20"""
    @doKiteRequest "cd #{@repoPath} ; #{command}", (res) =>
      parsed = res.split("\n").join(",")
      gitLog = JSON.parse "[#{parsed}]"
      @getDelegate().emit "LogFetched", gitLog
      
  statusKeys  : 
    "* " : "branch"
    " M" : "modified"
    "A " : "added"
    " D" : "deleted"
    "??" : "untracked"
  
  parseOutput: (res) ->
    lines = res.split "\n"
    
    for line in lines
      key   = line.substring 0, 2
      value = line.substring 2, line.length
      label = @statusKeys[key]
      @statusObj[label].push value  if label
  
  doKiteRequest: (command, callback) ->
    kiteController.run command, (err, res) =>
      unless err
        callback(res) if callback
      else 
        @kiteNotify()
        
  showPublicKeyWarning: ->
    modal      = new KDModalView
      title    : "Access Denied"
      cssClass : "access-denied-modal"
      overlay  : yes
      width    : 400 
      content  : 
        """
          <p>It seems like your ssh key is password protected.
          Kommitter app cannot work with password protected keys.</p>
          <p>You can push manually or click "Open Terminal" button to enter your password to push.</p>
        """
      buttons  :
        "Open Terminal" :
          style         : "modal-clean-green"
          callback      : => 
            @getDelegate().sendCommandToTerminal "cd #{@repoPath} ; git push"
            modal.destroy()
        "Close"         :
          style         : "modal-clean-gray"
          callback      : -> modal.destroy()
  
  kiteNotify: ->
    new KDNotificationView
      title    : "An error occured while processing your request, please try again!",
      type     : "mini"
      cssClass : "error"
      duration : 3000