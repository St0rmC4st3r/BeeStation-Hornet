/obj/item/gun/energy/laser/improvised
	name = "imrprovised laser rifle"
	desc = "A laser rifle, clearly made of what was at hand. It seems completely unreliable. You might be able use it properly only if you know what you are doing."
	icon_state = "laser"
	item_state = "laser"
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(/datum/material/iron=2000)
	ammo_type = list(/obj/item/ammo_casing/energy/laser/unstable)
	ammo_x_offset = 1
	shaded_charge = 1

    var/chambered_charge = 0            //determines how much charge is currently chambered in the capacitor
    var/capacitor_capacity = 0          //determines how much charge the capacitor can handle before exploding
    var/charge_transfer_rate = 0        //determines how much charge is transfered from the cell to the capacitor. It depends on the capacitor and current cell charge.
    var/incompetence_charge_loss = 5    //coefficient that multiplies the charge used to charge the capacitor if you are not: the creator, an engineer, a scientist, a roboticist, CE, RD.
    var/list/competent_personnel = list()   //TODO: Jobs go here
    var/damage = 0                      //damage to be set in the ammo casing. Because of the way the guns are coded.