Db = require 'db'
Dom = require 'dom'
Event = require 'event'
Form = require 'form'
Icon = require 'icon'
Server = require 'server'
Social = require 'social'
Obs = require 'obs'
Page = require 'page'
Plugin = require 'plugin'
Ui = require 'ui'
{tr} = require 'i18n'
TimeFormat = require 'timeFormat'

exports.renderActivity = (key, items) !->
	# key = Page.state.get("?key")
	# key = Page.state.get(0)
	item = items[key]
	name = item.name
	Page.setTitle item.name
	if Page.setBackgroundColor then Page.setBackgroundColor '#191919'
	Event.showStar tr(item.name)
	Dom.style
		padding: "0px"
		# backgroundColor: '#191919'
		color: '#bbb'
	Dom.css
		".form-sep":
			background: '#555'

	#big avatar of the activity
	if item.bigImg
		imgUrl = item.bigImg
	else
		if item.smallImg
			imgUrl = item.smallImg
		else
			imgUrl = Db.shared.get(name.toLowerCase())

	if imgUrl isnt "not found"
		Icon.render
			data: imgUrl
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
						padding: '2px 18px'
						boxSizing: 'border-box'
						Box: 'bottom right'
						height: '100%'
						width: '100%'
						background: 'linear-gradient(to top, rgba(0,0,0,0.55) 0%,rgba(0,0,0,0) 50px)'
						color: '#eee'
						fontSize: '24px'
						textAlign: 'right'
						_boxShadow: (if item.color? then item.color else 'rgba(228, 64, 64, 0.4)') + ' 0px 2px 4px'
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

		highlight = (text) ->
			Dom.span !->
				Dom.style color: Plugin.colors().highlight
				Dom.userText text


		Dom.p !->
			Dom.style
				margin: '10px 10px 15px 10px'
				textAlign: "center"
				clear: 'both'
				fontSize: 21 + 'px'
			
			highlight item.day
			Dom.text tr(" from ")
			highlight TimeFormat.toDisplayTime(TimeFormat.toMinutes(item.start))
			Dom.text tr(" till ")
			highlight TimeFormat.toDisplayTime(TimeFormat.toMinutes(item.start)+item.duration)
			Dom.text tr(" at ")
			highlight item.location

		Form.sep()

		if item.description?
			Dom.div !->
				Dom.style
					margin: '10px 10px 10px 10px'
					clear: 'both'
					fontSize: '17px'
				Dom.userText item.description

	#attendance
	if at = Db.shared.get("attendance", name)
		Dom.section !->
			Dom.style
				backgroundColor: '#222'
				border: 'none'
				margin: '10px 0px 0px 0px'
				padding: '8px 18px'				
				Dom.text tr("Attending:")
				Dom.div !->
					Dom.style
						textAlign: 'center'
						padding: "8px 0px"
					if at.length
						at.forEach (id) !->
							Dom.div !->
								Dom.style
									width: '62px'
									height: '62px'
									# margin: '20px'
									padding: '10px'
									borderRadius: '50%'
									display: 'inline-block'
								Ui.avatar Plugin.userAvatar(id), size: 60
								Dom.onTap !->
									Plugin.userInfo id
			# 		else
			# 			Dom.text tr("No one attending yet...")
			# else
			# 	Dom.text tr("No one attending yet...")
		#Joining in button
		# footerAction = !->
		# 	Server.sync 'join', name, !->
		# 		value = Db.shared.get "attendance", name
		# 		if value?
		# 			if Plugin.userId() in value
		# 				value.splice value.indexOf(Plugin.userId()), 1
		# 			else
		# 				value.push Plugin.userId()
		# 			Db.shared.set "attendance", name, value
		# 		else
		# 			Db.shared.set "attendance", name, [Plugin.userId()]
		# Obs.observe !->
		# 	ar = Db.shared.get "attendance", name
		# 	lorum = "lorum ipsum dolorus mit. En wat meer latijnse woorden diet ik niet ken."
		# 	# lorum = " o/"
		# 	if !ar?
		# 		log Page.setFooter label: tr("Join in!" + lorum), action: footerAction
		# 	else
		# 		if Plugin.userId() in ar
		# 			log Page.setFooter label: tr("Don't go"+ lorum), action: footerAction
		# 		else
		# 			log Page.setFooter label: tr("Join in!")+ lorum, action: footerAction

	Page.setFooter label: !->
		ar = Db.shared.get "attendance", name
		if !ar? or Plugin.userId() not in ar
			Dom.text tr("Count me in!")
		else
			Dom.text tr("Count me out...")
	, action: !->
		Server.sync 'join', name, !->
			value = Db.shared.get "attendance", name
			if value?
				if Plugin.userId() in value
					value.splice value.indexOf(Plugin.userId()), 1
					# Event.subscribe item.key
				else
					value.push Plugin.userId()
				Db.shared.set "attendance", name, value
			else
				Db.shared.set "attendance", name, [Plugin.userId()]

	#comments with some restyling
	Dom.section !->
		Social.renderComments key
		Dom.style
			backgroundColor: 'transparent'
			border: '0px'
			margin: '0px'
			paddingBottom: '0px'
			_boxShadow: "none"
		Dom.css
			"section section":
				backgroundColor: '#333'
				border: "1px solid #444"
				_boxShadow: 'none'