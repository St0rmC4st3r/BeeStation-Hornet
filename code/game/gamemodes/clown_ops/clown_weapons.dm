/obj/item/reagent_containers/spray/waterflower/lube
	name = "water flower"
	desc = "A seemingly innocent sunflower...with a twist. A <i>slippery</i> twist."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "sunflower"
	item_state = "sunflower"
	amount_per_transfer_from_this = 3
	spray_range = 1
	stream_range = 1
	volume = 30
	list_reagents = list(/datum/reagent/lube = 30)

//COMBAT CLOWN SHOES
//Clown shoes with combat stats and noslip. Of course they still squeak.
/obj/item/clothing/shoes/clown_shoes/combat
	name = "combat clown shoes"
	desc = "advanced clown shoes that protect the wearer and render them nearly immune to slipping on their own peels. They also squeak at 100% capacity."
	clothing_flags = NOSLIP
	slowdown = SHOES_SLOWDOWN
	armor_type = /datum/armor/clown_shoes_combat
	strip_delay = 70
	resistance_flags = NONE

/obj/item/clothing/shoes/clown_shoes/combat/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/shoes)

/// Recharging rate in PPS (peels per second)
#define BANANA_SHOES_RECHARGE_RATE 17
#define BANANA_SHOES_MAX_CHARGE 3000

/datum/armor/clown_shoes_combat
	melee = 25
	bullet = 25
	laser = 25
	energy = 25
	bomb = 50
	bio = 90
	fire = 70
	acid = 50
	stamina = 25
	bleed = 40

//The super annoying version
/obj/item/clothing/shoes/clown_shoes/banana_shoes/combat
	name = "mk-honk combat shoes"
	desc = "The culmination of years of clown combat research, these shoes leave a trail of chaos in their wake. They will slowly recharge themselves over time, or can be manually charged with bananium."
	slowdown = SHOES_SLOWDOWN
	armor_type = /datum/armor/banana_shoes_combat
	strip_delay = 70
	resistance_flags = NONE
	always_noslip = TRUE

/datum/armor/banana_shoes_combat
	melee = 25
	bullet = 25
	laser = 25
	energy = 25
	bomb = 50
	bio = 50
	fire = 90
	acid = 50
	stamina = 25
	bleed = 40

/obj/item/clothing/shoes/clown_shoes/banana_shoes/combat/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/shoes)

	var/datum/component/material_container/bananium = GetComponent(/datum/component/material_container)
	bananium.insert_amount_mat(BANANA_SHOES_MAX_CHARGE, /datum/material/bananium)
	START_PROCESSING(SSobj, src)

/obj/item/clothing/shoes/clown_shoes/banana_shoes/combat/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/shoes/clown_shoes/banana_shoes/combat/process(delta_time)
	var/datum/component/material_container/bananium = GetComponent(/datum/component/material_container)
	var/bananium_amount = bananium.get_material_amount(/datum/material/bananium)
	if(bananium_amount < BANANA_SHOES_MAX_CHARGE)
		bananium.insert_amount_mat(min(BANANA_SHOES_RECHARGE_RATE * delta_time, BANANA_SHOES_MAX_CHARGE - bananium_amount), /datum/material/bananium)

/obj/item/clothing/shoes/clown_shoes/banana_shoes/combat/attack_self(mob/user)
	ui_action_click(user)

#undef BANANA_SHOES_RECHARGE_RATE
#undef BANANA_SHOES_MAX_CHARGE

//BANANIUM SWORD

/obj/item/melee/transforming/energy/sword/bananium
	name = "bananium sword"
	desc = "An elegant weapon, for a more civilized age."
	force = 0
	bleed_force = 0
	bleed_force_on = 0
	throwforce = 0
	force_on = 0
	throwforce_on = 0
	hitsound = null
	attack_verb_on = list("slips")
	clumsy_check = FALSE
	sharpness = BLUNT
	sword_color = "yellow"
	heat = 0
	light_color = "#ffff00"
	var/next_trombone_allowed = 0

/obj/item/melee/transforming/energy/sword/bananium/Initialize(mapload)
	. = ..()
	adjust_slipperiness()

/* Adds or removes a slippery component, depending on whether the sword
 * is active or not.
 */
/obj/item/melee/transforming/energy/sword/proc/adjust_slipperiness()
	if(active)
		AddComponent(/datum/component/slippery, 60, GALOSHES_DONT_HELP)
	else
		qdel(GetComponent(/datum/component/slippery))

/obj/item/melee/transforming/energy/sword/bananium/attack(mob/living/M, mob/living/user)
	..()
	if(active)
		var/datum/component/slippery/slipper = GetComponent(/datum/component/slippery)
		slipper.Slip(src, M)

/obj/item/melee/transforming/energy/sword/bananium/throw_impact(atom/hit_atom, throwingdatum)
	. = ..()
	if(active)
		var/datum/component/slippery/slipper = GetComponent(/datum/component/slippery)
		slipper.Slip(src, hit_atom)

/obj/item/melee/transforming/energy/sword/bananium/attackby(obj/item/I, mob/living/user, params)
	if((world.time > next_trombone_allowed) && istype(I, /obj/item/melee/transforming/energy/sword/bananium))
		next_trombone_allowed = world.time + 50
		to_chat(user, "You slap the two swords together. Sadly, they do not seem to fit.")
		playsound(src, 'sound/misc/sadtrombone.ogg', 50)
		return TRUE
	return ..()

/obj/item/melee/transforming/energy/sword/bananium/transform_weapon(mob/living/user, supress_message_text)
	. = ..()
	adjust_slipperiness()

/obj/item/melee/transforming/energy/sword/bananium/ignition_effect(atom/A, mob/user)
	return ""

/obj/item/melee/transforming/energy/sword/bananium/suicide_act(mob/living/user)
	if(!active)
		transform_weapon(user, TRUE)
	user.visible_message(span_suicide("[user] is [pick("slitting [user.p_their()] stomach open with", "falling on")] [src]! It looks like [user.p_theyre()] trying to commit seppuku, but the blade slips off of [user.p_them()] harmlessly!"))
	var/datum/component/slippery/slipper = GetComponent(/datum/component/slippery)
	slipper.Slip(src, user)
	return SHAME

//BANANIUM SHIELD

/obj/item/shield/energy/bananium
	name = "bananium energy shield"
	desc = "A shield that stops most melee attacks, protects user from almost all energy projectiles, and can be thrown to slip opponents."
	throw_speed = 1
	clumsy_check = 0
	base_icon_state = "bananaeshield"
	force = 0
	throwforce = 0
	throw_range = 5
	on_force = 0
	on_throwforce = 0
	on_throw_speed = 1

/obj/item/shield/energy/bananium/Initialize(mapload)
	. = ..()
	adjust_slipperiness()

/* Adds or removes a slippery component, depending on whether the shield
 * is active or not.
 */
/obj/item/shield/energy/bananium/proc/adjust_slipperiness()
	if(active)
		AddComponent(/datum/component/slippery, 60, GALOSHES_DONT_HELP)
	else
		qdel(GetComponent(/datum/component/slippery))

/obj/item/shield/energy/bananium/attack_self(mob/living/carbon/human/user)
	. = ..()
	adjust_slipperiness()

/obj/item/shield/energy/bananium/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, force, quickstart = TRUE)
	if(active)
		if(iscarbon(thrower))
			var/mob/living/carbon/C = thrower
			C.throw_mode_on(THROW_MODE_TOGGLE) //so they can catch it on the return.
	return ..()

/obj/item/shield/energy/bananium/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(active)
		var/caught = hit_atom.hitby(src, FALSE, FALSE, throwingdatum=throwingdatum)
		if(iscarbon(hit_atom) && !caught)//if they are a carbon and they didn't catch it
			var/datum/component/slippery/slipper = GetComponent(/datum/component/slippery)
			slipper.Slip(src, hit_atom)
		var/mob/thrown_by = thrownby?.resolve()
		if(thrown_by && !caught)
			addtimer(CALLBACK(src, TYPE_PROC_REF(/atom/movable, throw_at), thrown_by, throw_range+2, throw_speed, null, TRUE), 1)
	else
		return ..()


//BOMBANANA]

/obj/item/seeds/banana/bombanana
	name = "pack of bombanana seeds"
	desc = "They're seeds that grow into bombanana trees. When grown, give to the clown."
	plantname = "Bombanana Tree"
	product = /obj/item/food/grown/banana/bombanana

/obj/item/food/grown/banana/bombanana
	trash_type = /obj/item/grown/bananapeel/bombanana
	seed = /obj/item/seeds/banana/bombanana
	tastes = list("explosives" = 10)
	food_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 1)

/obj/item/grown/bananapeel/bombanana
	desc = "A peel from a banana. Why is it beeping?"
	seed = /obj/item/seeds/banana/bombanana
	var/det_time = 50
	var/obj/item/grenade/syndieminibomb/bomb

/obj/item/grown/bananapeel/bombanana/Initialize(mapload)
	. = ..()
	bomb = new /obj/item/grenade/syndieminibomb(src)
	bomb.det_time = det_time
	if(iscarbon(loc))
		to_chat(loc, "[src] begins to beep.")
		var/mob/living/carbon/C = loc
		C.throw_mode_on(THROW_MODE_TOGGLE)
	bomb.preprime(loc, null, FALSE)

/obj/item/grown/bananapeel/bombanana/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/slippery, det_time)

/obj/item/grown/bananapeel/bombanana/Destroy()
	. = ..()
	QDEL_NULL(bomb)

/obj/item/grown/bananapeel/bombanana/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is deliberately slipping on the [src.name]! It looks like \he's trying to commit suicide."))
	playsound(loc, 'sound/misc/slip.ogg', 50, 1, -1)
	bomb.preprime(user, 0, FALSE)
	return BRUTELOSS

//TEARSTACHE GRENADE

/obj/item/grenade/chem_grenade/teargas/moustache
	name = "tear-stache grenade"
	desc = "A handsomely-attired teargas grenade."
	icon_state = "moustacheg"
	clumsy_check = GRENADE_NONCLUMSY_FUMBLE

/obj/item/grenade/chem_grenade/teargas/moustache/prime(mob/living/lanced_by)
	var/myloc = get_turf(src)
	. = ..()
	for(var/mob/living/carbon/M in hearers(6, myloc))
		if(!istype(M.wear_mask, /obj/item/clothing/mask/gas/clown_hat) && !istype(M.wear_mask, /obj/item/clothing/mask/gas/mime) )
			if(!M.wear_mask || M.dropItemToGround(M.wear_mask))
				var/obj/item/clothing/mask/fakemoustache/sticky/the_stash = new /obj/item/clothing/mask/fakemoustache/sticky()
				M.equip_to_slot_or_del(the_stash, ITEM_SLOT_MASK, TRUE, TRUE, TRUE, TRUE)

/obj/item/clothing/mask/fakemoustache/sticky
	var/unstick_time = 600

/obj/item/clothing/mask/fakemoustache/sticky/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, STICKY_MOUSTACHE_TRAIT)
	addtimer(CALLBACK(src, PROC_REF(unstick)), unstick_time)

/obj/item/clothing/mask/fakemoustache/sticky/proc/unstick()
	REMOVE_TRAIT(src, TRAIT_NODROP, STICKY_MOUSTACHE_TRAIT)
