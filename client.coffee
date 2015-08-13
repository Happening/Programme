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

days = ["Friday", "Saturday", "Sunday"]#, "Monday", "Someday", "Tomorrow"]
startTimes = [1130, 1000, 1100]
endTimes = [2400, 2800, 1400]

threads = ["Alpha", "Beta", "Gamma"]

#start time goes in time notation without the ':', duration in minutes
items = [
		{
			key: 0
			name: "Muse"
			location: 'Alpha'
			start: "1200"
			duration: 120
			description: "Muse are an English rock band from Teignmouth, Devon, formed in 1994. The band consists of Matthew Bellamy, Christopher Wolstenholme and Dominic Howard. They are known for their energetic live performances."
			shadowColor: "rgba(199,	199, 199, 0.4)"
			day: "Friday"
		}
		{
			key: 1
			name: "Foo Fighters"
			location: 'Alpha'
			start: "1530"
			duration: 150
			description: "Foo Fighters is an American rock band, formed in Seattle in 1994. It was founded by Nirvana drummer Dave Grohl as a one-man project following the death of Kurt Cobain and the resulting dissolution of his previous band."
			shadowColor: "rgba(175,	65, 73, 0.4)"
			day: "Friday"
		}
		{
			key: 2
			name: "Mumford & Sons"
			location: 'Beta'
			start: "1215"
			duration: 45
			description: "Mumford & Sons are a British rock band from London, formed in 2007. The band consists of Marcus Mumford, Ben Lovett, Winston Marshall and Ted Dwane. Mumford & Sons have released three studio albums: Sigh No More, Babel and Wilder Mind."
			shadowColor: "rgba(140,	171, 162, 0.4)"
			day: "Friday"
		}
		{
			key: 3
			name: "The Prodigy"
			location: 'Beta'
			start: "1415"
			duration: 90
			description: "The Prodigy are an English electronic dance music group from Braintree, Essex, formed by Liam Howlett in 1990. The current members include Liam Howlett, Keith Flint and Maxim."
			shadowColor: "rgba(186,	184, 183, 0.4)"
			day: "Friday"
		}
		{
			key: 4
			name: "Seasick Steve"
			location: 'Beta'
			start: "1600"
			duration: 60
			description: "Steven Gene Wold, commonly known as Seasick Steve, is an American blues musician. He plays mostly personalized guitars, and sings, usually about his early life doing casual work."
			shadowColor: "rgba(200,	148, 89, 0.4)"
			day: "Friday"
		}
		{
			key: 5
			name: "Unknown Artist"
			location: 'Beta'
			start: "2100"
			duration: 60
			day: "Friday"	
		}
		{
			key: 6
			name: "Ayreon"
			location: 'Gamma'
			start: "1430"
			duration: 45
			description: "Ayreon /ˈɛriən/ is a musical project by Dutch songwriter, singer, multi-instrumentalist musician and record producer Arjen Anthony Lucassen."
			shadowColor: "rgba(226,	178, 188, 0.4)"
			day: "Friday"
		}
		{
			key: 7
			name: "Caravan Palace"
			location: 'Gamma'
			start: "1630"
			duration: 45
			description: "Caravan Palace is a French electro swing band based in Paris. The band's influences include Django Reinhardt, Vitalic, Lionel Hampton, and Daft Punk. The band released their début studio album, Caravan Palace, on the Wagram label in October 2008."
			shadowColor: "rgba(184,	132, 100, 0.4)"
			day: "Friday"
		}
		{
			key: 8
			name: "Seasick Steve"
			location: 'Alpha'
			start: "1030"
			duration: 90
			description: "Steven Gene Wold, commonly known as Seasick Steve, is an American blues musician. He plays mostly personalized guitars, and sings, usually about his early life doing casual work."
			shadowColor: "rgba(200,	148, 89, 0.4)"
			day: "Saturday"
		}
		{
			key: 9
			name: "The Prodigy"
			location: 'Alpha'
			start: "1230"
			duration: 90
			description: "The Prodigy are an English electronic dance music group from Braintree, Essex, formed by Liam Howlett in 1990. The current members include Liam Howlett, Keith Flint and Maxim."
			shadowColor: "rgba(186,	184, 183, 0.4)"
			day: "Saturday"
		}
		#saturday
		{
			key: 10
			name: "AC/DC"
			location: 'Alpha'
			start: "1415"
			duration: 120
			description: "AC/DC are an Australian hard rock band, formed in November 1973 by brothers Malcolm and Angus Young, who continued as members until Malcolm's illness and departure in 2014."
			shadowColor: "rgba(200, 200, 200, 0.4)"
			day: "Saturday"
		}
		{
			key: 11
			name: "Emancipator"
			location: 'Beta'
			start: "1330"
			duration: 180
			description: "Douglas Appling, better known by his stage name Emancipator, is an American electronic producer based in Portland, Oregon. His debut album, Soon It Will Be Cold Enough, was released in 2006."
			shadowColor: "rgba(121, 204, 146, 0.4)"
			day: "Saturday"
		}
		{
			key: 12
			name: "Hans Zimmer"
			location: 'Gamma'
			start: "1130"
			duration: 180
			description: "Hans Florian Zimmer is a German composer and music producer. Since the 1980s, he has composed music for over 150 films."
			shadowColor: "rgba(121, 204, 146, 0.4)"
			day: "Sunday"
		}
	]

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