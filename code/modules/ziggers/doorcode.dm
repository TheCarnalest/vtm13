/obj/item/vamp/keys
	name = "\improper keys"
	desc = "Those can open some doors."
	icon = 'code/modules/ziggers/items.dmi'
	icon_state = "keys"
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_TINY
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	onflooricon = 'code/modules/ziggers/onfloor.dmi'

	var/list/accesslocks = list("nothing")
	var/roundstart_fix = FALSE

/obj/item/vamp/keys/camarilla
	name = "Camarilla keys"
	accesslocks = list("camarilla")
	color = "#bd3327"

/obj/item/vamp/keys/prince
	name = "Prince's keys"
	accesslocks = list("camarilla",
											"prince",
											"clerk",
											"archive")
	color = "#bd3327"

/obj/item/vamp/keys/sheriff
	name = "Sheriff's keys"
	accesslocks = list("camarilla",
											"prince",
											"archive")
	color = "#bd3327"

/obj/item/vamp/keys/clerk
	name = "Clerk's keys"
	accesslocks = list("camarilla",
											"clerk",
											"archive")
	color = "#bd3327"

/obj/item/vamp/keys/graveyard
	name = "Graveyard keys"
	accesslocks = list("graveyard")

/obj/item/vamp/keys/clinic
	name = "Clinic keys"
	accesslocks = list("clinic")

/obj/item/vamp/keys/cleaning
	name = "Cleaning keys"
	accesslocks = list("cleaning")

/obj/item/vamp/keys/archive
	name = "Archive keys"
	accesslocks = list("archive")

/obj/item/vamp/keys/anarch
	name = "Anarch keys"
	accesslocks = list("anarch")
	color = "#434343"

/obj/item/vamp/keys/bar
	name = "Barkeeper keys"
	accesslocks = list("bar",
											"anarch",
											"supply")
	color = "#434343"

/obj/item/vamp/keys/supply
	name = "Supply keys"
	accesslocks = list("supply",
											"anarch")
	color = "#434343"

/obj/item/vamp/keys/npc
	name = "Some keys"
	accesslocks = list("npc")

/obj/item/vamp/keys/npc/Initialize()
	. = ..()
	accesslocks = list("npc[rand(1, 20)]")

/obj/item/vamp/keys/npc/fix
	roundstart_fix = TRUE

/obj/item/vamp/keys/police
	name = "Police keys"
	accesslocks = list("police")

/obj/item/vamp/keys/strip
	name = "Strip keys"
	accesslocks = list("strip")

/obj/item/vamp/keys/giovanni
	name = "Mafia keys"
	accesslocks = list("giovanni")

/obj/item/vamp/keys/taxi
	name = "Taxi keys"
	accesslocks = list("taxi")
	color = "#fffb8b"

/obj/structure/vampdoor
	name = "\improper door"
	desc = "It opens and closes."
	icon = 'code/modules/ziggers/doors.dmi'
	icon_state = "door-1"
	plane = GAME_PLANE
	layer = ABOVE_ALL_MOB_LAYER
	pixel_w = -16
	anchored = TRUE
	density = TRUE
	opacity = TRUE

	var/baseicon = "door"
	var/lastclicked = 0

	var/closed = TRUE
	var/locked = FALSE
	var/lock_id = "nothing"
	var/glass = FALSE
	var/hackable = TRUE
	var/hacking = FALSE

	var/open_sound = 'code/modules/ziggers/sounds/door_open.ogg'
	var/close_sound = 'code/modules/ziggers/sounds/door_close.ogg'
	var/lock_sound = 'code/modules/ziggers/sounds/door_locked.ogg'

/obj/structure/vampdoor/attack_hand(mob/user)
	if(lastclicked+5 > world.time)
		return
	lastclicked = world.time
	if(locked)
		playsound(src, lock_sound, 75, TRUE)
		to_chat(user, "<span class='warning'>[src] is locked!</span>")
		return

	if(closed)
		playsound(src, open_sound, 75, TRUE)
		icon_state = "[baseicon]-0"
		density = FALSE
		opacity = FALSE
		layer = OPEN_DOOR_LAYER
		to_chat(user, "<span class='notice'>You open [src].</span>")
		closed = FALSE
	else
		for(var/mob/living/L in src.loc)
			if(L)
				playsound(src, lock_sound, 75, TRUE)
				to_chat(user, "<span class='warning'>[L] is preventing you from closing [src].</span>")
				return
		playsound(src, close_sound, 75, TRUE)
		icon_state = "[baseicon]-1"
		density = TRUE
		if(!glass)
			opacity = TRUE
		layer = ABOVE_ALL_MOB_LAYER
		to_chat(user, "<span class='notice'>You close [src].</span>")
		closed = TRUE

/obj/structure/vampdoor/attackby(obj/item/W, mob/living/user, params)
	if(lastclicked+5 > world.time)
		return
	lastclicked = world.time
	if(istype(W, /obj/item/vamp/keys/hack))
		if(locked)
			if(hackable || HAS_TRAIT(user, TRAIT_BONE_KEY))
				hacking = TRUE
				playsound(src, 'code/modules/ziggers/sounds/hack.ogg', 100, TRUE)
				for(var/mob/living/carbon/human/npc/police/P in range(7, src))
					if(P)
						P.Aggro(user)
				if(do_mob(user, src, 7 SECONDS))
					if(prob(50) || HAS_TRAIT(user, TRAIT_BONE_KEY))
						to_chat(user, "<span class='notice'>You pick the lock.</span>")
						locked = FALSE
						hacking = FALSE
						return
					else
						to_chat(user, "<span class='warning'>You failed to pick the lock.</span>")
						hacking = FALSE
						return
				else
					to_chat(user, "<span class='warning'>You failed to pick the lock.</span>")
					hacking = FALSE
					return
			else
				to_chat(user, "<span class='warning'>This lock is too complicated to pick.</span>")
				return
		else
			return
	else if(istype(W, /obj/item/vamp/keys))
		var/obj/item/vamp/keys/KEY = W
		if(KEY.roundstart_fix)
			lock_id = pick(KEY.accesslocks)
			KEY.roundstart_fix = FALSE
		if(KEY.accesslocks)
			for(var/i in KEY.accesslocks)
				if(i == lock_id)
					if(!locked)
						playsound(src, lock_sound, 75, TRUE)
						to_chat(user, "[src] is now locked.")
						locked = TRUE
					else
						playsound(src, lock_sound, 75, TRUE)
						to_chat(user, "[src] is now unlocked.")
						locked = FALSE

/obj/item/vamp/keys/hack
	name = "\improper lockpick"
	desc = "Those can open some doors. Illegaly..."
	icon_state = "hack"
	item_flags = NOBLUDGEON

/obj/structure/vampdoor/old
	icon_state = "old-1"
	baseicon = "old"

/obj/structure/vampdoor/simple
	icon_state = "cam-1"
	baseicon = "cam"

/obj/structure/vampdoor/reinf
	icon_state = "reinf-1"
	baseicon = "reinf"

/obj/structure/vampdoor/prison
	icon_state = "prison-1"
	opacity = FALSE
	baseicon = "prison"
	glass = TRUE

/obj/structure/vampdoor/wood
	icon_state = "wood-1"
	baseicon = "wood"

/obj/structure/vampdoor/wood/old
	icon_state = "oldwood-1"
	baseicon = "oldwood"

/obj/structure/vampdoor/glass
	icon_state = "glass-1"
	opacity = FALSE
	baseicon = "glass"
	glass = TRUE

/obj/structure/vampdoor/shop
	icon_state = "shop-1"
	opacity = FALSE
	baseicon = "shop"
	glass = TRUE

/obj/structure/vampdoor/camarilla
	icon_state = "cam-1"
	baseicon = "cam"
	locked = TRUE
	lock_id = "camarilla"
	hackable = FALSE

/obj/structure/vampdoor/clerk
	icon_state = "shop-1"
	opacity = FALSE
	baseicon = "shop"
	glass = TRUE
	locked = TRUE
	lock_id = "clerk"

/obj/structure/vampdoor/prince
	icon_state = "glass-1"
	opacity = FALSE
	baseicon = "glass"
	glass = TRUE
	locked = TRUE
	lock_id = "prince"
	hackable = FALSE

/obj/structure/vampdoor/graveyard
	icon_state = "oldwood-1"
	baseicon = "oldwood"
	locked = TRUE
	lock_id = "graveyard"

/obj/structure/vampdoor/clinic
	icon_state = "shop-1"
	opacity = FALSE
	baseicon = "shop"
	glass = TRUE
	locked = TRUE
	lock_id = "clinic"

/obj/structure/vampdoor/cleaning
	icon_state = "reinf-1"
	baseicon = "reinf"
	locked = TRUE
	lock_id = "cleaning"

/obj/structure/vampdoor/archive
	icon_state = "old-1"
	baseicon = "old"
	locked = TRUE
	lock_id = "archive"
	hackable = FALSE

/obj/structure/vampdoor/anarch
	icon_state = "cam-1"
	baseicon = "cam"
	locked = TRUE
	lock_id = "anarch"

/obj/structure/vampdoor/bar
	icon_state = "cam-1"
	baseicon = "cam"
	locked = TRUE
	lock_id = "bar"
	hackable = FALSE

/obj/structure/vampdoor/supply
	icon_state = "cam-1"
	baseicon = "cam"
	locked = TRUE
	lock_id = "supply"

/obj/structure/vampdoor/npc
	icon_state = "wood-1"
	baseicon = "wood"
	locked = TRUE
	lock_id = "npc"

/obj/structure/vampdoor/npc/Initialize()
	. = ..()
	lock_id = "npc[rand(1, 20)]"

/obj/structure/vampdoor/police
	icon_state = "cam-1"
	baseicon = "cam"
	locked = TRUE
	lock_id = "police"

/obj/structure/vampdoor/prison
	icon_state = "prison-1"
	baseicon = "prison"
	locked = TRUE
	glass = TRUE
	hackable = FALSE
	lock_id = "police"

/obj/structure/vampdoor/strip
	icon_state = "cam-1"
	baseicon = "cam"
	locked = TRUE
	lock_id = "strip"

/obj/structure/vampdoor/giovanni
	icon_state = "wood-1"
	baseicon = "wood"
	locked = TRUE
	lock_id = "giovanni"