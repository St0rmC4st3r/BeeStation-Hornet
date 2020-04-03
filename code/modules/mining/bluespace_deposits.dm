GLOBAL_LIST_INIT(bluespace_deposits, subtypesof(/datum/bluespace_ore_deposit))

//DON'T MINE BLUESPACE

/datum/bluespace_ore_deposit
	var/x
	var/y
	var/special_deposit = FALSE
	var/list/allowedmats
	var/list/mats_prob = list(
		/datum/material/iron=30, 
		/datum/material/glass=40, 
		/datum/material/copper=15, 
		/datum/material/silver=12, 
		/datum/material/gold=13, 
		/datum/material/diamond=5, 			//WHAT THE FUCK IS CO2?!
		/datum/material/plasma=20, 
		/datum/material/uranium=10, 
		/datum/material/bananium=0.001, 	//nope
		/datum/material/titanium=11, 
		/datum/material/bluespace=3, 		//DO NOT MINE
		/datum/material/plastic=10			//we should be concerned about environmental pollution
		)
	var/oreammount_min = 2000 				//one ingot totally
	var/oreammount_max = 10000
	var/oreammount
	var/oreammount_estimated_total
	var/barren_rock_multiplyer = 0			//makes mining slower
	var/datum/component/material_container/ores


/datum/bluespace_ore_deposit/proc/Initialize()
	oreammount = rand(oreammount_min, oreammount_max)
	oreammount_estimated_total = oreammount + round(rand(oreammount*-0.5, oreammount*1.5))
	AddComponent(/datum/component/material_container,
	allowedmats,
	INFINITY,
	FALSE,
	/obj/item/stack,
	null,
	null,
	TRUE)
	generate_ores()


/datum/bluespace_ore_deposit/proc/generate_ores()
	var/ore_unsorted_left = oreammount
	var/portion = round(ore_unsorted_left/100)
	var/datum/material/current_ore
	while(ore_unsorted_left > 0)
		current_ore = pick(mats_prob)
		if(current_ore in allowedmats)
			if(portion>ore_unsorted_left)
				portion = ore_unsorted_left
			ores.insert_amount_mat(portion, current_ore)
			ore_unsorted_left -= portion

	return


/datum/bluespace_ore_deposit/regular		//generic multimaterial deposit
	allowedmats = list(			
		/datum/material/iron, 
		/datum/material/glass, 
		/datum/material/copper, 
		/datum/material/plasma,
		/datum/material/silver, 
		/datum/material/gold, 
		/datum/material/diamond, 
		/datum/material/uranium, 
		/datum/material/titanium, 
		/datum/material/bluespace, //DO NOT MINE
		)
/datum/bluespace_ore_deposit/regular/small
	oreammount_min = 1000
	oreammount_max = 10000

/datum/bluespace_ore_deposit/regular/medium
	oreammount_min = 5000
	oreammount_max = 25000

/datum/bluespace_ore_deposit/regular/large
	oreammount_min = 25000
	oreammount_max = 100000

/datum/bluespace_ore_deposit/regular/very_large
	oreammount_min = 100000
	oreammount_max = 1000000



/datum/bluespace_ore_deposit/pure			//contains only one type of resource. also smaller than regular.
	allowedmats = list(			//let's be somewhat generous
		/datum/material/iron=30, 
		/datum/material/glass, 
		/datum/material/copper, 
		/datum/material/plasma,
		/datum/material/silver, 
		/datum/material/gold, 
		/datum/material/diamond,			//imagine the ammount of CO2 
		/datum/material/uranium, 
		/datum/material/titanium
		)
	oreammount_min = 5000
	oreammount_max = 50000
	

/datum/bluespace_ore_deposit/pure/Initialize()
	.=..()
	allowedmats = list(pick(allowedmats))
	if(!barren_rock_multiplyer)
		barren_rock_multiplyer = rand(0, 0.6)
	


/datum/bluespace_ore_deposit/pure/small
	oreammount_min = 500
	oreammount_max = 10000

/datum/bluespace_ore_deposit/pure/medium
	oreammount_min = 5000
	oreammount_max = 50000

/datum/bluespace_ore_deposit/pure/large
	oreammount_min = 20000
	oreammount_max = 100000


/datum/bluespace_ore_deposit/pure/bluespace								//FREEMAN, YOU FOOL!!!!
	allowedmats = list(/datum/material/bluespace)
	oreammount_min = 10			//feh....
	oreammount_max = 10000		//ohshit!
	
/datum/bluespace_ore_deposit/pure/bananium								
	allowedmats = list(/datum/material/bananium)
	oreammount_min = 100			
	oreammount_max = 40000

/datum/bluespace_ore_deposit/pure/fake									//miners will mine nothing while the probe will report minerals.
	barren_rock_multiplyer = 1

/datum/bluespace_ore_deposit/pure/plastic								//nuff said
	allowedmats = list(/datum/material/plastic)


/datum/bluespace_ore_deposit/spawner									//this may spawn something.
	var/list/special_spawnable
	var/spawnable_ammount = 1

/datum/bluespace_ore_deposit/spawner/snacks
	allowedmats = list(/datum/material/plastic)	//wrappings
	oreammount_min = 10			
	oreammount_max = 10000
/datum/bluespace_ore_deposit/spawner/pizza

/datum/bluespace_ore_deposit/spawner/booze

/datum/bluespace_ore_deposit/spawner/artifact							//should spawn artifacts when ported. skub for now.



/datum/bluespace_ore_deposit/spawner/singularity						//can create a singulo.
	special_spawnable = list(/obj/singularity)
/datum/bluespace_ore_deposit/spawner/biological							//spawns a mob

/datum/bluespace_ore_deposit/spawner/biological/dead_spessman			//was he exploring? fell out of a shuttle? forcibly spaced? who knows.

/datum/bluespace_ore_deposit/spawner/biological/cristaline				//basilisks

/datum/bluespace_ore_deposit/spawner/biological/dragonlair				//a ton of gold, but it will eventually spawn a sentient space dragon should there be ghosts willing to control it.

/datum/bluespace_ore_deposit/spawner/biological/syndie_minebots

/datum/bluespace_ore_deposit/whole_asteroids							//in case you need something from _maps/templates

	
