Db = require 'db'
Http = require 'http'
Plugin = require 'plugin'

exports.client_getCover = (name) !->
	#start by setting we haven't found it. cause if we indeed don't it's harder to set.
	Db.shared.set name, "not found"

	#parse the name a bit so spotify accepts it.
	name = name.replace(/, /g,",")
	name = name.replace(/\s/g, "+")
	name = name.replace(/&/g,"%26")
	Http.get
		url: 'https://api.spotify.com/v1/search?q=' + name + '&type=artist&limit=1'
		name: 'spotifyResponse'

exports.spotifyResponse = (data) !->
	# called when the Http API has the result for the above request
	d = JSON.parse data
	if d.artists.total isnt 0
		name = d.artists.items[0].name.toLowerCase()
		imgUrl = d.artists.items[0].images[0].url
		Db.shared.set name, imgUrl

exports.client_join = (name) !->
	# value = Plugin.userId()
	value = Db.shared.get("attendance", name)
	if value?
		log "yes"
		log value
		if Plugin.userId() in value
			value.splice value.indexOf(Plugin.userId()), 1
		else
			value.push Plugin.userId()
	else
		value = [Plugin.userId()]
	if value.length is 0
		value = null
	Db.shared.set "attendance", name, value
