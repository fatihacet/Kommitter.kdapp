class TerminalView extends JView
    
  constructor: (options = {}, data) ->
    
    options.cssClass = "terminal-view"
    
    super options, data
    
    @terminal = new WebTermView
      delegate : @
      cssClass : "webterm"
      
    @terminal.on "WebTermConnected", (@remote)=>
      {command} = @getOptions()
      @runCommand command if command
      @setClass "active"
      
  runCommand: (command) ->
    return unless command 
    return @remote.input "#{command}\n" if @remote
    
    if not @remote and not @triedAgain
      @utils.wait 2000, =>
        @runCommand command
        @triedAgain = yes
        
  pistachio: -> 
    """
      {{> @terminal}}
    """