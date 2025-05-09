//Xenobio control console
/mob/camera/ai_eye/remote/xenobio
	visible_icon = TRUE
	icon = 'icons/mob/cameramob.dmi'
	icon_state = "generic_camera"
	var/allowed_area = null

/mob/camera/ai_eye/remote/xenobio/Initialize(mapload)
	var/area/A = get_area(loc)
	allowed_area = A.name
	. = ..()

/mob/camera/ai_eye/remote/xenobio/setLoc(destination)
	var/area/new_area = get_area(destination)
	return is_valid_area(new_area) ? ..() : FALSE

/mob/camera/ai_eye/remote/xenobio/canZMove(direction, turf/source, turf/target, pre_move = TRUE)
	var/area/new_area = get_area(target)
	return is_valid_area(new_area) ? ..() : FALSE

/mob/camera/ai_eye/remote/xenobio/proc/is_valid_area(area/new_area)
	return new_area && new_area.name == allowed_area || new_area && (new_area.area_flags & XENOBIOLOGY_COMPATIBLE)

/obj/machinery/computer/camera_advanced/xenobio
	name = "Slime management console"
	desc = "A computer used for remotely handling slimes."
	networks = list("ss13")
	circuit = /obj/item/circuitboard/computer/xenobiology
	var/datum/action/innate/slime_place/slime_place_action
	var/datum/action/innate/slime_pick_up/slime_up_action
	var/datum/action/innate/feed_slime/feed_slime_action
	var/datum/action/innate/monkey_recycle/monkey_recycle_action
	var/datum/action/innate/slime_scan/scan_action
	var/datum/action/innate/feed_potion/potion_action
	var/datum/action/innate/hotkey_help/hotkey_help

	var/obj/machinery/monkey_recycler/connected_recycler
	var/list/stored_slimes
	var/obj/item/slimepotion/slime/current_potion
	var/max_slimes = 5
	var/monkeys = 0

	icon_screen = "slime_comp"
	icon_keyboard = "rd_key"

	light_color = LIGHT_COLOR_PINK

	reveal_camera_mob = TRUE
	camera_mob_icon_state = "xeno"

/obj/machinery/computer/camera_advanced/xenobio/Initialize(mapload)
	. = ..()
	slime_place_action = new(src)
	slime_up_action = new(src)
	feed_slime_action = new(src)
	monkey_recycle_action = new(src)
	scan_action = new(src)
	potion_action = new(src)
	hotkey_help = new(src)
	stored_slimes = list()
	RegisterSignal(src, COMSIG_ATOM_CONTENTS_DEL, PROC_REF(on_contents_del))
	for(var/obj/machinery/monkey_recycler/recycler in GLOB.monkey_recyclers)
		if(get_area(recycler.loc) == get_area(loc))
			connected_recycler = recycler
			connected_recycler.connected += src

/obj/machinery/computer/camera_advanced/xenobio/Destroy()
	stored_slimes = null
	QDEL_NULL(current_potion)
	for(var/i in contents)
		var/mob/living/simple_animal/slime/S = i
		if(istype(S))
			S.forceMove(drop_location())
	return ..()

/obj/machinery/computer/camera_advanced/xenobio/CreateEye()
	eyeobj = new /mob/camera/ai_eye/remote/xenobio(get_turf(src))
	eyeobj.origin = src
	eyeobj.icon = camera_mob_icon
	eyeobj.icon_state = camera_mob_icon_state
	RevealCameraMob()

/obj/machinery/computer/camera_advanced/xenobio/GrantActions(mob/living/user)
	..()

	if(slime_up_action)
		slime_up_action.Grant(user)
		actions += slime_up_action

	if(slime_place_action)
		slime_place_action.Grant(user)
		actions += slime_place_action

	if(feed_slime_action)
		feed_slime_action.Grant(user)
		actions += feed_slime_action

	if(monkey_recycle_action)
		monkey_recycle_action.Grant(user)
		actions += monkey_recycle_action

	if(scan_action)
		scan_action.Grant(user)
		actions += scan_action

	if(potion_action)
		potion_action.Grant(user)
		actions += potion_action

	if(hotkey_help)
		hotkey_help.Grant(user)
		actions += hotkey_help

	RegisterSignal(user, COMSIG_XENO_SLIME_CLICK_CTRL, PROC_REF(XenoSlimeClickCtrl))
	RegisterSignal(user, COMSIG_XENO_SLIME_CLICK_ALT, PROC_REF(XenoSlimeClickAlt))
	RegisterSignal(user, COMSIG_XENO_SLIME_CLICK_SHIFT, PROC_REF(XenoSlimeClickShift))
	RegisterSignal(user, COMSIG_XENO_TURF_CLICK_SHIFT, PROC_REF(XenoTurfClickShift))
	RegisterSignal(user, COMSIG_XENO_TURF_CLICK_CTRL, PROC_REF(XenoTurfClickCtrl))
	RegisterSignal(user, COMSIG_XENO_MONKEY_CLICK_CTRL, PROC_REF(XenoMonkeyClickCtrl))

	//Checks for recycler on every interact, prevents issues with load order on certain maps.
	if(!connected_recycler)
		for(var/obj/machinery/monkey_recycler/recycler in GLOB.monkey_recyclers)
			if(get_area(recycler.loc) == get_area(loc))
				connected_recycler = recycler
				connected_recycler.connected += src

/obj/machinery/computer/camera_advanced/xenobio/remove_eye_control(mob/living/user)
	UnregisterSignal(user, COMSIG_XENO_SLIME_CLICK_CTRL)
	UnregisterSignal(user, COMSIG_XENO_SLIME_CLICK_ALT)
	UnregisterSignal(user, COMSIG_XENO_SLIME_CLICK_SHIFT)
	UnregisterSignal(user, COMSIG_XENO_TURF_CLICK_SHIFT)
	UnregisterSignal(user, COMSIG_XENO_TURF_CLICK_CTRL)
	UnregisterSignal(user, COMSIG_XENO_MONKEY_CLICK_CTRL)
	..()

/obj/machinery/computer/camera_advanced/xenobio/proc/on_contents_del(datum/source, atom/deleted)
	SIGNAL_HANDLER

	if(current_potion == deleted)
		current_potion = null
	if(deleted in stored_slimes)
		stored_slimes -= deleted

/obj/machinery/computer/camera_advanced/xenobio/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/food/monkeycube))
		monkeys++
		to_chat(user, span_notice("You feed [O] to [src]. It now has [monkeys] monkey cubes stored."))
		qdel(O)
		return
	else if(istype(O, /obj/item/storage/bag))
		var/obj/item/storage/P = O
		var/loaded = FALSE
		for(var/obj/G in P.contents)
			if(istype(G, /obj/item/food/monkeycube))
				loaded = TRUE
				monkeys++
				qdel(G)
		if(loaded)
			to_chat(user, span_notice("You fill [src] with the monkey cubes stored in [O]. [src] now has [monkeys] monkey cubes stored."))
		return
	else if(istype(O, /obj/item/slimepotion/slime))
		var/replaced = FALSE
		if(user && !user.transferItemToLoc(O, src))
			return
		if(!QDELETED(current_potion))
			current_potion.forceMove(drop_location())
			replaced = TRUE
		current_potion = O
		to_chat(user, span_notice("You load [O] in the console's potion slot[replaced ? ", replacing the one that was there before" : ""]."))
		return
	..()

REGISTER_BUFFER_HANDLER(/obj/machinery/computer/camera_advanced/xenobio)

DEFINE_BUFFER_HANDLER(/obj/machinery/computer/camera_advanced/xenobio)
	if (istype(buffer,/obj/machinery/monkey_recycler) && connected_recycler != buffer)
		to_chat(user, span_notice("You link [src] with [buffer] in [buffer_parent] buffer."))
		connected_recycler = buffer
		connected_recycler.connected += src
		return COMPONENT_BUFFER_RECEIVED
	return NONE

/datum/action/innate/slime_place
	name = "Place Slimes"
	icon_icon = 'icons/hud/actions/actions_silicon.dmi'
	button_icon_state = "slime_down"

/datum/action/innate/slime_place/on_activate()
	if(!master || !isliving(owner))
		return
	var/mob/living/C = owner
	var/mob/camera/ai_eye/remote/xenobio/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = master

	if(GLOB.cameranet.checkTurfVis(remote_eye.loc))
		for(var/mob/living/simple_animal/slime/S in X.stored_slimes)
			S.forceMove(remote_eye.loc)
			S.visible_message("[S] warps in!")
			X.stored_slimes -= S
	else
		to_chat(owner, span_warning("Target is not near a camera. Cannot proceed."))

/datum/action/innate/slime_pick_up
	name = "Pick up Slime"
	icon_icon = 'icons/hud/actions/actions_silicon.dmi'
	button_icon_state = "slime_up"

/datum/action/innate/slime_pick_up/on_activate()
	if(!master || !isliving(owner))
		return
	var/mob/living/C = owner
	var/mob/camera/ai_eye/remote/xenobio/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = master

	if(GLOB.cameranet.checkTurfVis(remote_eye.loc))
		for(var/mob/living/simple_animal/slime/S in remote_eye.loc)
			if(X.stored_slimes.len >= X.max_slimes)
				break
			if(!S.ckey)
				if(S.buckled)
					S.Feedstop(silent = TRUE)
				S.visible_message("[S] vanishes in a flash of light!")
				S.forceMove(X)
				X.stored_slimes += S
	else
		to_chat(owner, span_warning("Target is not near a camera. Cannot proceed."))


/datum/action/innate/feed_slime
	name = "Feed Slimes"
	icon_icon = 'icons/hud/actions/actions_silicon.dmi'
	button_icon_state = "monkey_down"

/datum/action/innate/feed_slime/on_activate()
	if(!master || !isliving(owner))
		return
	var/mob/living/C = owner
	var/mob/camera/ai_eye/remote/xenobio/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = master

	if(GLOB.cameranet.checkTurfVis(remote_eye.loc))
		if(X.monkeys >= 1)
			var/mob/living/carbon/monkey/food = new /mob/living/carbon/monkey(remote_eye.loc, TRUE, owner)
			if (!QDELETED(food))
				X.monkeys--
				X.monkeys = round(X.monkeys, 0.1)		//Prevents rounding errors
				to_chat(owner, "[X] now has [X.monkeys] monkeys stored.")
		else
			to_chat(owner, "[X] needs to have at least 1 monkey stored. Currently has [X.monkeys] monkeys stored.")
	else
		to_chat(owner, span_notice("Target is not near a camera. Cannot proceed."))


/datum/action/innate/monkey_recycle
	name = "Recycle Monkeys"
	icon_icon = 'icons/hud/actions/actions_silicon.dmi'
	button_icon_state = "monkey_up"

/datum/action/innate/monkey_recycle/on_activate()
	if(!master || !isliving(owner))
		return
	var/mob/living/C = owner
	var/mob/camera/ai_eye/remote/xenobio/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = master
	var/obj/machinery/monkey_recycler/recycler = X.connected_recycler

	if(!recycler)
		to_chat(owner, span_notice("There is no connected monkey recycler.  Use a multitool to link one."))
		return
	if(GLOB.cameranet.checkTurfVis(remote_eye.loc))
		for(var/mob/living/carbon/monkey/M in remote_eye.loc)
			if(M.stat)
				M.visible_message("[M] vanishes as [M.p_theyre()] reclaimed for recycling!")
				recycler.use_power(500)
				X.monkeys += recycler.cube_production
				X.monkeys = round(X.monkeys, 0.1)		//Prevents rounding errors
				qdel(M)
				to_chat(owner, "[X] now has [X.monkeys] monkeys available.")
	else
		to_chat(owner, span_warning("Target is not near a camera. Cannot proceed."))

/datum/action/innate/slime_scan
	name = "Scan Slime"
	icon_icon = 'icons/hud/actions/actions_silicon.dmi'
	button_icon_state = "slime_scan"

/datum/action/innate/slime_scan/on_activate()
	if(!master || !isliving(owner))
		return
	var/mob/living/C = owner
	var/mob/camera/ai_eye/remote/xenobio/remote_eye = C.remote_control

	if(GLOB.cameranet.checkTurfVis(remote_eye.loc))
		for(var/mob/living/simple_animal/slime/S in remote_eye.loc)
			slime_scan(S, C)
	else
		to_chat(owner, span_warning("Target is not near a camera. Cannot proceed."))

/datum/action/innate/feed_potion
	name = "Apply Potion"
	icon_icon = 'icons/hud/actions/actions_silicon.dmi'
	button_icon_state = "slime_potion"

/datum/action/innate/feed_potion/on_activate()
	if(!master || !isliving(owner))
		return

	var/mob/living/C = owner
	var/mob/camera/ai_eye/remote/xenobio/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = master

	if(QDELETED(X.current_potion))
		to_chat(owner, span_warning("No potion loaded."))
		return

	if(GLOB.cameranet.checkTurfVis(remote_eye.loc))
		for(var/mob/living/simple_animal/slime/S in remote_eye.loc)
			X.current_potion.attack(S, C)
			break
	else
		to_chat(owner, span_warning("Target is not near a camera. Cannot proceed."))

/datum/action/innate/hotkey_help
	name = "Hotkey Help"
	icon_icon = 'icons/hud/actions/actions_silicon.dmi'
	button_icon_state = "hotkey_help"

/datum/action/innate/hotkey_help/on_activate()
	if(!master || !isliving(owner))
		return
	to_chat(owner, "<b>Click shortcuts:</b>")
	to_chat(owner, "Shift-click a slime to pick it up, or the floor to drop all held slimes.")
	to_chat(owner, "Ctrl-click a slime to scan it.")
	to_chat(owner, "Alt-click a slime to feed it a potion.")
	to_chat(owner, "Ctrl-click or a dead monkey to recycle it, or the floor to place a new monkey.")

//
// Alternate clicks for slime, monkey and open turf if using a xenobio console

// Scans slime
/mob/living/simple_animal/slime/CtrlClick(mob/user)
	SEND_SIGNAL(user, COMSIG_XENO_SLIME_CLICK_CTRL, src)
	..()

//Feeds a potion to slime
/mob/living/simple_animal/slime/AltClick(mob/user)
	SEND_SIGNAL(user, COMSIG_XENO_SLIME_CLICK_ALT, src)
	..()

//Picks up slime
/mob/living/simple_animal/slime/ShiftClick(mob/user)
	SEND_SIGNAL(user, COMSIG_XENO_SLIME_CLICK_SHIFT, src)
	..()

//Place slimes
/turf/open/ShiftClick(mob/user)
	SEND_SIGNAL(user, COMSIG_XENO_TURF_CLICK_SHIFT, src)
	..()

//Place monkey
/turf/open/CtrlClick(mob/user)
	SEND_SIGNAL(user, COMSIG_XENO_TURF_CLICK_CTRL, src)
	..()

//Pick up monkey
/mob/living/carbon/monkey/CtrlClick(mob/user)
	SEND_SIGNAL(user, COMSIG_XENO_MONKEY_CLICK_CTRL, src)
	..()

// Scans slime
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoSlimeClickCtrl(mob/living/user, mob/living/simple_animal/slime/S)
	SIGNAL_HANDLER

	if(!GLOB.cameranet.checkTurfVis(S.loc))
		to_chat(user, span_warning("Target is not near a camera. Cannot proceed."))
		return
	var/mob/living/C = user
	var/mob/camera/ai_eye/remote/xenobio/E = C.remote_control
	var/area/mobarea = get_area(S.loc)
	if(mobarea.name == E.allowed_area || (mobarea.area_flags & XENOBIOLOGY_COMPATIBLE))
		slime_scan(S, C)

//Feeds a potion to slime
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoSlimeClickAlt(mob/living/user, mob/living/simple_animal/slime/S)
	SIGNAL_HANDLER

	if(!GLOB.cameranet.checkTurfVis(S.loc))
		to_chat(user, span_warning("Target is not near a camera. Cannot proceed."))
		return
	var/mob/living/C = user
	var/mob/camera/ai_eye/remote/xenobio/E = C.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = E.origin
	var/area/mobarea = get_area(S.loc)
	if(QDELETED(X.current_potion))
		to_chat(C, span_warning("No potion loaded."))
		return
	if(mobarea.name == E.allowed_area || (mobarea.area_flags & XENOBIOLOGY_COMPATIBLE))
		X.current_potion.attack(S, C)

//Picks up slime
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoSlimeClickShift(mob/living/user, mob/living/simple_animal/slime/S)
	SIGNAL_HANDLER

	if(!GLOB.cameranet.checkTurfVis(S.loc))
		to_chat(user, span_warning("Target is not near a camera. Cannot proceed."))
		return
	var/mob/living/C = user
	var/mob/camera/ai_eye/remote/xenobio/E = C.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = E.origin
	var/area/mobarea = get_area(S.loc)
	if(mobarea.name == E.allowed_area || (mobarea.area_flags & XENOBIOLOGY_COMPATIBLE))
		if(X.stored_slimes.len >= X.max_slimes)
			to_chat(C, span_warning("Slime storage is full."))
			return
		if(S.ckey)
			to_chat(C, span_warning("The slime wiggled free!"))
			return
		if(S.buckled)
			S.Feedstop(silent = TRUE)
		S.visible_message("[S] vanishes in a flash of light!")
		S.forceMove(X)
		X.stored_slimes += S

//Place slimes
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoTurfClickShift(mob/living/user, turf/open/T)
	SIGNAL_HANDLER

	if(!GLOB.cameranet.checkTurfVis(T))
		to_chat(user, span_warning("Target is not near a camera. Cannot proceed."))
		return
	var/mob/living/C = user
	var/mob/camera/ai_eye/remote/xenobio/E = C.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = E.origin
	var/area/turfarea = get_area(T)
	if(turfarea.name == E.allowed_area || (turfarea.area_flags & XENOBIOLOGY_COMPATIBLE))
		for(var/mob/living/simple_animal/slime/S in X.stored_slimes)
			S.forceMove(T)
			S.visible_message("[S] warps in!")
			X.stored_slimes -= S

//Place monkey
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoTurfClickCtrl(mob/living/user, turf/open/T)
	SIGNAL_HANDLER

	if(!GLOB.cameranet.checkTurfVis(T))
		to_chat(user, span_warning("Target is not near a camera. Cannot proceed."))
		return
	var/mob/living/C = user
	var/mob/camera/ai_eye/remote/xenobio/E = C.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = E.origin
	var/area/turfarea = get_area(T)
	if(turfarea.name == E.allowed_area || (turfarea.area_flags & XENOBIOLOGY_COMPATIBLE))
		if(X.monkeys >= 1)
			var/mob/living/carbon/monkey/food = new /mob/living/carbon/monkey(T, TRUE, C)
			if (!QDELETED(food))
				X.monkeys--
				X.monkeys = round(X.monkeys, 0.1)		//Prevents rounding errors
				to_chat(C, "[X] now has [X.monkeys] monkeys stored.")
		else
			to_chat(C, "[X] needs to have at least 1 monkey stored. Currently has [X.monkeys] monkeys stored.")

//Pick up monkey
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoMonkeyClickCtrl(mob/living/user, mob/living/carbon/monkey/M)
	SIGNAL_HANDLER

	if(!GLOB.cameranet.checkTurfVis(M.loc))
		to_chat(user, span_warning("Target is not near a camera. Cannot proceed."))
		return
	var/mob/living/C = user
	var/mob/camera/ai_eye/remote/xenobio/E = C.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = E.origin
	var/area/mobarea = get_area(M.loc)
	if(!X.connected_recycler)
		to_chat(C, span_notice("There is no connected monkey recycler.  Use a multitool to link one."))
		return
	if(mobarea.name == E.allowed_area || (mobarea.area_flags & XENOBIOLOGY_COMPATIBLE))
		if(!M.stat)
			return
		M.visible_message("[M] vanishes as [p_theyre()] reclaimed for recycling!")
		X.connected_recycler.use_power(500)
		X.monkeys += connected_recycler.cube_production
		X.monkeys = round(X.monkeys, 0.1)		//Prevents rounding errors
		qdel(M)
		to_chat(C, "[X] now has [X.monkeys] monkeys available.")
