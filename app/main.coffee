KD.enableLogs()
{nickname}           = KD.whoami().profile
kodingAppsController = KD.getSingleton "kodingAppsController"
kiteController       = KD.getSingleton "kiteController"
kodingAppManager     = KD.getSingleton "appManager"


#TEMP FIX FOR STYLING
$("#k-link").remove()
link = $ """<link id="k-link" type="text/css" rel="stylesheet" href="https://fatihacet.koding.com/.applications/kommitter/resources/style.css" />"""
$("head").append link