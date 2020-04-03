/obj/machinery/mineral/bluespace_miner
	name = "bluespace mining machine"
	desc = "A machine that uses the magic of Bluespace to slowly generate materials and add them to a linked ore silo."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "stacker"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/bluespace_miner
	layer = BELOW_OBJ_LAYER
	var/list/ore_rates = list(/datum/material/iron = 0.6, /datum/material/glass = 0.6, /datum/material/copper = 0.4, /datum/material/plasma = 0.2,  /datum/material/silver = 0.2, /datum/material/gold = 0.1, /datum/material/titanium = 0.1, /datum/material/uranium = 0.1, /datum/material/diamond = 0.1)
	var/datum/component/remote_materials/materials

/obj/machinery/mineral/bluespace_miner/Initialize(mapload)
	. = ..()
	materials = AddComponent(/datum/component/remote_materials, "bsm", mapload)

/obj/machinery/mineral/bluespace_miner/Destroy()
	materials = null
	return ..()

/obj/machinery/mineral/bluespace_miner/multitool_act(mob/living/user, obj/item/multitool/M)
	if(istype(M))
		if(!M.buffer || !istype(M.buffer, /obj/machinery/ore_silo))
			to_chat(user, "<span class='warning'>You need to multitool the ore silo first.</span>")
			return FALSE

/obj/machinery/mineral/bluespace_miner/examine(mob/user)
	. = ..()
	if(!materials?.silo)
		. += "<span class='notice'>No ore silo connected. Use a multi-tool to link an ore silo to this machine.</span>"
	else if(materials?.on_hold())
		. += "<span class='warning'>Ore silo access is on hold, please contact the quartermaster.</span>"

/obj/machinery/mineral/bluespace_miner/process()
	if(!materials?.silo || materials?.on_hold())
		return
	var/datum/component/material_container/mat_container = materials.mat_container
	if(!mat_container || panel_open || !powered())
		return
	var/datum/material/ore = pick(ore_rates)
	mat_container.insert_amount_mat((ore_rates[ore] * 1000), ore)

/obj/machinery/computer/bluespace_miner
	name = "bluespace miner contol console"
	desc = "A console that is used to configure linked bluespace mining machines."
	var/screen = "select"
	var/obj/machinery/mineral/probe/probe //THERE CAN BE ONLY ONE!!!!
	var/list/obj/machinery/mineral/bluespace_miner/miners

/obj/machinery/computer/bluespace_miner/Initialize()
	miners = list()
	. = ..()


/obj/machinery/bluespace_probe
	name = "bluespace deposit probe"
	desc = "Used to probe bluespace for ore deposits. Nanotrasen should definitely invest in some better equipment. "



/obj/machinery/bluespace_deposit_spawner
	name = "bluespace deposit radar"
	desc = "A machine that makes new bluespace deposits opaque to the probes. DO NOT REMOVE."
	//Actually just adds new deposits to the GLOB.bluespace_deposits if they are insufficient.
	var/scanning_cooldown = 3000	//every 5 minutes
	var/next_cooldown
	var/list/bluespace_ore_deposit/last_major_change
	var/list/bluespace_ore_deposit/last_check

/obj/machinery/bluespace_deposit_spawner/Initialize()

/obj/machinery/bluespace_deposit_spawner/proc/deposit_checkup()
	if(length(GLOB.bluespace_deposits)<length(last_check))
		if(prob(33))
			spawn_new_deposit()
		last_check = GLOB.bluespace_deposits
	if(length(GLOB.bluespace_deposits)<length(last_major_change)-10)
		major_change_action()

/obj/machinery/bluespace_deposit_spawner/proc/major_change_action()

/obj/machinery/bluespace_deposit_spawner/proc/spawn_new_deposit() 
