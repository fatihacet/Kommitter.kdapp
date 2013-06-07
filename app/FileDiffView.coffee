class FileDiffView extends JView
    
  constructor: (options = {}, data) ->
    
    options.cssClass = "diff-view"
    
    super options, data
    
    @noDiffView = new KDView
      cssClass  : "no-diff-view"
      partial   : "Select a file to see its diff here."
    
    @diffView   = new KDCustomHTMLView
      tagName   : "pre"
      
    @diffView.hide()
      
    @on "ShowDiff", (diff) =>
      @noDiffView.hide()
      @diffView.show()
      @diffView.updatePartial diff.replace(/\>/g, "&gt;")
                                  .replace(/\</g, "&lt;")
                                  .replace(/^\+.*$/gm, '<span class=added>$&</span>')
                                  .replace(/^-.*$/gm, '<span class=removed>$&</span>')
                                  .replace(/^@.*$/gm, '<span class=line-numbers>$&</span>')
                                  .replace(/^([iI]ndex:?|diff --git) .*$/gim, '<span class=filename>$&</span>')
      
    @on "KommitDone", =>
      @diffView.updatePartial ""
      @noDiffView.show()
      
  pistachio: -> 
    """
      {{> @noDiffView}}
      {{> @diffView}}
    """