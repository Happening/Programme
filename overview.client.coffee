Db = require 'db'
Dom = require 'dom'
Form = require 'form'
Server = require 'server'
Obs = require 'obs'
Page = require 'page'
Plugin = require 'plugin'
Ui = require 'ui'
{tr} = require 'i18n'
TimeFormat = require 'timeFormat'

halfHourWidth = 60 #in pixels
rowHeight = 60 #in pixels
marginLeft = 8 #in pixels #80
locationHeight = 8 #in pixels
startTime = 540 #in minuts

scrollE = null

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
			# height: (rowHeight) + 'px'
			height: '20px'
			marginBottom: (rowHeight-20) + 'px'
			padding: '4px'
			# boxSizing: 'border-box'

		Dom.text name + ":"

addItem = (item, index) ->
	Dom.li !->
		imgUrl = Db.shared.get item.name.toLowerCase()
		# imgUrl = "not found"
		if !imgUrl?
			Server.call "getCover", item.name.toLowerCase()
		Dom.style
			position: 'absolute'
			left: ((TimeFormat.toHourFractal(item.start)*halfHourWidth*2) - (startTime/30*halfHourWidth)) + "px"
			top: index*(rowHeight+locationHeight)+locationHeight+14 + 'px'
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

exports.renderOverview = (items, threads, days) ->
	#responsive
	rowHeight = Math.min(150, Math.max(rowHeight, (Page.height()-140-(threads.length*locationHeight))/threads.length))
	contentHeight = Math.max(Page.height()-130, threads.length*(rowHeight+locationHeight)+12)+27

	#title
	if !Db.local.peek("day")? then Db.local.set("day", days[0])
	Obs.observe !->
		Page.setTitle Db.local.get("day")

	Dom.style
		Box: "vertical"
		height: "100%"
		padding: '0px'
		background: '#191919'

	#overview
	Dom.div !->
		Dom.style
			overflowX: 'visible'
			overflowY: 'auto'
			padding: '0px'
			color: '#bbb'
			
			_userSelect: 'none'
			height: '100%'
			display: 'flex'
		Dom.ul !-> #thread legend
			Dom.style
				zIndex: 50;
				listStyle: 'none'
				padding: 0
				margin: 0	
				Box: 'vertical'
				display: 'block'
				pointerEvents: 'none'
				width: '0px'
				height: '0px'
				position: 'relative'
			Dom.li !-> #no top, margin, padding or border works. so this is it then.
				Dom.style height: "19px"
			addThread t for t in threads
		Dom.div !-> #body
			Dom.style
				overflowY: 'auto'
				overflowX: 'visible'
				boxSizing: 'border-box'
				height: contentHeight
				paddingLeft: '8px'

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
						day = Db.local.get("day")
						Dom.style
							listStyle: 'none'
							margin: '0px'
							padding: '8px'
							position: 'relative'
						# addItem item for item in items
						for item in items when item.day is day
							addItem item, threads.indexOf(item.location)
	#days
	Page.setFooter !->
		Dom.div !->
			cd = Db.local.get("day")
			Dom.style
				listStyle: 'none'
				Box: 'horizontal'
				overflowX: 'auto'
			days.forEach (day) !->
				Dom.li !->
					Dom.style
						color: if cd is day then Plugin.colors().highlight else '#bbb'
						Flex: true
						textAlign: 'center'
						minWidth: '90px'
						height: '20px'
					Dom.text day
					Dom.onTap !->
						Db.local.set("day", day)


	#scroll to the position where we left it
	scrollE.prop("scrollLeft", Db.local.peek("hScroll")||0)	

	#save scroll to state
	Obs.onClean !->
		Db.local.set "hScroll", scrollE.prop("scrollLeft")