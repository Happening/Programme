#Programming plug-in for events.
Db = require 'db'
Dom = require 'dom'
Form = require 'form'
Icon = require 'icon'
Server = require 'server'
Page = require 'page'
Plugin = require 'plugin'
Obs = require 'obs'
Ui = require 'ui'
{tr} = require 'i18n'
Overview = require 'overview'
Activity = require 'activity'
dag1 = require 'vrijdag'
dag2 = require 'zaterdag'
dag3 = require 'zondag'

days = ["Vrijdag", "Zaterdag", "Zondag"]#, "Monday", "Someday", "Tomorrow"]
startTimes = [1200, 1000, 1000]
endTimes = [2800, 2800, 2800]

threads = ["Alpha", "Heineken", "India", "Bravo", "Lima", "Juliet", "X-ray", "Echo", "Charlie", "Romeo", "WatchDoc", "Oh Mega!"]

#start time goes in time notation without the ':', duration in minutes
items = (dag1.dag().concat dag2.dag()).concat(dag3.dag())

# Initial entry point
exports.render = !->
	#highlight on dark brackground fix
	Dom.css !->
		".tap":
			backgroundColor: "255, 255, 255)"

	if arg = Page.state.get(0)
		return Activity.renderActivity(arg, items)
	else
		return Overview.renderOverview(items, threads, days, startTimes, endTimes)