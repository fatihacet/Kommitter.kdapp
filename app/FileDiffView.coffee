class FileDiffView extends JView
    
  constructor: (options = {}, data) ->
    
    super options, data
    
    {@ace}      = @getOptions()
    
    @noDiffView = new KDView
      cssClass  : "no-diff-view"
      partial   : "Select a file to see its diff here."
    
    @diffView   = new KDView
      cssClass  : "diff-view"
      
  viewAppended: ->
    super
    
    @aceEditor = @ace.edit @diffView.domElement[0]
    @aceEditor.setTheme "ace/theme/monokai"
    @aceEditor.getSession().setMode "ace/mode/diff"
    @aceEditor.setReadOnly true
        
  pistachio: -> 
    """
      {{> @noDiffView}}
      {{> @diffView}}
    """