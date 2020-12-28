/obj/item/implant/hazard
	name = "hazard training implant"
	desc = "This implant allows to automatically put on your skinsuit and internals, albeit very slowly."
	actions_types = list(/datum/action/item_action/hazard_implant)
	icon_state = "hazard"
	implant_color = "r"


/obj/item/implant/hazard/activate()
	. = ..()
	to_chat(imp_in, "<span class='hear'>You feel a faint click.</span>")
	if(iscarbon(imp_in))
		var/mob/living/carbon/C_imp_in = imp_in
		if(ishuman(imp_in))
			var/mob/living/carbon/human/H = C_imp_in
			H.visible_message("<span class='notice'>[H] starts to slowly don atmospheric hazard gear on [t_himself]...</span>", "<span class='notice'>You begin putting on your atmospheric hazard gear on yourself, stand still...</span>")
			if(do_after(H, 20, TRUE, H, TRUE))
				//here be dragons
				//here goes the putting stuff on.
				if(subtypesof(/obj/item/clothing/suit/space, /obj/item/clothing/suit/fire))
				H.
				/obj/item/clothing/suit/space/skinsuit)
					H.dropItemToGround(H.get_item_by_slot(SLOT_WEAR_SUIT))
				H
				if(
				H.contents



	if(iscarbon(imp_in))
		var/mob/living/carbon/C_imp_in = imp_in
		C_imp_in.uncuff()
	if(!uses)
		qdel(src)


/obj/item/implant/hazard/get_data()
	var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> NT Atmospheric Hazard Training Implant<BR>
<HR>
<b>Implant Details:</b> <BR>
<b>Function:</b> Emits neural signal sequence that helps the user to put on internals and airtight exowear properly, but slowly.<BR>
<b>Special Features:</b><BR>
<i>Neuro-Scan</i>- Analyzes certain shadow signals in the nervous system<BR>
<HR>
No Implant Specifics"}
	return dat


/obj/item/implanter/hazard
	name = "implanter (hazard trainer)"
	imp_type = /obj/item/implant/hazard

/obj/item/implantcase/hazard
	name = "implant case - 'Hazard Trainer'"
	desc = "A glass case containing a hazard training implant."
	imp_type = /obj/item/implant/hazard
