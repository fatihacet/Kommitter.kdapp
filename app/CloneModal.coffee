class CloneModal extends KDObject
  
  constructor: (options = {}, data) ->
    
    super options, data
    
    @getDelegate().addSubView saveDialog = new KDDialogView
      cssClass         : "save-as-dialog"
      duration         : 200
      topOffset        : 0
      overlay          : yes
      height           : "auto"
      buttons          :
        Save           :
          style        : "modal-clean-gray"
          callback     : =>
            notification = new KDNotificationView
              title    : "Cloning repository..."
              type     : "mini"
              duration : 20000
              
            [node] = @finderController.treeController.selectedNodes
            name   = @inputFileName.getValue()
    
            return warn "Please select a folder to clone!" unless node
            
            saveDialog.hide()
            @utils.wait 300, => # temp fix to be sure overlay has removed with fade out animation
              path = FSHelper.plainPath node.getData().path
              Kommitter.klone path, name, (err, res) ->
                if err
                  notification.notificationSetTitle "An error occured. Please try again..."
                  notification.notificationSetTimer 4000
                  notification.setClass "error"
                else
                  notification.notificationSetTitle "Your repo has been cloned."
                  notification.notificationSetTimer 4000
                  notification.setClass "success"
        Cancel      :
          style     : "modal-cancel"
          callback  : =>
            @finderController.stopAllWatchers()
            delete @finderController
            saveDialog.hide()
    
    saveDialog.addSubView wrapper = new KDView
      cssClass : "kddialog-wrapper"
    
    wrapper.addSubView form = new KDFormView
    
    form.addSubView labelFileName = new KDLabelView
      title : "Repo URL:"
    
    form.addSubView @inputFileName = inputFileName = new KDInputView
      label        : labelFileName
      placeholder  : "Enter the Git repo URL"
    
    form.addSubView labelFinder = new KDLabelView
      title : "Select a folder to clone:"
    
    saveDialog.show()
    inputFileName.setFocus()
    
    @finderController = new NFinderController
      nodeIdPath        : "path"
      nodeParentIdPath  : "parentPath"
      foldersOnly       : yes
      contextMenu       : no
      loadFilesOnInit   : yes
    
    finder = @finderController.getView()
    @finderController.reset()
    
    form.addSubView finderWrapper = new KDView cssClass : "save-as-dialog file-container",null
    finderWrapper.addSubView finder
    finderWrapper.setHeight 200
