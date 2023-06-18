/obj/damap
	icon = 'code/modules/ziggers/map.dmi'
	icon_state = "map"
	plane = GAME_PLANE
	layer = ABOVE_NORMAL_TURF_LAYER

/obj/structure/vampmap
	name = "\improper map"
	desc = "Locate yourself now."
	icon = 'code/modules/ziggers/props.dmi'
	icon_state = "map"
	plane = GAME_PLANE
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE
	density = TRUE

/obj/structure/vampmap/attack_hand(mob/user)
	. = ..()
	var/dat = {"
			<style type="text/css">

			body {
				background-color: #090909; color: white;
			}

			</style>
			"}
	var/obj/damap/DAMAP = new(user)
	var/mutable_appearance/targeticon = mutable_appearance(DAMAP.icon, "target", ABOVE_MOB_LAYER)
	targeticon.pixel_w = user.x-127
	targeticon.pixel_z = user.y-127
	DAMAP.add_overlay(targeticon)
	dat += "<center>[icon2html(getFlatIcon(DAMAP), user)]</center>"
	user << browse(dat, "window=map;size=400x400;border=1;can_resize=0;can_minimize=0")
	onclose(user, "map", src)
	qdel(DAMAP)


/obj/effect/mob_spawn/human/citizen
	name = "just a civillian"
	desc = "A humming sleeper with a silhouetted occupant inside. Its stasis function is broken and it's likely being used as a bed."
	mob_name = "a civillian"
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "cryostasis_sleeper"
	outfit = /datum/outfit/civillian1
	roundstart = FALSE
	death = FALSE
	mob_species = /datum/species/human
	short_desc = "You just woke up from strange noises outside. This city is totally cursed..."
	flavour_text = "Each day you notice some weird shit going at night. Each day, new corpses, new missing people, new police-don't-give-a-fuck. This time you definitely should go and see the mysterious powers of the night... or not? You are too afraid because you are not aware of it."
	assignedrole = "Civillian"

/obj/effect/mob_spawn/human/citizen/Initialize(mapload)
	. = ..()
	if(prob(50))
		qdel(src)
		return
	var/arrpee = rand(1,4)
	switch(arrpee)
		if(2)
			outfit = /datum/outfit/civillian2
		if(3)
			outfit = /datum/outfit/civillian3
		if(4)
			outfit = /datum/outfit/civillian4

/obj/effect/mob_spawn/human/citizen/special(mob/living/new_spawn)
	var/my_name = "Tyler"
	if(new_spawn.gender == MALE)
		my_name = pick(GLOB.first_names_male)
	else
		my_name = pick(GLOB.first_names_female)
	var/my_surname = pick(GLOB.last_names)
	new_spawn.fully_replace_character_name(null,"[my_name] [my_surname]")

/datum/outfit/civillian1
	name = "civillian"
	uniform = /obj/item/clothing/under/vampire/sport
	shoes = /obj/item/clothing/shoes/vampire/sneakers
	id = /obj/item/cockclock
	l_pocket = /obj/item/vamp/phone
	r_pocket = /obj/item/flashlight
	l_hand = /obj/item/vamp/keys/npc

/datum/outfit/civillian2
	name = "civillian"
	uniform = /obj/item/clothing/under/vampire/office
	shoes = /obj/item/clothing/shoes/vampire
	id = /obj/item/cockclock
	l_pocket = /obj/item/vamp/phone
	r_pocket = /obj/item/flashlight
	l_hand = /obj/item/vamp/keys/npc

/datum/outfit/civillian3
	name = "civillian"
	uniform = /obj/item/clothing/under/vampire/emo
	shoes = /obj/item/clothing/shoes/vampire
	id = /obj/item/cockclock
	l_pocket = /obj/item/vamp/phone
	r_pocket = /obj/item/flashlight
	l_hand = /obj/item/vamp/keys/npc

/datum/outfit/civillian4
	name = "civillian"
	uniform = /obj/item/clothing/under/vampire/bandit
	shoes = /obj/item/clothing/shoes/vampire/jackboots
	id = /obj/item/cockclock
	l_pocket = /obj/item/vamp/phone
	r_pocket = /obj/item/flashlight
	l_hand = /obj/item/vamp/keys/npc