class LogItem extends JView

  constructor: (options = {}, data) ->
  
    options.cssClass = "kommit-log-item"
    
    super options, data
    
    @avatar      = new KDCustomHTMLView
      tagName    : "img"
      bind       : "error"
      attributes : 
        src      : "https://gravatar.com/avatar/#{md5.digest data.email}?s=50"
      error     : =>
        @avatar.getDomElement().attr "src", "http://www.gravatar.com/avatar/?d=mm&s=50"
        
    @on "click", => @emit "LogItemClicked"
  
  pistachio: ->
    data = @getData()
    @age = new KDTimeAgoView {}, data.date
    """
      <div class="user-avatar">{{> @avatar}}</div>
      <div class="message">#{data.message}</div>
      <div class="user-details">#{data.name}<span class="user-email">&lt;#{data.email}&gt;</span> authored {{> @age}}</div>
      <div class="id">#{data.id}</div>
    """
