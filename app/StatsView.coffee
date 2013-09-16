class StatsView extends JView
  
  constructor: (options, data) ->
    
    super options, data
    
    @warningText    = new KDCustomHTMLView
      tagName       : "p"
      partial       : "Generating repo stats may take a few minutes due to size of the repo."
      
    @generateButton = new KDButtonView
      title         : "Generate Stats"
      cssClass      : "cupid-green"
      callback      : => @getDelegate().kommitter.generateRepoStats @
      
  pistachio: ->
    """
      {{> @warningText}}
      {{> @generateButton}}
    """