/obj/structure/weedshit
	name = "hydroponics"
	desc = "Definitely not for the weed."
	icon = 'code/modules/ziggers/weed.dmi'
	icon_state = "soil_dry0"
	plane = GAME_PLANE
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE
	density = TRUE
	var/wet = FALSE
	var/weeded = 0
	var/health = 3

/obj/structure/weedshit/examine(mob/user)
	. = ..()
	if(!wet)
		. += "<span class='warning'>[src] is dry!</span>"
	if(weeded == 5)
		. += "<span class='warning'>The crop is dead!</span>"
	else
		if(health <= 2)
			. += "<span class='warning'>The crop is looking unhealthy.</span>"

/obj/item/weedseed
	name = "seed"
	desc = "Green and smelly..."
	icon_state = "seed"
	icon = 'code/modules/ziggers/items.dmi'
	w_class = WEIGHT_CLASS_SMALL

/obj/item/weedpack
	name = "green package"
	desc = "Green and smelly..."
	icon_state = "package_weed"
	icon = 'code/modules/ziggers/items.dmi'
	w_class = WEIGHT_CLASS_SMALL
	onflooricon = 'code/modules/ziggers/onfloor.dmi'

/datum/crafting_recipe/weed_leaf
	name = "Sort Weed"
	time = 50
	reqs = list(/obj/item/food/vampire/weed = 1)
	result = /obj/item/weedpack
	always_available = TRUE
	category = CAT_DRUGS

/datum/crafting_recipe/weed_blunt
	name = "Roll Blunt"
	time = 50
	reqs = list(/obj/item/weedpack = 1, /obj/item/paper = 1)
	result = /obj/item/clothing/mask/cigarette/rollie/cannabis
	always_available = TRUE
	category = CAT_DRUGS

/obj/item/food/vampire/weed
	name = "leaf"
	desc = "Green and smelly..."
	icon_state = "weed"
	icon = 'code/modules/ziggers/items.dmi'
	onflooricon = 'code/modules/ziggers/onfloor.dmi'
	bite_consumption = 5
	tastes = list("cat piss" = 4, "weed" = 2)
	foodtypes = VEGETABLES
	food_reagents = list(/datum/reagent/drug/space_drugs = 20, /datum/reagent/toxin/lipolicide = 20)
	eat_time = 10

/obj/item/bailer
	name = "bailer"
	desc = "Best for flora!"
	icon_state = "bailer"
	icon = 'code/modules/ziggers/items.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/amount_of_water = 10

/obj/item/bailer/examine(mob/user)
	. = ..()
	if(!amount_of_water)
		. += "<span class='warning'>[src] is empty!</span>"

/obj/structure/weedshit/attack_hand(mob/user)
	. = ..()
	if(weeded == 5)
		weeded = 0
		health = 3
	if(weeded == 4)
		weeded = 1
		new /obj/item/food/vampire/weed(get_turf(user))

/obj/structure/weedshit/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/bailer))
		var/obj/item/bailer/B = W
		if(B.amount_of_water)
			B.amount_of_water = max(0, B.amount_of_water-1)
			wet = TRUE
			to_chat(user, "<span class='notice'>You fill [src] with water.</span>")
			playsound(src, 'sound/effects/refill.ogg', 50, TRUE)
		else
			to_chat(user, "<span class='warning'>[W] is empty!</span>")
	if(istype(W, /obj/item/weedseed))
		if(weeded == 0)
			health = 3
			weeded = 1
			qdel(W)
	update_weed_icon()
	return

/obj/structure/weedshit/Initialize()
	. = ..()
	GLOB.weed_list += src

/obj/structure/weedshit/Destroy()
	. = ..()
	GLOB.weed_list -= src

/obj/structure/weedshit/proc/update_weed_icon()
	icon_state = "soil[wet ? "" : "_dry"][weeded]"

SUBSYSTEM_DEF(smokeweedeveryday)
	name = "Smoke Weed Every Day"
	init_order = INIT_ORDER_DEFAULT
	wait = 1800
	priority = FIRE_PRIORITY_VERYLOW

/datum/controller/subsystem/smokeweedeveryday/fire()
	for(var/obj/structure/weedshit/W in GLOB.weed_list)
		if(W)
			if(W.weeded != 0 && W.weeded != 5)
				if(!W.wet)
					if(W.health)
						W.health = max(0, W.health-1)
					else
						W.weeded = 5
				else if(W.health)
					if(prob(33))
						W.wet = FALSE
					W.health = min(3, W.health+1)
					W.weeded = min(4, W.weeded+1)
			W.update_weed_icon()

/obj/item/bong
	name = "bong"
	desc = "Technically known as a water pipe."
	icon = 'code/modules/ziggers/items.dmi'
	icon_state = "bulbulator"
	inhand_icon_state = "bulbulator"
	onflooricon = 'code/modules/ziggers/onfloor.dmi'

	///The icon state when the bong is lit
	var/icon_on = "bulbulator"
	///The icon state when the bong is not lit
	var/icon_off = "bulbulator"
	///Whether the bong is lit or not
	var/lit = FALSE
	///How many hits can the bong be used for?
	var/max_hits = 4
	///How many uses does the bong have remaining?
	var/bong_hits = 0
	///How likely is it we moan instead of cough?
	var/moan_chance = 0

	///Max units able to be stored inside the bong
	var/chem_volume = 30
	///Is it filled?
	var/packed_item = FALSE

	///How many reagents do we transfer each use?
	var/reagent_transfer_per_use = 0
	///How far does the smoke reach per use?
	var/smoke_range = 2

/obj/item/bong/Initialize(mapload)
	. = ..()
	create_reagents(chem_volume, INJECTABLE | NO_REACT)

/obj/item/bong/attackby(obj/item/used_item, mob/user, params)
	if(istype(used_item, /obj/item/food/grown))
		var/obj/item/food/grown/grown_item = used_item
		if(packed_item)
			to_chat(user, "<span class='warning'>Already packed!</span>")
			return
		if(!HAS_TRAIT(grown_item, TRAIT_DRIED))
			to_chat(user, "<span class='warning'>Needs to be dried!</span>")
			return
		to_chat(user, "<span class='notice'>You stuff [grown_item] into [src].</span>")
		bong_hits = max_hits
		packed_item = TRUE
		if(grown_item.reagents)
			grown_item.reagents.trans_to(src, grown_item.reagents.total_volume)
			reagent_transfer_per_use = reagents.total_volume / max_hits
		qdel(grown_item)
	else if(istype(used_item, /obj/item/weedpack)) //for hash/dabs
		if(packed_item)
			to_chat(user, "<span class='warning'>Already packed!</span>")
			return
		to_chat(user, "<span class='notice'>You stuff [used_item] into [src].</span>")
		bong_hits = max_hits
		packed_item = TRUE
		var/obj/item/food/grown/cannabis/W = new(loc)
		if(W.reagents)
			W.reagents.trans_to(src, W.reagents.total_volume)
			reagent_transfer_per_use = reagents.total_volume / max_hits
		qdel(W)
		qdel(used_item)
	else
		var/lighting_text = used_item.ignition_effect(src, user)
		if(!lighting_text)
			return ..()
		if(bong_hits <= 0)
			to_chat(user, "<span class='warning'>Nothing to smoke!</span>")
			return ..()
		light(lighting_text)
		name = "lit [initial(name)]"

/obj/item/bong/attack_self(mob/user)
	var/turf/location = get_turf(user)
	if(lit)
		user.visible_message("<span class='notice'>[user] puts out [src].</span>", "<span class='notice'>You put out [src].</span>")
		lit = FALSE
		icon_state = icon_off
		inhand_icon_state = icon_off
	else if(!lit && bong_hits > 0)
		to_chat(user, "<span class='notice'>You empty [src] onto [location].</span>")
		new /obj/effect/decal/cleanable/ash(location)
		packed_item = FALSE
		bong_hits = 0
		reagents.clear_reagents()
	return

/obj/item/bong/attack(mob/hit_mob, mob/user, def_zone)
	if(!packed_item || !lit)
		return
	hit_mob.visible_message("<span class='notice'>[user] starts [hit_mob == user ? "taking a hit from [src]." : "forcing [hit_mob] to take a hit from [src]!"]", "[hit_mob == user ? "<span class='notice'>You start taking a hit from [src].</span>" : "<span class='danger'>[user] starts forcing you to take a hit from [src]!</span>"]")
	playsound(src, 'code/modules/ziggers/sounds/heatdam.ogg', 50, TRUE)
	if(!do_after(user, 40, src))
		return
	to_chat(hit_mob, "<span class='notice'>You finish taking a hit from the [src].</span>")
	if(reagents.total_volume)
		reagents.trans_to(hit_mob, reagent_transfer_per_use, methods = VAPOR)
		bong_hits--
	var/turf/open/pos = get_turf(src)
	if(istype(pos))
		for(var/i in 1 to smoke_range)
			spawn_cloud(pos, smoke_range)
	if(moan_chance > 0)
		if(prob(moan_chance))
			playsound(hit_mob, pick('code/modules/ziggers/sounds/lungbust_moan1.ogg','code/modules/ziggers/sounds/lungbust_moan2.ogg', 'code/modules/ziggers/sounds/lungbust_moan3.ogg'), 50, TRUE)
			hit_mob.emote("moan")
		else
			playsound(hit_mob, pick('code/modules/ziggers/sounds/lungbust_cough1.ogg','code/modules/ziggers/sounds/lungbust_cough2.ogg'), 50, TRUE)
			hit_mob.emote("cough")
	if(bong_hits <= 0)
		to_chat(hit_mob, "<span class='warning'>Out of uses!</span>")
		lit = FALSE
		packed_item = FALSE
		icon_state = icon_off
		inhand_icon_state = icon_off
		name = "[initial(name)]"
		reagents.clear_reagents() //just to make sure

/obj/item/bong/proc/light(flavor_text = null)
	if(lit)
		return
	if(!(flags_1 & INITIALIZED_1))
		icon_state = icon_on
		inhand_icon_state = icon_on
		return
	lit = TRUE
	name = "lit [name]"

	if(reagents.get_reagent_amount(/datum/reagent/toxin/plasma)) // the plasma explodes when exposed to fire
		var/datum/effect_system/reagents_explosion/explosion = new()
		explosion.set_up(round(reagents.get_reagent_amount(/datum/reagent/toxin/plasma) * 0.4, 1), get_turf(src), 0, 0)
		explosion.start()
		qdel(src)
		return
	if(reagents.get_reagent_amount(/datum/reagent/fuel)) // the fuel explodes, too, but much less violently
		var/datum/effect_system/reagents_explosion/explosion = new()
		explosion.set_up(round(reagents.get_reagent_amount(/datum/reagent/fuel) * 0.2, 1), get_turf(src), 0, 0)
		explosion.start()
		qdel(src)
		return

	// allowing reagents to react after being lit
	reagents.flags &= ~(NO_REACT)
	reagents.handle_reactions()
	icon_state = icon_on
	inhand_icon_state = icon_on
	if(flavor_text)
		var/turf/bong_turf = get_turf(src)
		bong_turf.visible_message(flavor_text)

/obj/item/bong/proc/spawn_cloud(turf/open/location, smoke_range)
	var/list/turfs_affected = list(location)
	var/list/turfs_to_spread = list(location)
	var/spread_stage = smoke_range
	for(var/i in 1 to smoke_range)
		if(!turfs_to_spread.len)
			break
		var/list/new_spread_list = list()
		for(var/turf/open/turf_to_spread as anything in turfs_to_spread)
			if(isspaceturf(turf_to_spread))
				continue
			var/obj/effect/abstract/fake_steam/fake_steam = locate() in turf_to_spread
			var/at_edge = FALSE
			if(!fake_steam)
				at_edge = TRUE
				fake_steam = new(turf_to_spread)
			fake_steam.stage_up(spread_stage)

			if(!at_edge)
				for(var/turf/open/open_turf as anything in turf_to_spread.atmos_adjacent_turfs)
					if(!(open_turf in turfs_affected))
						new_spread_list += open_turf
						turfs_affected += open_turf

		turfs_to_spread = new_spread_list
		spread_stage--

#define MAX_FAKE_STEAM_STAGES 5
#define STAGE_DOWN_TIME (10 SECONDS)

/// Fake steam effect
/obj/effect/abstract/fake_steam
	layer = FLY_LAYER
	icon = 'icons/effects/atmospherics.dmi'
	icon_state = "water_vapor"
	blocks_emissive = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/next_stage_down = 0
	var/current_stage = 0

/obj/effect/abstract/fake_steam/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/abstract/fake_steam/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/abstract/fake_steam/process()
	if(next_stage_down > world.time)
		return
	stage_down()

#define FAKE_STEAM_TARGET_ALPHA 204

/obj/effect/abstract/fake_steam/proc/update_alpha()
	alpha = FAKE_STEAM_TARGET_ALPHA * (current_stage / MAX_FAKE_STEAM_STAGES)

#undef FAKE_STEAM_TARGET_ALPHA

/obj/effect/abstract/fake_steam/proc/stage_down()
	if(!current_stage)
		qdel(src)
		return
	current_stage--
	next_stage_down = world.time + STAGE_DOWN_TIME
	update_alpha()

/obj/effect/abstract/fake_steam/proc/stage_up(max_stage = MAX_FAKE_STEAM_STAGES)
	var/target_max_stage = min(MAX_FAKE_STEAM_STAGES, max_stage)
	current_stage = min(current_stage + 1, target_max_stage)
	next_stage_down = world.time + STAGE_DOWN_TIME
	update_alpha()

#undef MAX_FAKE_STEAM_STAGES