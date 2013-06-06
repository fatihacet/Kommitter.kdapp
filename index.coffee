baseView = new BaseView
appView.addSubView baseView

eventNameMap = 
  changeRepo : "ChangeRepo"
  refresh    : "Refresh"
  pull       : "NotImplementedYet"
  kommit     : "ShowKommitDialog"
  push       : "NotImplementedYet"
  saveStash  : "NotImplementedYet"
  applyStash : "NotImplementedYet"
  about      : "ShowAbout"
  exit       : "Exit"

for eventKey, eventName of eventNameMap
  do (eventKey, eventName) => 
    appView.on "#{eventKey}MenuItemClicked", (menuItem) =>
      isRepoSelected = baseView.isARepoSelected()
      isRepoRequired = not (menuItem is "exit" or menuItem is "about")
      if not isRepoSelected and isRepoRequired
        return baseView.emit "NoRepoSelected" 
      baseView.emit eventName
