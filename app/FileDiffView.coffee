class FileDiffView extends JView
    
  constructor: (options = {}, data) ->
    
    options.cssClass = "diff-view"
    
    super options, data
    
    {@ace}      = @getOptions()
    
    @noDiffView = new KDView
      cssClass  : "no-diff-view"
      partial   : "Select a file to see its diff here."
    
    @diffView   = new KDCustomHTMLView
      tagName   : "pre"
      
    @on "ShowDiff", (diff) =>
      @noDiffView.hide()
      @diffView.updatePartial diff.replace(/^\+.*$/gm, '<span class=added>$&</span>')
      .replace(/^-.*$/gm, '<span class=removed>$&</span>')
      .replace(/^@.*$/gm, '<span class=line-numbers>$&</span>')
      .replace(/^([iI]ndex:?|diff --git) .*$/gim, '<span class=filename>$&</span>')
      
  pistachio: -> 
    """
      {{> @noDiffView}}
      {{> @diffView}}
    """