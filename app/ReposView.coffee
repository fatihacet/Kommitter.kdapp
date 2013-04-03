KD.enableLogs(); #TODO: Remove line
{nickname} = KD.whoami().profile

class ReposView extends JView

  constructor: (options = {}, data) ->
    
    options.cssClass = "kommitter-repos-view"
    
    super options, data
    
    @findReposAndCreateRepoItems()
    
  findReposAndCreateRepoItems: ->
    KD.getSingleton("kiteController").run """find -P "/Users/#{nickname}/Applications/" -maxdepth 4 -name ".git" -type d""", (err, res) =>
      lines = res.split "\n"
      @addSubView new RepoItem { delegate: @getDelegate() }, line.replace ".git", "" for line in lines when line
    
    
class RepoItem extends JView 
  
  constructor: (options = {}, data) ->
    
    options.cssClass = "kommitter-repo-item"
    
    super options, data
    
  click: ->
    baseView = @getDelegate()
    baseView.setData @getData()
    baseView.initialize()
    
  pistachio: ->
    data  = @getData()
    words = data.split("/")
    name  = words[words.length - 2]
    """
      <img class="kommitter-repo-icon" src="https://app.koding.com/gokmen/Sample/0.1.1/resources/icon.128.png" />
      <span class="kommitter-repo-name">#{name}</span>
      <span class="kommitter-repo-path">#{data}</span>
    """