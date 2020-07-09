/obj/machinery/computer/hypnomachine
	name = "\improper psychophysiological hypnosis console"
	desc = "Used to brainwash sentient species into a state of altered self-identification. Due to high power tesla coils being used, the brainwashing may affect people nearby the patient."
	icon_screen = "ratvar3"
	icon_keyboard = "syndie_key"

	var/locked = TRUE
	var/mob/living/carbon/human/target
	var/brainwash_objective = ""

/obj/machinery/computer/hypnomachine/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = default_state)
  ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
  if(!ui)
    ui = new(user, src, ui_key, "Hypnoconsole", name, 300, 300, master_ui, state)
    ui.open()

/obj/machinery/computer/hypnomachine/ui_data(mob/user)
	var/list/data = list()
	data["brainwash_objective"] = null
	data["error"] = null
	if(!target)
		data["error"] = "pooping frog exception"
	else
		data["target"] = target.name

	return data
