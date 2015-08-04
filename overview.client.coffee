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

exports.renderOverview = (items, threads) ->
	#responsive
	rowHeight = Math.min(150, Math.max(rowHeight, (Page.height()-140-(threads.length*locationHeight))/threads.length))
	contentHeight = Math.max(Page.height()-130, threads.length*(rowHeight+locationHeight)+12)+27

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
					# addItem item for item in items
					for item in items
						addItem item, threads.indexOf(item.location)
	
	#scroll to the position where we left it	
	scrollE.prop("scrollLeft", Page.state.get("_scroll")||0)		

	Page.onNavClean (prev) !->
		if scrollE.prop("scrollLeft")
			prev._scroll = scrollE.prop("scrollLeft")