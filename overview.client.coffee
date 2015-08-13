Db = require 'db'
Dom = require 'dom'
Event = require 'event'
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
scrollVE = null

addTime = (time) ->
	Dom.li !->
		Dom.style
			width: halfHourWidth + "px"
			padding: '4px'
			boxSizing: 'border-box'
			background: '#222' if (time%60 isnt 0) 
			height: '100%'
		# Dom.text Math.floor(time/60) + ":" + if (time%60) then (time%60) else "00"
		Dom.text TimeFormat.toDisplayTime(time)

addThread = (name) ->
	Dom.li !->
		Dom.style
			fontSize: '80%'
			height: '20px'
			marginBottom: (rowHeight-20) + 'px'
			padding: '4px'
			_whiteSpace: 'nowrap'
		Dom.text name + ":"

addItem = (item, index, startTime) ->
	Dom.li !->
		Dom.addClass "act"
		if item.smallImg
			imgUrl = item.smallImg
		else
			imgUrl = Db.shared.get item.name.toLowerCase()
			if !imgUrl?
				Server.call "getCover", item.name.toLowerCase()
		itemWidth = item.duration/30*halfHourWidth
		Dom.style
			position: 'absolute'
			left: ((TimeFormat.toHourFractal(item.start)*halfHourWidth*2) - (startTime/30*halfHourWidth)) + "px"
			top: index*(rowHeight+locationHeight)+locationHeight+14 + 'px'
			width: itemWidth + "px"
			height: rowHeight-16 + 'px'
			backgroundColor: '#666'
			backgroundImage: 'url("' + imgUrl + '")' if imgUrl isnt "not found"
			backgroundSize: 'cover'
			backgroundPosition: 'center 30%'
			boxSizing: 'border-box'
			_boxShadow: "rgba(#{item.color || "228,64,64"}, 1.0) 0px 0px 40px" if Db.shared.get("attendance", item.name)
			fontWeight: 'bold' if Db.shared.get("attendance", item.name)
			borderRadius: '2px'
			padding: '0px'
		Dom.div !->
			Dom.style
				Box: 'bottom'
				verticalAlign: 'bottom'
				height: '100%'
				width: '100%'
				background: 'linear-gradient(to top, rgba(0,0,0,0.7) 0%,rgba(0,0,0,0) 50px)'
			Dom.span !->
				Dom.style
					fontSize: '90%'
					boxSizing: 'border-box'
					padding: '2px 8px'
					color: '#eee'				
					overflow: 'hidden'
					position: 'absolute'
					bottom: '0px'
					_whiteSpace: 'nowrap'
					textOverflow: 'ellipsis'
					width: '100%'

				Dom.userText item.name
		Dom.div !->
			Dom.style
				position: 'absolute'
				top: '0px'
				right: '0px'
				textAlign: 'right'
				paddingTop: '1px'
				_whiteSpace: 'nowrap'
			if at = Db.shared.get("attendance", item.name)
				maxAvatars = Math.floor((itemWidth-40)/20)
				at.forEach (id, i) !->
					if i > maxAvatars then return
					Ui.avatar Plugin.userAvatar(id), size: 15
			Event.renderBubble [item.key], style:
				margin: if itemWidth > 35 then '-15px -10px 0px 0px' else '-15px -15px 0px 0px'
		Dom.onTap !->
			Page.nav {0:item.key}

exports.renderOverview = (items, threads, days, startTimes, endTimes) ->
	#responsive
	rowHeight = Math.min(150, Math.max(rowHeight, (Page.height()-170-(threads.length*locationHeight))/threads.length))
	contentHeight = Math.max(Page.height()-130, threads.length*(rowHeight+locationHeight)+12)+27

	Dom.css
		'.act.tap>div':
			background: 'rgba(0, 0, 0, 0.4) !important'

	#title
	if !Db.local.peek("day")? then Db.local.set("day", days[0])
	Obs.observe !->
		Page.setTitle Db.local.get("day")

	Dom.style
		Box: "vertical"
		padding: '0px'
		background: '#191919'
	if Plugin.agent().android
		Dom.style height: (contentHeight+29)+'px'
		if Plugin.agent().android < 4.4
			Obs.observe !->
				day = Db.local.get("day")
				dayIndex = days.indexOf(day)
				timeWidth = (TimeFormat.toMinutes(endTimes[dayIndex])-TimeFormat.toMinutes(startTimes[dayIndex]))/30 + 1
				Dom.style
					width: (timeWidth*halfHourWidth+marginLeft) + 19 + 'px'
	else
		Dom.style height: '100%'

	#overview
	#if vertical scrolling doesn't work, re-enable the height properties
	Dom.div !->
		Dom.style
			padding: '0px'
			color: '#bbb'			
			_userSelect: 'none'
			# height: contentHeight+'px' #thing?
			display: 'flex'
		if not Plugin.agent().android
			Dom.style
				overflowX: 'visible'
				overflowY: 	'auto'
				height: '100%'

		scrollVE = Dom.get()

		Dom.div !-> #thread legend
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
				# textTransform: "uppercase"
				position: 'relative'
			Dom.div !->
				if Plugin.agent().android >= 4.4
					Dom.style
						borderBottom: '29px solid transparent'
						# height: contentHeight+'px'
						width: Page.width()+'px'

				Dom.li !-> #no top, margin, padding or border works. so this is it then.
					Dom.style height: "19px"
				addThread t for t in threads
		Dom.div !-> #body
			if Plugin.agent().android
				if Plugin.agent().android >= 4.4
					Dom.overflow()
					Dom.style
						boxSizing: 'border-box'
						# height: contentHeight
						paddingLeft: '8px'
			else
				Dom.style
					overflowY: 'auto'
					overflowX: 'visible'
					boxSizing: 'border-box'
					# height: contentHeight
					paddingLeft: '8px'

			scrollE = Dom.get()	

			Dom.div !-> #time legend
				day = Db.local.get("day")
				dayIndex = days.indexOf(day)
				timeWidth = (TimeFormat.toMinutes(endTimes[dayIndex])-TimeFormat.toMinutes(startTimes[dayIndex]))/30 + 1
				Dom.style
					margin: '0px'
					listStyle: 'none'
					padding: 0
					Box: 'left'
					width: (timeWidth*halfHourWidth+marginLeft) + 'px'
					height: '100%'
					marginLeft: marginLeft
					position: 'relative'
				addTime i for i in [TimeFormat.toMinutes(startTimes[dayIndex])..TimeFormat.toMinutes(endTimes[dayIndex])] by 30
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
						for item in items when item.day is day
							addItem item, threads.indexOf(item.location), TimeFormat.toMinutes(startTimes[dayIndex])
	#days
	Page.setFooter !->
		Dom.div !->
			cd = Db.local.get("day")
			Dom.style
				listStyle: 'none'
				Box: 'horizontal'
				# overflowX: 'auto'
				background: '#191919'
			Dom.css
				'.tap':
					background: '#eee'
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
	scrollVE.prop("scrollTop", Db.local.peek("vScroll")||0)	

	#save scroll to state
	Obs.onClean !->
		Db.local.set "hScroll", scrollE.prop("scrollLeft")
		Db.local.set "vScroll", scrollVE.prop("scrollTop")