//slimecolor for the xenoblob nodes

/datum/slimecolor
	////////////////////////////
	//////*general info*////////
	////////////////////////////

	var/special_icon_state = "" //probably should be default or something. This is for rainbow, oil, metal, etc.
	var/colour = "grey"			//designated colour of node itself, slimes, and probably creeps.
	var/colour_HEX = ""

	////////////////////////////
	/////*behaviour stuff*//////
	////////////////////////////

	var/aggression				= 1	//nuff said. controls aggression towards non-food.
	var/gluttony				= 1	//after some treshold should allow a chance to throw temporary creeps to some food in extended range.
	var/preferred_temp_offset	= 0	//Maybe it likes when it's warmer?
	var/list/possible_slimes[4]		//what slimes can it spawn. Same as current slimes.

	////////////////////////////
	////*possible mutations*////
	////////////////////////////

	var/list/possible_mutations	//like in slimes for now.

//tier0
/datum/slimecolor/grey
	colour = "grey"
	possible_mutations  += /datum/slimecolor/orange
	possible_mutations  += /datum/slimecolor/purple
	possible_mutations  += /datum/slimecolor/cyan
	possible_mutations  += /datum/slimecolor/metal

//tier1
/datum/slimecolor/orange
	colour = "orange"
	possible_mutations[1] = /datum/slimecolor/yellow
	possible_mutations[2] = /datum/slimecolor/violet
	possible_mutations[3] = /datum/slimecolor/red
	possible_mutations[4] = /datum/slimecolor/red

/datum/slimecolor/purple
	colour = "purple"
	possible_mutations[1] = /datum/slimecolor/violet
	possible_mutations[2] = /datum/slimecolor/blue
	possible_mutations[3] = /datum/slimecolor/green
	possible_mutations[4] = /datum/slimecolor/green

/datum/slimecolor/cyan		//old blue
	colour = "blue"
	possible_mutations[1] = /datum/slimecolor/blue
	possible_mutations[2] = /datum/slimecolor/silver
	possible_mutations[3] = /datum/slimecolor/magenta
	possible_mutations[4] = /datum/slimecolor/magenta

/datum/slimecolor/metal
	colour = "metal"
	possible_mutations[1] = /datum/slimecolor/silver
	possible_mutations[2] = /datum/slimecolor/yellow
	possible_mutations[3] = /datum/slimecolor/gold
	possible_mutations[4] = /datum/slimecolor/gold

//tier2
/datum/slimecolor/yellow
	colour = "yellow"
	possible_mutations[1] = /datum/slimecolor/metal
	possible_mutations[2] = /datum/slimecolor/orange
	possible_mutations[3] = /datum/slimecolor/bluespace
	possible_mutations[4] = /datum/slimecolor/bluespace

/datum/slimecolor/violet	//old dark purple
	colour = "dark purple"
	possible_mutations[1] = /datum/slimecolor/orange
	possible_mutations[2] = /datum/slimecolor/purple
	possible_mutations[3] = /datum/slimecolor/sepia
	possible_mutations[4] = /datum/slimecolor/sepia

/datum/slimecolor/blue		//old dark blue
	colour = "dark blue"
	possible_mutations[1] = /datum/slimecolor/cyan
	possible_mutations[2] = /datum/slimecolor/purple
	possible_mutations[3] = /datum/slimecolor/cerulean
	possible_mutations[4] = /datum/slimecolor/cerulean

/datum/slimecolor/silver
	colour = "silver"
	possible_mutations[1] = /datum/slimecolor/cyan
	possible_mutations[2] = /datum/slimecolor/metal
	possible_mutations[3] = /datum/slimecolor/pyrite
	possible_mutations[4] = /datum/slimecolor/pyrite

//tier2.5. Change mutations to something not as crappy
/datum/slimecolor/bluespace
	colour = "bluespace"
	possible_mutations[1] = /datum/slimecolor/bluespace
	possible_mutations[2] = /datum/slimecolor/bluespace
	possible_mutations[3] = /datum/slimecolor/bluespace
	possible_mutations[4] = /datum/slimecolor/bluespace

/datum/slimecolor/sepia
	colour = "sepia"
	possible_mutations[1] = /datum/slimecolor/sepia
	possible_mutations[2] = /datum/slimecolor/sepia
	possible_mutations[3] = /datum/slimecolor/sepia
	possible_mutations[4] = /datum/slimecolor/sepia

/datum/slimecolor/cerulean
	colour = "cerulean"
	possible_mutations[1] = /datum/slimecolor/cerulean
	possible_mutations[2] = /datum/slimecolor/cerulean
	possible_mutations[3] = /datum/slimecolor/cerulean
	possible_mutations[4] = /datum/slimecolor/cerulean

/datum/slimecolor/pyrite
	colour = "pyrite"
	possible_mutations[1] = /datum/slimecolor/pyrite
	possible_mutations[2] = /datum/slimecolor/pyrite
	possible_mutations[3] = /datum/slimecolor/pyrite
	possible_mutations[4] = /datum/slimecolor/pyrite

//tier3
/datum/slimecolor/red
	colour = "red"
	possible_mutations[1] = /datum/slimecolor/red
	possible_mutations[2] = /datum/slimecolor/red
	possible_mutations[3] = /datum/slimecolor/oil
	possible_mutations[4] = /datum/slimecolor/oil

/datum/slimecolor/green
	colour = "green"
	possible_mutations[1] = /datum/slimecolor/green
	possible_mutations[2] = /datum/slimecolor/green
	possible_mutations[3] = /datum/slimecolor/black
	possible_mutations[4] = /datum/slimecolor/black

/datum/slimecolor/magenta	//old pink
	colour = "pink"
	possible_mutations[1] = /datum/slimecolor/magenta
	possible_mutations[2] = /datum/slimecolor/magenta
	possible_mutations[3] = /datum/slimecolor/pink
	possible_mutations[4] = /datum/slimecolor/pink

/datum/slimecolor/gold
	colour = "gold"
	possible_mutations[1] = /datum/slimecolor/gold
	possible_mutations[2] = /datum/slimecolor/gold
	possible_mutations[3] = /datum/slimecolor/adamantine
	possible_mutations[4] = /datum/slimecolor/adamantine

//tier4. Also do something about this.
/datum/slimecolor/oil
	colour = "oil"
	possible_mutations[1] = /datum/slimecolor/oil
	possible_mutations[2] = /datum/slimecolor/oil
	possible_mutations[3] = /datum/slimecolor/oil
	possible_mutations[4] = /datum/slimecolor/oil

/datum/slimecolor/black
	colour ="black"
	possible_mutations[1] = /datum/slimecolor/black
	possible_mutations[2] = /datum/slimecolor/black
	possible_mutations[3] = /datum/slimecolor/black
	possible_mutations[4] = /datum/slimecolor/black

/datum/slimecolor/pink		//old light pink
	colour = "light pink"
	possible_mutations[1] = /datum/slimecolor/pink
	possible_mutations[2] = /datum/slimecolor/pink
	possible_mutations[3] = /datum/slimecolor/pink
	possible_mutations[4] = /datum/slimecolor/pink

/datum/slimecolor/adamantine
	colour = "adamantine"
	possible_mutations[1] = /datum/slimecolor/adamantine
	possible_mutations[2] = /datum/slimecolor/adamantine
	possible_mutations[3] = /datum/slimecolor/adamantine
	possible_mutations[4] = /datum/slimecolor/adamantine

//rainbow
/datum/slimecolor/rainbow
	colour = "rainbow"
	possible_mutations[1] = /datum/slimecolor/rainbow
	possible_mutations[2] = /datum/slimecolor/rainbow
	possible_mutations[3] = /datum/slimecolor/rainbow
	possible_mutations[4] = /datum/slimecolor/rainbow


