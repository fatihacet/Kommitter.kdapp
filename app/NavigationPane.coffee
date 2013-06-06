class NavigationPane extends JView
    
  constructor: (options = {}, data) ->
    
    options.cssClass = "navigation-pane"
    
    super options, data
    
    @branches  = new KDView
      cssClass : "nav-item"
      partial  : "BRANCHES"
      
    @branches.addSubView @branchName = new KDView
      cssClass : "branch-item"
      partial  : ""
      
    @remotes   = new KDView
      cssClass : "nav-item"
      partial  : "REMOTES"
      tooltip  : 
        title  : "Remotes will be added soon!"
      
    @stashes   = new KDView
      cssClass : "nav-item"
      partial  : "STASHES"
      tooltip  : 
        title  : "Stashes will be added soon!"
        
    @on "UpdateBranchList", (list) ->
      @branchName.updatePartial "#{list} (HEAD)"
        
  pistachio: -> 
    """
      {{> @branches}}
      {{> @remotes}}
      {{> @stashes}}
    """