//Status effects are used to apply temporary or permanent effects to mobs. Mobs are aware of their status effects at all times.
//This file contains their code, plus code for applying and removing them.
//When making a new status effect, add a define to status_effects.dm in __DEFINES for ease of use!

/datum/status_effect
	/// The ID of the effect. ID is used in adding and removing effects to check for duplicates, among other things.
	var/id = "effect"
	/// When set initially / in on_creation, this is how long the status effect lasts in deciseconds.
	/// While processing, this becomes the world.time when the status effect will expire.
	/// -1 = infinite duration.
	var/duration = -1
	/// When set initially / in on_creation, this is how long between [proc/tick] calls in deciseconds.
	/// While processing, this becomes the world.time when the next tick will occur.
	/// -1 = will stop processing, if duration is also unlimited (-1).
	var/tick_interval = 1 SECONDS
	/// The mob affected by the status effect.
	var/mob/living/owner
	/// How many of the effect can be on one mob, and/or what happens when you try to add a duplicate.
	var/status_type = STATUS_EFFECT_UNIQUE
	/// If TRUE, we call [proc/on_remove] when owner is deleted. Otherwise, we call [proc/be_replaced].
	var/on_remove_on_mob_delete = FALSE
	//If defined, this text will appear when the mob is examined - to use he, she etc. use "SUBJECTPRONOUN" and replace it in the examines themselves
	var/examine_text
	/// The typepath to the alert thrown by the status effect when created.
	/// Status effect "name"s and "description"s are shown to the owner here.
	var/alert_type = /atom/movable/screen/alert/status_effect
	/// The alert itself, created in [proc/on_creation] (if alert_type is specified).
	var/atom/movable/screen/alert/status_effect/linked_alert
	/// While enabled, the duration of the status effect will show alongside the icon.
	/// Regardless of what this value is set to, duration will not display if a linked alert is not set
	var/show_duration = TRUE
	var/last_shown_duration = 0

/datum/status_effect/New(list/arguments)
	on_creation(arglist(arguments))

/datum/status_effect/proc/on_creation(mob/living/new_owner, ...)
	if(new_owner)
		owner = new_owner
	if(QDELETED(owner) || !on_apply())
		qdel(src)
		return
	if(owner)
		LAZYADD(owner.status_effects, src)

	if(duration != -1)
		duration = world.time + duration
	tick_interval = world.time + tick_interval

	if(alert_type)
		var/atom/movable/screen/alert/status_effect/A = owner.throw_alert(id, alert_type)
		A.attached_effect = src //so the alert can reference us, if it needs to
		linked_alert = A //so we can reference the alert, if we need to

	update_icon()
	if(duration > 0 || initial(tick_interval) > 0) //don't process if we don't care
		START_PROCESSING(SSfastprocess, src)

	return TRUE

/datum/status_effect/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	if(owner)
		linked_alert = null
		owner.clear_alert(id)
		LAZYREMOVE(owner.status_effects, src)
		on_remove()
		owner = null
	return ..()

/datum/status_effect/process()
	if(!owner)
		qdel(src)
		return
	var/needs_update = last_shown_duration != CEILING((duration - world.time) / 10, 1)
	if(tick_interval < world.time)
		tick()
		tick_interval = world.time + initial(tick_interval)
		needs_update = TRUE
	if (needs_update)
		update_icon()
	if(duration != -1 && duration < world.time)
		qdel(src)

/datum/status_effect/proc/on_apply() //Called whenever the buff is applied; returning FALSE will cause it to autoremove itself.
	return TRUE

/// Called every tick from process().
/datum/status_effect/proc/tick()
	return

/// Called whenever the buff expires or is removed (qdeleted)
/// Note that at the point this is called, it is out of the
/// owner's status_effects list, but owner is not yet null
/datum/status_effect/proc/on_remove()
	return

/// Called instead of on_remove when a status effect
/// of status_type STATUS_EFFECT_REPLACE is replaced by itself,
/// or when a status effect with on_remove_on_mob_delete
/// set to FALSE has its mob deleted
/datum/status_effect/proc/be_replaced() //Called instead of on_remove when a status effect is replaced by itself or when a status effect with on_remove_on_mob_delete = FALSE has its mob deleted
	linked_alert = null
	owner.clear_alert(id)
	LAZYREMOVE(owner.status_effects, src)
	owner = null
	qdel(src)

/datum/status_effect/proc/before_remove() //! Called before being removed; returning FALSE will cancel removal
	return TRUE

/datum/status_effect/proc/refresh(effect, ...)
	var/original_duration = initial(duration)
	if(original_duration == -1)
		return
	duration = world.time + original_duration

/// Merge this status effect by applying new arguments
/datum/status_effect/proc/merge(...)
	return

/datum/status_effect/proc/get_examine_text() //Called when the owner is examined
	return examine_text

//clickdelay/nextmove modifiers!
/datum/status_effect/proc/nextmove_modifier()
	return 1

/datum/status_effect/proc/nextmove_adjust()
	return 0

/datum/status_effect/proc/update_icon()
	if (!linked_alert || !show_duration || duration <= 0)
		return
	last_shown_duration = CEILING((duration - world.time) / 10, 1)
	linked_alert.maptext = MAPTEXT("[last_shown_duration]s")

////////////////
// ALERT HOOK //
////////////////

/atom/movable/screen/alert/status_effect
	name = "Curse of Mundanity"
	desc = "You don't feel any different..."
	var/datum/status_effect/attached_effect

/atom/movable/screen/alert/status_effect/Destroy()
	attached_effect = null //Don't keep a ref now
	return ..()

//////////////////
// HELPER PROCS //
//////////////////

/mob/living/proc/apply_status_effect(effect, ...) //applies a given status effect to this mob, returning the effect if it was successful
	. = FALSE
	var/datum/status_effect/S1 = effect
	LAZYINITLIST(status_effects)
	var/list/arguments = args.Copy()
	arguments[1] = src
	for(var/datum/status_effect/S in status_effects)
		if(S.id == initial(S1.id) && S.status_type)
			if(S.status_type == STATUS_EFFECT_REPLACE)
				S.be_replaced()
			else if(S.status_type == STATUS_EFFECT_REFRESH)
				S.refresh(arglist(arguments))
				return
			else if (S.status_type == STATUS_EFFECT_MERGE)
				S.merge(arglist(args.Copy(2)))
				S.update_icon()
				return
			else
				return
	S1 = new effect(arguments)
	. = S1

/mob/living/proc/remove_status_effect(effect, ...) //removes all of a given status effect from this mob, returning TRUE if at least one was removed
	. = FALSE
	var/list/arguments = args.Copy(2)
	if(status_effects)
		var/datum/status_effect/S1 = effect
		for(var/datum/status_effect/S in status_effects)
			if(initial(S1.id) == S.id && S.before_remove(arguments))
				qdel(S)
				. = TRUE

/mob/living/proc/has_status_effect(effect) //returns the effect if the mob calling the proc owns the given status effect
	. = FALSE
	if(status_effects)
		var/datum/status_effect/S1 = effect
		for(var/datum/status_effect/S in status_effects)
			if(initial(S1.id) == S.id)
				return S

/mob/living/proc/has_status_effect_list(effect) //returns a list of effects with matching IDs that the mod owns; use for effects there can be multiple of
	. = list()
	if(status_effects)
		var/datum/status_effect/S1 = effect
		for(var/datum/status_effect/S in status_effects)
			if(initial(S1.id) == S.id)
				. += S

/// Status effect from multiple sources, when all sources are removed, so is the effect
/datum/status_effect/grouped
	status_type = STATUS_EFFECT_MULTIPLE //! Adds itself to sources and destroys itself if one exists already, there are never multiple
	var/list/sources = list()

/datum/status_effect/grouped/on_creation(mob/living/new_owner, source)
	var/datum/status_effect/grouped/existing = new_owner.has_status_effect(type)
	if(existing)
		existing.sources |= source
		qdel(src)
		return FALSE
	else
		sources |= source
		return ..()

/datum/status_effect/grouped/before_remove(source)
	sources -= source
	return !length(sources)
