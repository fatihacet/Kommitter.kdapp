class ReposView extends JView

  constructor: (options = {}, data) ->
    
    options.cssClass = "kommitter-repos-view"
    
    super options, data
    
    @findReposAndCreateRepoItems()
    
  getAppIcon: (appName) ->
    icons = @apps?[appName]?.icns
    if icons and (icon = icons["128"] or icons["160"] or icons["256"])
      #TODO: Use KD.config.userSitesDomain instead of koding.com
      icon = "https://#{nickname}.koding.com/.applications/#{appName.toLowerCase()}/#{icon.substring 1, icon.length}"
    return icon or ""
    
  findReposAndCreateRepoItems: ->
    command = """find -P . -maxdepth 4 -name ".git" -type d"""
    kiteController.run command, (err, repos) =>
      kodingAppsController.fetchApps (err, apps) =>
        @apps      = apps
        repoPaths  = repos.split "\n"
        itemConfig = { delegate: @getDelegate() }
        for repoPath in repoPaths when repoPath
          repoPath = repoPath.replace ".git", ""
          if repoPath.indexOf(".kdapp") > -1
            appName = FSHelper.getFileNameFromPath repoPath.substring 0, repoPath.length - 1
            appIcon = @getAppIcon appName.replace ".kdapp", ""
            itemConfig.appIcon = appIcon if appIcon
          @addSubView new RepoItem itemConfig, repoPath
