baseView = new BaseView
appView.addSubView baseView

appView.on "kommitMenuItemClicked", => 
  debugger
  baseView.emit "ShowKommitDialog"