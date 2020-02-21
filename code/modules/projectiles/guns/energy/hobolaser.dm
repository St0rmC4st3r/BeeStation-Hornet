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

	//parts

	var/obj/item/stock_parts/capacitor/capacitor = null
	var/obj/item/stock_parts/micro_laser/laser = null
	var/obj/item/stock_parts/cell/cell = null

	var/owner = null					//original crafter. To be set during init
    var/chambered_charge = 0            //determines how much charge is currently chambered in the capacitor
    var/capacitor_capacity = 0          //determines how much charge the capacitor can handle before exploding
    var/charge_transfer_rate = 0        //determines how much charge is transfered from the cell to the capacitor. It depends on the capacitor and current cell charge.
    var/incompetence_charge_loss = 3    //coefficient that multiplies the charge used to charge the capacitor if you are not: the creator, an engineer, a scientist, a roboticist, CE, RD.
    var/list/competent_personnel = list()   //TODO: Jobs go here
    var/maximum_damage = 0              //maximum damage the laser can output.
    var/damage = 0                      //damage to be set in the ammo casing. Because of the way the guns are coded.
    

/obj/item/gun/energy/laser/improvised/proc/crank(mob/user/M)
	if(!capacitor)
		to_chat(M, "<span class='notice'>There is no capacitor installed!</span>")
		return
	if(!cell)
		to_chat(M, "<span class='notice'>There is no power cell installed!</span>")
		return
	var/user_incompetent = (!(M.Job in competent_personnel) && !(M.mind = owner))
	var/transferable_charge = capacitor.rating*150 + (cell.charge/capacitor_capacity)*20 //Using a T1 capacitor with a bluespace cell is not the best idea idea.
	var/consumable_charge = transferable_charge
	
	if(user_incompetent) //You do not know how to channel just the right ammount of charge
		transferable_charge += rand(-capacitor.rating*100, capacitor.rating*100)
		consumable_charge = transferable_charge * incompetence_charge_loss
	
	if(cell.charge<consumable_charge)
		if(user_incompetent)
			chambered_charge += cell.charge/incompetence_charge_loss
			cell.use(cell.charge)
		else
			chambered_charge += cell.charge
			cell.use(cell.charge)
	else
		chambered_charge += consumable_charge
		cell.use(consumable_charge)

	if(chambered_charge>capacitor_capacity*1.5)
		//TODO make_capacitor_explode and burn your ass.

		