baseView = new BaseView
appView.addSubView baseView

appView.on "kommitMenuItemClicked", => 
  baseView.emit "ShowKommitDialog"