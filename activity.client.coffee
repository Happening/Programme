Db = require 'db'
Dom = require 'dom'
Form = require 'form'
Icon = require 'icon'
Server = require 'server'
Page = require 'page'
Plugin = require 'plugin'
Ui = require 'ui'
{tr} = require 'i18n'
TimeFormat = require 'timeFormat'

addActivityItem = (title, content, sep = true) !->
	Dom.div !->
		if title?
			Dom.p !->
				Dom.style margin: '10px 0px 10px 10px'
				Dom.text title
		if content?
			Dom.p !->
				Dom.style
					margin: '0px 10px 10px 0px'
					textAlign: 'right'
					clear: 'both'
					fontSize: '21px'
				Dom.text content
		if sep
			Form.sep()

exports.renderActivity = (name, items) !->
	key = Page.state.get("?key")
	item = items[key]
	Page.setTitle item.name
	Dom.style
		padding: "0px"
		backgroundColor: '#191919'
		color: '#bbb'
	Dom.css
		".form-sep":
			background: '#555'

	#big avatar of the activity
	if Db.shared.get(name.toLowerCase()) isnt "not found"
		Icon.render
			data: Db.shared.get(name.toLowerCase())
			size: 200
			content: !->
				Dom.style
					width: '100%'
					height: '150px'
					Box: 'bottom right'
					display: 'flex'
					backgroundPosition: '50% 30%'
					# min: '-8px 0px 0px 0px'
				Dom.div !->
					Dom.style
						padding: '2px 8px'
						boxSizing: 'border-box'
						Box: 'bottom right'
						height: '100%'
						width: '100%'
						background: 'linear-gradient(to top, rgba(0,0,0,0.55) 0%,rgba(0,0,0,0) 50px)'
						color: '#eee'
						fontSize: '24px'
						color: '#FFF'
						_boxShadow: (if item.shadowColor? then item.shadowColor else 'rgba(228, 64, 64, 0.4)') + ' 0px 2px 4px'
					Dom.text item.name
	else
		Dom.h1 !->
			Dom.style
				margin: "0px"
				padding: "8px 18px"
			Dom.userText item.name

	#info
	Dom.section !->
		Dom.style
			backgroundColor: '#222'
			border: 'none'
			margin: '0px'

		if item.description?
			addActivityItem(null, item.description, true)
		if item.start?
			addActivityItem(tr("Start time:"), TimeFormat.toDisplayTime(TimeFormat.toMinutes(item.start)), true)
		if item.duration? and item.start?
			addActivityItem(tr("End time:"), TimeFormat.toDisplayTime(TimeFormat.toMinutes(item.start)+item.duration), true)
		if item.location?
			addActivityItem(tr("Venue:"), item.location, false)

	#attendance
	Dom.section !->
		Dom.style
			backgroundColor: '#222'
			border: 'none'
			margin: '10px 0px 0px 0px'
			padding: '8px 18px'
		if at = Db.shared.get("attendance", name)
			Dom.text tr("Attending:")
			Dom.div !->
				Dom.css
					".ui-avatar":
						"margin": "4px !important" #very ugly to use !imporant.
				Dom.style
					# Box: "center"
					textAlign: 'center'
					padding: "8px 0px"
				for id in at
					Ui.avatar Plugin.userAvatar(id), size: 60, onTap: !->
						Plugin.userInfo id

		#Joining in button
		Dom.css
			".bar-foot":
				background: '#111'
		Page.setFooter label: !->
			ar = Db.shared.get "attendance", name
			if !ar?
				Dom.text tr("Join in!")
			else
				if Plugin.userId() in ar
					Dom.text tr("Don't go")
				else
					Dom.text tr("Join in!")
		, action: !->
			Server.sync 'join', name, !->
				value = Db.shared.get "attendance", name
				if value?
					if Plugin.userId() in value
						value.splice value.indexOf(Plugin.userId()), 1
					else
						value.push Plugin.userId()
					Db.shared.set "attendance", name, value
				else
					Db.shared.set "attendance", name, [Plugin.userId()]