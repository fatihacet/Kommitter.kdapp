class KommitView extends JView
    
  constructor: (options = {}, data) ->
    
    options.cssClass = "kommit-view"
    
    super options, data
    
    @textarea     = new KDInputView
      type        : "textarea"
      placeholder : "Commit message"
      
    @commitButton = new KDButtonView
      cssClass    : "editor-button"
      title       : "Commit"
      callback    : @bound "kommit"
      
    @cancelButton = new KDButtonView
      cssClass    : "editor-button"
      title       : "Cancel"
      
  kommit: ->
    message = @textarea.getValue()
    
    if message then @getDelegate().emit "Kommit", message
    else new KDNotificationView
      title    : "Commit message cannot be empty."
      cssClass : "error"
      type     : "mini"
    
  pistachio: -> 
    """
      {{> @textarea}}
      <div class="buttons-container">
        {{> @cancelButton}}
        {{> @commitButton}}
      </div>
    """