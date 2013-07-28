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
      @diffView.updatePartial @createDiffMarkup @parseDiffToChunks diff
      
    @on "KommitDone", =>
      @diffView.updatePartial ""
      @noDiffView.show()
      
  parseDiffToChunks: (diff) ->
    lines   = diff.split "\n"
    meta    = lines.splice 0, 4
    chunks  = []
    
    for line in lines
      if line.indexOf("@@ ") is 0
          chunks.push [line]
      else
          chunks.last.push line
          
    return chunks
      
  lineClassMap:
    "@" : "chunk-title"
    "+" : "added-line"
    "-" : "deleted-line"
    " " : "regular-line"
    
  createDiffMarkup: (chunks) ->
    markup = """<table class="diff-table">"""
    
    for chunk in chunks
      firstLine        = chunk[0]
      lineInfo         = firstLine.split(/\s?@@\s?/)[1].split " "
      leftLineNumber   = Math.abs(parseInt(lineInfo[0]))
      rightLineNumber  = Math.abs(parseInt(lineInfo[1]))
      leftLineCounter  = 0
      rightLineCounter = 0
      
      for line in chunk
        lineClass        = @lineClassMap[line[0]]
        if lineClass  
          markup        += """<tr class="#{lineClass}">"""
          
          if lineClass is "chunk-title"
            markup += "<td>...</td><td>...</td><td>#{line}</td>"
          else if lineClass is "added-line"
            markup += "<td>&nbsp;</td><td>#{rightLineNumber++}</td><td>#{line}</td>"
          else if lineClass is "deleted-line"
            markup += "<td>#{leftLineNumber++}</td><td>&nbsp;</td><td>#{line}</td>"
          else 
            markup += "<td>#{leftLineNumber++}</td><td>#{rightLineNumber++}</td><td>#{line}</td>"
          
          markup += "</tr>"
        
    return markup
      
  pistachio: -> 
    """
      {{> @noDiffView}}
      {{> @diffView}}
    """
