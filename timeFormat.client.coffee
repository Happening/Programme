exports.toHourFractal = (t) ->
	t = String t
	h = parseInt t.substring(0,2)
	m = parseInt t.substring(2,4)
	h+m/60

exports.toMinutes = (t) ->
	t = String t
	h = parseInt t.substring(0,2)
	m = parseInt t.substring(2,4)
	h*60+m

exports.toDisplayTime = (t) ->
	h = Math.floor(t/60)
	h = h%24
	if h<10 then h = "0"+h
	m = t%60
	h + ":" + (m||"00")