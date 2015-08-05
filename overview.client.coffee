Db = require 'db'
Dom = require 'dom'
Form = require 'form'
Server = require 'server'
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
			#save scroll to state
			Page.state.set "_hScroll", scrollE.prop("scrollLeft")
			Page.nav {0:item.name, "?key": item.key}

exports.renderOverview = (items, threads, days) ->
	#responsive
	rowHeight = Math.min(150, Math.max(rowHeight, (Page.height()-140-(threads.length*locationHeight))/threads.length))
	contentHeight = Math.max(Page.height()-130, threads.length*(rowHeight+locationHeight)+12)+27

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
				Box: 'vertical'
				display: 'block'
				pointerEvents: 'none'
				margin: "27px 0px 0px 0px"
				width: '0px'
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
						Dom.style
							listStyle: 'none'
							margin: '0px'
							padding: '8px'
							position: 'relative'
						# addItem item for item in items
						for item in items
							addItem item, threads.indexOf(item.location)
	#days
	Dom.div !->
		Dom.style
			listStyle: 'none'
			Box: 'horizontal'
			# Flex: true
		for day in days
			Dom.li !->
				Dom.text day


	#scroll to the position where we left it
	scrollE.prop("scrollLeft", Page.state.get("_hScroll")||0)	

	# Page.onNavClean (prev) !->
		# if scrollE.prop("scrollLeft")
			# prev._hScroll = scrollE.prop("scrollLeft")