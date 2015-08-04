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

halfHourWidth = 60 #in pixels
rowHeight = 60 #in pixels
marginLeft = 8 #in pixels #80
locationHeight = 8 #in pixels
startTime = 540 #in minuts

threads = ["Alpha", "Beta", "Gamma"]#, "4", "5", "6", "7"]

#start time goes in time notation without the ':', duration in minutes
items = [
		{
			key: 0
			name: "Muse"
			location: 'Alpha'
			start: "1000"
			duration: 120
			description: "Muse are an English rock band from Teignmouth, Devon, formed in 1994. The band consists of Matthew Bellamy, Christopher Wolstenholme and Dominic Howard. They are known for their energetic live performances."
			shadowColor: "rgba(199,	199, 199, 0.4)"
		}
		{
			key: 1
			name: "Foo Fighters"
			location: 'Alpha'
			start: "1230"
			duration: 150
			description: "Foo Fighters is an American rock band, formed in Seattle in 1994. It was founded by Nirvana drummer Dave Grohl as a one-man project following the death of Kurt Cobain and the resulting dissolution of his previous band."
			shadowColor: "rgba(175,	65, 73, 0.4)"
		}
		{
			key: 2
			name: "Mumford & Sons"
			location: 'Beta'
			start: "1015"
			duration: 45
			description: "Mumford & Sons are a British rock band from London, formed in 2007. The band consists of Marcus Mumford, Ben Lovett, Winston Marshall and Ted Dwane. Mumford & Sons have released three studio albums: Sigh No More, Babel and Wilder Mind."
			shadowColor: "rgba(140,	171, 162, 0.4)"
		}
		{
			key: 3
			name: "The Prodigy"
			location: 'Beta'
			start: "1115"
			duration: 90
			description: "The Prodigy are an English electronic dance music group from Braintree, Essex, formed by Liam Howlett in 1990. The current members include Liam Howlett, Keith Flint and Maxim."
			shadowColor: "rgba(186,	184, 183, 0.4)"
		}
		{
			key: 4
			name: "Seasick Steve"
			location: 'Beta'
			start: "1300"
			duration: 60
			description: "Steven Gene Wold, commonly known as Seasick Steve, is an American blues musician. He plays mostly personalized guitars, and sings, usually about his early life doing casual work."
			shadowColor: "rgba(200,	148, 89, 0.4)"
		}
		{
			key: 5
			name: "Unknown Artist"
			location: 'Beta'
			start: "1500"
			duration: 60}
		{
			key: 6
			name: "Ayreon"
			location: 'Gamma'
			start: "0930"
			duration: 45
			description: "Ayreon /ˈɛriən/ is a musical project by Dutch songwriter, singer, multi-instrumentalist musician and record producer Arjen Anthony Lucassen."
			shadowColor: "rgba(226,	178, 188, 0.4)"
		}
		{
			key: 7
			name: "Caravan Palace"
			location: 'Gamma'
			start: "1030"
			duration: 45
			description: "Caravan Palace is a French electro swing band based in Paris. The band's influences include Django Reinhardt, Vitalic, Lionel Hampton, and Daft Punk. The band released their début studio album, Caravan Palace, on the Wagram label in October 2008."
			shadowColor: "rgba(184,	132, 100, 0.4)"
		}
	]

#responsive
rowHeight = Math.min(150, Math.max(rowHeight, (Page.height()-140-(threads.length*locationHeight))/threads.length))
contentHeight = Math.max(Page.height()-130, threads.length*(rowHeight+locationHeight)+12)+27

#e9e9e9
# itunes.apple.com/search?term=muse&entity=album&limit=1
# https://api.spotify.com/v1/search?q=muse&type=artist&limit=1

toHourFractal = (t) ->
	t = String t
	h = parseInt t.substring(0,2)
	m = parseInt t.substring(2,4)
	h+m/60

toMinutes = (t) ->
	t = String t
	h = parseInt t.substring(0,2)
	m = parseInt t.substring(2,4)
	h*60+m

toDisplayTime = (t) ->
	h = Math.floor(t/60)
	m = t%60
	h + ":" + (m||"00")

addTime = (time) ->
	Dom.li !->
		Dom.style
			width: halfHourWidth + "px"
			padding: '4px'
			boxSizing: 'border-box'
			background: '#222' if (time%60 isnt 0) 
			height: '100%'
		Dom.text Math.floor(time/60) + ":" + if (time%60) then (time%60) else "00"

addThread = (name) ->
	Dom.li !->
		# Dom.style
		# 	minWidth: '70px'
		# 	height: (rowHeight-8) + 'px'
		# 	padding: '8px'
		# 	margin: '0px 0px 8px 0px'
		# 	fontSize: '130%'
		# 	boxSizing: 'border-box'
		# 	background: '#fff'
		# 	Box: 'middle right'
		# 	_boxShadow: 'rgba(0, 0, 0, 0.4) 0px 1px 3px'
		Dom.style
			fontSize: '80%'
			height: (rowHeight) + 'px'
			padding: '4px'
			# boxSizing: 'border-box'

		Dom.text name + ":"

addItem = (item) ->
	Dom.li !->
		imgUrl = Db.shared.get item.name.toLowerCase()
		# imgUrl = "not found"
		log imgUrl
		if !imgUrl?
			Server.call "getCover", item.name.toLowerCase()
		Dom.style
			position: 'absolute'
			left: ((toHourFractal(item.start)*halfHourWidth*2) - (startTime/30*halfHourWidth)) + "px"
			top: threads.indexOf(item.location)*(rowHeight+locationHeight)+locationHeight+14 + 'px'
			width: item.duration/30*halfHourWidth + "px"
			height: rowHeight-16 + 'px'
			backgroundColor: '#666'
			backgroundImage: 'url("' + imgUrl + '")' if imgUrl isnt "not found"
			backgroundSize: 'cover'
			backgroundPosition: 'center 30%'
			boxSizing: 'border-box'
			_boxShadow: (if item.shadowColor? then item.shadowColor else 'rgba(228, 64, 64, 0.4)') + ' 0px 2px 4px'
			padding: '0px'
		Dom.div !->
			Dom.style
				overflow: 'hidden'
				padding: '2px 8px'
				boxSizing: 'border-box'
				Box: 'bottom'
				height: '100%'
				width: '100%'
				background: 'linear-gradient(to top, rgba(0,0,0,0.7) 0%,rgba(0,0,0,0) 50px)'
				color: '#eee'
				_whiteSpace: 'nowrap'
			Dom.text item.name
		if at = Db.shared.get("attendance", item.name)
			Ui.unread at.length, Plugin.colors().highlight,
				position: "absolute"
				top: '5px'
				right: '-10px'
		Dom.onTap !->
			Page.nav {0:item.name, "?key": item.key}

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

# Initial entry point
exports.render = !->
	if arg = Page.state.get(0)
		return renderActivity(arg)
	else
		return renderOverview()


renderActivity = (name) !->
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
			addActivityItem(tr("Start time:"), toDisplayTime(toMinutes(item.start)), true)
		if item.duration? and item.start?
			addActivityItem(tr("End time:"), toDisplayTime(toMinutes(item.start)+item.duration), true)
		if item.location?
			addActivityItem(tr("Venue:"), item.location, false)

	#attendance
	Dom.section !->
		Dom.style
			backgroundColor: '#222'
			border: 'none'
			margin: '10px 0px 0px 0px'
			padding: '8px 18px'
		Obs.observe
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

renderOverview = !->
	
	scrollE = null
	#overview
	Dom.style
		overflowX: 'visible'
		overflowY: 'auto'
		padding: '0px'
		color: '#bbb'
		background: '#191919'
		_userSelect: 'none'
		height: '100%'
		display: 'flex'
	Dom.ul !-> #thread legend
		Dom.style
			zIndex: 50;
			listStyle: 'none'
			padding: 0	
			Box: 'vertical'
			position: 'absolute'
			top: '27px'
			margin: "0px"
		addThread t for t in threads
	Dom.div !-> #body
		Dom.style
			overflowY: 'auto'
			overflowX: 'visible'
			boxSizing: 'border-box'
			height: contentHeight

		scrollE = Dom.get()	

		Dom.div !-> #time legend
			Dom.style
				margin: '0px'
				listStyle: 'none'
				padding: 0
				Box: 'left'
				width: (29*halfHourWidth+marginLeft) + 'px'
				height: '100%'
				marginLeft: marginLeft
				position: 'relative'
			addTime i*30+startTime for i in [0..28]
			Dom.div !-> #content
				Dom.style
					position: 'absolute'
					left: '0px'
					top: '25px'

				Form.sep()
				Dom.div !-> #items
					Dom.style
						listStyle: 'none'
						margin: '0px'
						padding: '8px'
						position: 'relative'
					addItem item for item in items
	
	#scroll to the position where we left it	
	scrollE.prop("scrollLeft", Page.state.get("_scroll")||0)		
	
	Page.onNavClean (prev) !->
		if scrollE.prop("scrollLeft")
			prev._scroll = scrollE.prop("scrollLeft")
			
