/mob/living
	var/isfishing = FALSE

/obj/item/food/fish
	desc = "Marine life."
	icon = 'code/modules/ziggers/48x32weapons.dmi'
	onflooricon = 'code/modules/ziggers/onfloor.dmi'
	w_class = WEIGHT_CLASS_SMALL
	eatsound = 'code/modules/ziggers/sounds/eat.ogg'
	tastes = list("fish" = 1)
	food_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/protein = 3)
	foodtypes = RAW | MEAT

/obj/item/food/fish/shark
	name = "leopard shark"
	icon_state = "fish1"

/obj/item/food/fish/tune
	name = "tune"
	icon_state = "fish2"

/obj/item/food/fish/catfish
	name = "catfish"
	icon_state = "fish3"

/obj/item/food/fish/crab
	name = "crab"
	icon_state = "fish4"

/obj/item/fishing_rod
	name = "fishing rod"
	icon_state = "fishing"
	icon = 'code/modules/ziggers/items.dmi'
	onflooricon = 'code/modules/ziggers/onfloor.dmi'
	w_class = WEIGHT_CLASS_BULKY
	lefthand_file = 'code/modules/ziggers/righthand.dmi'
	righthand_file = 'code/modules/ziggers/lefthand.dmi'
	var/catching = FALSE

/obj/item/fishing_rod/attack_self(mob/user)
	. = ..()
	if(isturf(user.loc))
		forceMove(user.loc)
		onflooricon = 'code/modules/ziggers/64x64.dmi'
		icon = 'code/modules/ziggers/64x64.dmi'
		dir = user.dir
		anchored = TRUE

/obj/item/fishing_rod/MouseDrop(atom/over_object)
	. = ..()
	if(isturf(loc))
		if(istype(over_object, /mob/living))
			if(get_dist(src, over_object) < 2)
				if(anchored)
					anchored = FALSE
					onflooricon = initial(onflooricon)
					icon = onflooricon

/obj/item/fishing_rod/attack_hand(mob/living/user)
	if(anchored)
		if(!istype(get_step(src, dir), /turf/open/floor/plating/vampocean))
			return
		if(user.isfishing)
			return
		if(!catching)
			catching = TRUE
			user.isfishing = TRUE
			playsound(loc, 'code/modules/ziggers/sounds/catching.ogg', 50, FALSE)
			if(do_mob(user, src, 15 SECONDS))
				catching = FALSE
				user.isfishing = FALSE
				if(prob(33))
					var/IT = pick(/obj/item/food/fish/shark,
									/obj/item/food/fish/tune,
									/obj/item/food/fish/catfish,
									/obj/item/food/fish/crab)
					var/i = rand(1, 1000)
					if(i == 1000)
						IT = /obj/item/vtm_artifact/rand
					new IT(user.loc)
					playsound(loc, 'code/modules/ziggers/sounds/catched.ogg', 50, FALSE)
					if(user.key)
						var/datum/preferences/P = GLOB.preferences_datums[ckey(user.key)]
						if(P)
							P.exper = min(calculate_mob_max_exper(user), P.exper+10)
				else
					to_chat(user, "<span class='warning'>Nothing!</span>")
			else
				catching = FALSE
				user.isfishing = FALSE
		return
	..()