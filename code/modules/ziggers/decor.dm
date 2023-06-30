/obj/effect/decal/rugs
	name = "rugs"
	icon = 'code/modules/ziggers/tiles.dmi'
	icon_state = "rugs"

/obj/effect/decal/rugs/Initialize()
	. = ..()
	icon_state = "rugs[rand(1, 11)]"

/obj/structure/vampfence
	name = "\improper fence"
	desc = "Protects places from walking in."
	icon = 'code/modules/ziggers/props.dmi'
	icon_state = "fence"
	plane = GAME_PLANE
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE
	density = TRUE

/obj/structure/vampfence/corner
	icon_state = "fence_corner"

/obj/structure/vampfence/rich
	icon = 'code/modules/ziggers/32x48.dmi'

/obj/structure/vampfence/corner/rich
	icon = 'code/modules/ziggers/32x48.dmi'

/obj/structure/gargoyle
	name = "\improper gargoyle"
	desc = "Some kind of gothic architecture."
	icon = 'code/modules/ziggers/32x48.dmi'
	icon_state = "gargoyle"
	pixel_z = 8
	plane = GAME_PLANE
	layer = ABOVE_ALL_MOB_LAYERS_LAYER
	anchored = TRUE

/obj/structure/lamppost
	name = "lamppost"
	desc = "Gives some light to the streets."
	icon = 'code/modules/ziggers/lamppost.dmi'
	base_icon_state = "base"
	plane = GAME_PLANE
	layer = ABOVE_ALL_MOB_LAYER
	var/number_of_lamps
	pixel_w = -32
	anchored = TRUE
	density = TRUE

/obj/effect/decal/lamplight
	alpha = 0

/obj/effect/decal/lamplight/Initialize()
	. = ..()
	set_light(7, 1, "#ffde9b")

/obj/structure/lamppost/Initialize()
	. = ..()
	switch(number_of_lamps)
		if(1)
			switch(dir)
				if(NORTH)
					new /obj/effect/decal/lamplight(get_step(loc, NORTH))
				if(SOUTH)
					new /obj/effect/decal/lamplight(get_step(loc, SOUTH))
				if(EAST)
					new /obj/effect/decal/lamplight(get_step(loc, EAST))
				if(WEST)
					new /obj/effect/decal/lamplight(get_step(loc, WEST))
		if(2)
			switch(dir)
				if(NORTH)
					new /obj/effect/decal/lamplight(get_step(loc, NORTH))
					new /obj/effect/decal/lamplight(get_step(loc, SOUTH))
				if(SOUTH)
					new /obj/effect/decal/lamplight(get_step(loc, NORTH))
					new /obj/effect/decal/lamplight(get_step(loc, SOUTH))
				if(EAST)
					new /obj/effect/decal/lamplight(get_step(loc, EAST))
					new /obj/effect/decal/lamplight(get_step(loc, WEST))
				if(WEST)
					new /obj/effect/decal/lamplight(get_step(loc, EAST))
					new /obj/effect/decal/lamplight(get_step(loc, WEST))
		if(3)
			switch(dir)
				if(NORTH)
					new /obj/effect/decal/lamplight(get_step(loc, NORTH))
					new /obj/effect/decal/lamplight(get_step(loc, EAST))
					new /obj/effect/decal/lamplight(get_step(loc, WEST))
				if(SOUTH)
					new /obj/effect/decal/lamplight(get_step(loc, SOUTH))
					new /obj/effect/decal/lamplight(get_step(loc, EAST))
					new /obj/effect/decal/lamplight(get_step(loc, WEST))
				if(EAST)
					new /obj/effect/decal/lamplight(get_step(loc, EAST))
					new /obj/effect/decal/lamplight(get_step(loc, NORTH))
					new /obj/effect/decal/lamplight(get_step(loc, SOUTH))
				if(WEST)
					new /obj/effect/decal/lamplight(get_step(loc, WEST))
					new /obj/effect/decal/lamplight(get_step(loc, NORTH))
					new /obj/effect/decal/lamplight(get_step(loc, SOUTH))
		if(4)
			new /obj/effect/decal/lamplight(get_step(loc, NORTH))
			new /obj/effect/decal/lamplight(get_step(loc, SOUTH))
			new /obj/effect/decal/lamplight(get_step(loc, EAST))
			new /obj/effect/decal/lamplight(get_step(loc, WEST))
		else
			new /obj/effect/decal/lamplight(loc)

/obj/structure/lamppost/one
	icon_state = "one"
	number_of_lamps = 1

/obj/structure/lamppost/two
	icon_state = "two"
	number_of_lamps = 2

/obj/structure/lamppost/three
	icon_state = "three"
	number_of_lamps = 3

/obj/structure/lamppost/four
	icon_state = "four"
	number_of_lamps = 4

/obj/structure/lamppost/sidewalk
	icon_state = "civ"
	number_of_lamps = 5

/obj/structure/lamppost/sidewalk/chinese
	icon_state = "chinese"

/obj/structure/trafficlight
	name = "traffic light"
	desc = "Shows when road is free or not."
	icon = 'code/modules/ziggers/lamppost.dmi'
	icon_state = "traffic"
	plane = GAME_PLANE
	layer = ABOVE_ALL_MOB_LAYER
	pixel_w = -32
	anchored = TRUE

/obj/effect/decal/litter
	name = "litter"
	icon = 'code/modules/ziggers/tiles.dmi'
	icon_state = "paper1"

/obj/effect/decal/litter/Initialize()
	. = ..()
	icon_state = "paper[rand(1, 6)]"

/obj/effect/decal/cardboard
	name = "cardboard"
	icon = 'code/modules/ziggers/tiles.dmi'
	icon_state = "cardboard1"

/obj/effect/decal/cardboard/Initialize()
	. = ..()
	icon_state = "cardboard[rand(1, 5)]"
	var/matrix/M = matrix()
	M.Turn(rand(0, 360))
	transform = M

/obj/structure/clothingrack
	name = "clothing rack"
	desc = "Have some clothes."
	icon = 'code/modules/ziggers/props.dmi'
	icon_state = "rack"
	plane = GAME_PLANE
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE
	density = TRUE

/obj/structure/clothingrack/rand
	icon_state = "rack2"

/obj/structure/clothingrack/rand/Initialize()
	. = ..()
	icon_state = "rack[rand(1, 5)]"

/obj/structure/clothinghanger
	name = "clothing hanger"
	desc = "Have some clothes."
	icon = 'code/modules/ziggers/props.dmi'
	icon_state = "hanger1"
	plane = GAME_PLANE
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE
	density = TRUE

/obj/structure/clothinghanger/Initialize()
	. = ..()
	icon_state = "hanger[rand(1, 4)]"

/obj/structure/foodrack
	name = "food rack"
	desc = "Have some food."
	icon = 'code/modules/ziggers/64x64.dmi'
	icon_state = "rack2"
	plane = GAME_PLANE
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE
	density = TRUE
	pixel_w = -16

/obj/structure/foodrack/Initialize()
	. = ..()
	icon_state = "rack[rand(1, 5)]"

/obj/structure/trashcan
	name = "trash can"
	desc = "Holds garbage inside."
	icon = 'code/modules/ziggers/props.dmi'
	icon_state = "garbage"
	plane = GAME_PLANE
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE
	density = TRUE

/obj/structure/trashcan/Initialize()
	. = ..()
	if(prob(25))
		icon_state = "garbage_open"

/obj/structure/trashbag
	name = "trash bag"
	desc = "Holds garbage inside."
	icon = 'code/modules/ziggers/props.dmi'
	icon_state = "garbage1"
	anchored = TRUE

/obj/structure/trashbag/Initialize()
	. = ..()
	var/garbagestate = rand(1, 9)
	if(garbagestate > 6)
		density = TRUE
	icon_state = "garbage[garbagestate]"

/obj/structure/hotelsign
	name = "sign"
	desc = "It says H O T E L."
	icon = 'code/modules/ziggers/props.dmi'
	icon_state = "hotel"
	plane = GAME_PLANE
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE

/obj/structure/hotelsign/Initialize()
	. = ..()
	set_light(2, 1, "#8e509e")

/obj/structure/hotelbanner
	name = "banner"
	desc = "It says H O T E L."
	icon = 'code/modules/ziggers/props.dmi'
	icon_state = "banner"
	plane = GAME_PLANE
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE
	density = TRUE

/obj/structure/milleniumsign
	name = "sign"
	desc = "It says M I L L E N I U M."
	icon = 'code/modules/ziggers/props.dmi'
	icon_state = "millenium"
	plane = GAME_PLANE
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE

/obj/structure/milleniumsign/Initialize()
	. = ..()
	set_light(2, 1, "#4299bb")

/obj/structure/anarchsign
	name = "sign"
	desc = "It says B A R."
	icon = 'code/modules/ziggers/props.dmi'
	icon_state = "bar"
	plane = GAME_PLANE
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE

/obj/structure/anarchsign/Initialize()
	. = ..()
	set_light(2, 1, "#ffffff")

/obj/structure/chinesesign
	name = "sign"
	desc = "吸阴茎同性恋."
	icon = 'code/modules/ziggers/props.dmi'
	icon_state = "chinese1"
	plane = GAME_PLANE
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE

/obj/structure/chinesesign/alt
	icon_state = "chinese2"

/obj/structure/chinesesign/alt/alt
	icon_state = "chinese3"

/obj/structure/arc
	name = "chinatown arc"
	desc = "Cool chinese architecture."
	icon = 'code/modules/ziggers/props.dmi'
	icon_state = "ark1"
	plane = GAME_PLANE
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE

/obj/structure/arc/add
	icon_state = "ark2"

/obj/structure/trad
	name = "traditional lamp"
	desc = "Cool chinese lamp."
	icon = 'code/modules/ziggers/props.dmi'
	icon_state = "trad"
	plane = GAME_PLANE
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE

/obj/structure/vampipe
	name = "pipes"
	icon = 'code/modules/ziggers/props.dmi'
	icon_state = "piping1"
	plane = GAME_PLANE
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE

/obj/structure/hydrant
	name = "hydrant"
	desc = "Used for firefighting."
	icon = 'code/modules/ziggers/props.dmi'
	icon_state = "hydrant"
	anchored = TRUE

/obj/structure/vampcar
	name = "car"
	desc = "It drives."
	icon = 'code/modules/ziggers/cars.dmi'
	icon_state = "taxi"
	plane = GAME_PLANE
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE
	density = TRUE
	pixel_w = -16

/obj/structure/vampcar/Initialize()
	. = ..()
	var/atom/movable/M = new(get_step(loc, EAST))
	M.density = TRUE
	M.anchored = TRUE
	dir = pick(NORTH, SOUTH, WEST, EAST)

/obj/structure/roadblock
	name = "\improper road block"
	desc = "Protects places from walking in."
	icon = 'code/modules/ziggers/props.dmi'
	icon_state = "roadblock"
	plane = GAME_PLANE
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE
	density = TRUE

/obj/structure/roadblock/alt
	icon_state = "barrier"

/obj/machinery/light/prince
	icon = 'code/modules/ziggers/icons.dmi'

/obj/effect/decal/painting
	name = "painting"
	icon = 'code/modules/ziggers/icons.dmi'
	icon_state = "painting1"
	plane = GAME_PLANE
	layer = ABOVE_ALL_MOB_LAYER

/obj/effect/decal/painting/second
	icon_state = "painting2"

/obj/effect/decal/painting/third
	icon_state = "painting3"

/obj/structure/jesuscross
	name = "Jesus Christ on a cross"
	desc = "Jesus said, “Father, forgive them, for they do not know what they are doing.” And they divided up his clothes by casting lots (Luke 23:34)."
	icon = 'code/modules/ziggers/64x64.dmi'
	icon_state = "cross"
	plane = GAME_PLANE
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE
	density = TRUE
	pixel_w = -16

/obj/structure/roadsign
	name = "road sign"
	desc = "Do not drive your car cluelessly."
	icon = 'code/modules/ziggers/32x48.dmi'
	icon_state = "stop"
	plane = GAME_PLANE
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE

/obj/structure/roadsign/stop
	name = "stop sign"
	icon_state = "stop"

/obj/structure/roadsign/noparking
	name = "no parking sign"
	icon_state = "noparking"

/obj/structure/roadsign/nopedestrian
	name = "no pedestrian sign"
	icon_state = "nopedestrian"

/obj/structure/roadsign/busstop
	name = "bus stop sign"
	icon_state = "busstop"

/obj/structure/roadsign/speedlimit
	name = "speed limit sign"
	icon_state = "speed50"

/obj/structure/roadsign/warningtrafficlight
	name = "traffic light warning sign"
	icon_state = "warningtrafficlight"

/obj/structure/roadsign/warningpedestrian
	name = "pedestrian warning sign"
	icon_state = "warningpedestrian"

/obj/structure/roadsign/parking
	name = "parking sign"
	icon_state = "parking"

/obj/structure/roadsign/crosswalk
	name = "crosswalk sign"
	icon_state = "crosswalk"

/obj/structure/barrels
	name = "barrel"
	desc = "Storage some liquids."
	icon = 'code/modules/ziggers/props.dmi'
	icon_state = "barrel1"
	plane = GAME_PLANE
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE
	density = TRUE

/obj/structure/barrels/rand
	icon_state = "barrel2"

/obj/structure/barrels/rand/Initialize()
	. = ..()
	icon_state = "barrel[rand(1, 18)]"

/obj/structure/bricks
	name = "bricks"
	desc = "Building material."
	icon = 'code/modules/ziggers/props.dmi'
	icon_state = "bricks"
	plane = GAME_PLANE
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE
	density = TRUE

/obj/effect/decal/pallet
	name = "pallet"
	icon = 'code/modules/ziggers/props.dmi'
	icon_state = "under1"

/obj/effect/decal/pallet/Initialize()
	. = ..()
	icon_state = "under[rand(1, 2)]"

/obj/effect/decal/trash
	name = "trash"
	icon = 'code/modules/ziggers/props.dmi'
	icon_state = "trash1"

/obj/effect/decal/trash/Initialize()
	. = ..()
	icon_state = "trash[rand(1, 30)]"

/obj/cargocrate
	name = "cargocrate"
	desc = "It delivers a lot of things."
	icon = 'code/modules/ziggers/containers.dmi'
	icon_state = "1"
	plane = GAME_PLANE
	layer = CAR_LAYER
	anchored = TRUE

/obj/cargocrate/Initialize()
	. = ..()
	icon_state = "[rand(1, 5)]"
	if(icon_state != "1")
		opacity = TRUE
	density = TRUE
	var/atom/movable/M1 = new(get_step(loc, EAST))
	var/atom/movable/M2 = new(get_step(M1.loc, EAST))
	var/atom/movable/M3 = new(get_step(M2.loc, EAST))
	M1.density = TRUE
	if(icon_state != "1")
		M1.opacity = TRUE
	M1.anchored = TRUE
	M2.density = TRUE
	if(icon_state != "1")
		M2.opacity = TRUE
	M2.anchored = TRUE
	M3.density = TRUE
	if(icon_state != "1")
		M3.opacity = TRUE
	M3.anchored = TRUE

/obj/structure/fuelstation
	name = "fuel station"
	desc = "Fuel your car here."
	icon = 'code/modules/ziggers/props.dmi'
	icon_state = "fuelstation"
	plane = GAME_PLANE
	layer = CAR_LAYER
	anchored = TRUE
	density = TRUE

/obj/structure/bloodextractor
	name = "blood extractor"
	desc = "Extract blood in packs."
	icon = 'code/modules/ziggers/props.dmi'
	icon_state = "bloodextractor"
	plane = GAME_PLANE
	layer = CAR_LAYER
	anchored = TRUE
	density = TRUE
	var/last_extracted = 0

/mob/living/carbon/human/MouseDrop(atom/over_object)
	. = ..()
	if(iskindred(src))
		return
	if(istype(over_object, /obj/structure/bloodextractor))
		if(get_dist(src, over_object) < 2)
			var/obj/structure/bloodextractor/V = over_object
			if(V.last_extracted+300 > world.time)
				V.visible_message("<span class='warning'>[V] isn't ready!</span>")
				return
			V.last_extracted = world.time
			new /obj/item/drinkable_bloodpack(get_step(V, SOUTH))

GLOBAL_LIST_EMPTY(vampire_computers)

/obj/vampire_computer
	name = "computer"
	desc = "See the news of Kindred City."
	icon = 'code/modules/ziggers/props.dmi'
	icon_state = "computer"
	plane = GAME_PLANE
	layer = CAR_LAYER
	anchored = TRUE
	var/main = FALSE
	var/last_message = ""

/obj/vampire_computer/examine(mob/user)
	. = ..()
	icon_state = initial(icon_state)
	. += "Last Message:<BR>"
	. += "- [last_message]"

/obj/vampire_computer/Initialize()
	. = ..()
	GLOB.vampire_computers += src

/obj/vampire_computer/Destroy()
	. = ..()
	GLOB.vampire_computers -= src

/obj/vampire_computer/prince
	icon_state = "computerprince"
	main = TRUE

/obj/vampire_computer/attack_hand(mob/user)
	to_chat(user, "Last Message:<BR>")
	to_chat(user, "- [last_message]")
	if(!main)
		return
	var/announce = input(user, "Type a text to announce:", "Announce")  as text|null
	if(announce)
		for(var/obj/vampire_computer/C in GLOB.vampire_computers)
			C.last_message = "[announce]"
			if(!C.main)
				C.say("New announcement from Prince!")
				C.icon_state = "computermessage"
			else
				C.say("Announcement sent.")

/obj/structure/rack/tacobell
	name = "table"
	icon = 'code/modules/ziggers/props.dmi'
	icon_state = "tacobell"

/obj/structure/rack/tacobell/attack_hand(mob/living/user)
	return

/obj/structure/rack/tacobell/horizontal
	icon_state = "tacobell1"

/obj/structure/rack/tacobell/vertical
	icon_state = "tacobell2"

/obj/structure/rack/tacobell/south
	icon_state = "tacobell3"

/obj/structure/rack/tacobell/north
	icon_state = "tacobell4"

/obj/structure/rack/tacobell/east
	icon_state = "tacobell5"

/obj/structure/rack/tacobell/west
	icon_state = "tacobell6"

/obj/structure/rack/bubway
	name = "table"
	icon = 'code/modules/ziggers/props.dmi'
	icon_state = "bubway"

/obj/structure/rack/bubway/attack_hand(mob/living/user)
	return

/obj/structure/rack/bubway/horizontal
	icon_state = "bubway1"

/obj/structure/rack/bubway/vertical
	icon_state = "bubway2"

/obj/structure/rack/bubway/south
	icon_state = "bubway3"

/obj/structure/rack/bubway/north
	icon_state = "bubway4"

/obj/structure/rack/bubway/east
	icon_state = "bubway5"

/obj/structure/rack/bubway/west
	icon_state = "bubway6"

/obj/bacotell
	name = "Baco Tell"
	desc = "Eat some precious tacos and pizza!"
	icon = 'code/modules/ziggers/fastfood.dmi'
	icon_state = "bacotell"
	plane = GAME_PLANE
	layer = CAR_LAYER
	anchored = TRUE
	pixel_w = -16

/obj/bubway
	name = "BubWay"
	desc = "Eat some precious burgers and pizza!"
	icon = 'code/modules/ziggers/fastfood.dmi'
	icon_state = "bubway"
	plane = GAME_PLANE
	layer = CAR_LAYER
	anchored = TRUE
	pixel_w = -16

/obj/gummaguts
	name = "Gumma Guts"
	desc = "Eat some precious chicken nuggets and donuts!"
	icon = 'code/modules/ziggers/fastfood.dmi'
	icon_state = "gummaguts"
	plane = GAME_PLANE
	layer = CAR_LAYER
	anchored = TRUE
	pixel_w = -16

/obj/underplate
	name = "underplate"
	icon = 'code/modules/ziggers/props.dmi'
	icon_state = "underplate"
	plane = GAME_PLANE
	layer = TABLE_LAYER
	anchored = TRUE

/obj/underplate/stuff
	icon_state = "stuff"

/obj/order
	name = "order sign"
	icon = 'code/modules/ziggers/props.dmi'
	icon_state = "order"
	plane = GAME_PLANE
	layer = CAR_LAYER
	anchored = TRUE

/obj/order1
	name = "order screen"
	icon = 'code/modules/ziggers/props.dmi'
	icon_state = "order1"
	plane = GAME_PLANE
	layer = CAR_LAYER
	anchored = TRUE

/obj/order2
	name = "order screen"
	icon = 'code/modules/ziggers/props.dmi'
	icon_state = "order2"
	plane = GAME_PLANE
	layer = CAR_LAYER
	anchored = TRUE

/obj/order3
	name = "order screen"
	icon = 'code/modules/ziggers/props.dmi'
	icon_state = "order3"
	plane = GAME_PLANE
	layer = CAR_LAYER
	anchored = TRUE

/obj/order4
	name = "order screen"
	icon = 'code/modules/ziggers/props.dmi'
	icon_state = "order4"
	plane = GAME_PLANE
	layer = CAR_LAYER
	anchored = TRUE

/obj/matrix
	name = "matrix"
	desc = "Suicide is no exit..."
	icon = 'code/modules/ziggers/props.dmi'
	icon_state = "matrix"
	plane = GAME_PLANE
	layer = ABOVE_NORMAL_TURF_LAYER
	anchored = TRUE
	opacity = TRUE
	density = TRUE

/obj/matrix/attack_hand(mob/user)
	if(user.client)
		cryoMob(user, src)
	return TRUE

/proc/cryoMob(mob/living/mob_occupant, obj/pod)
	var/list/crew_member = list()
	crew_member["name"] = mob_occupant.real_name

	if(mob_occupant.mind)
		// Handle job slot/tater cleanup.
		var/job = mob_occupant.mind.assigned_role
		crew_member["job"] = job
		SSjob.FreeRole(job)
//		if(LAZYLEN(mob_occupant.mind.objectives))
//			mob_occupant.mind.objectives.Cut()
		mob_occupant.mind.special_role = null
	else
		crew_member["job"] = "N/A"

	if (pod)
		pod.visible_message("\The [pod] hums and hisses as it teleports [mob_occupant.real_name].")

	var/list/gear = list()
	if(ishuman(mob_occupant))		// sorry simp-le-mobs deserve no mercy
		var/mob/living/carbon/human/C = mob_occupant
		gear = C.get_all_gear()
		for(var/obj/item/item_content as anything in gear)
			item_content.forceMove(pod.loc)
		for(var/mob/living/L in mob_occupant.GetAllContents() - mob_occupant)
			L.forceMove(pod.loc)
		if(mob_occupant.client)
			mob_occupant.client.screen.Cut()
//			mob_occupant.client.screen += mob_ocupant.client.void
			var/mob/dead/new_player/M = new /mob/dead/new_player()
			M.key = mob_occupant.key
	QDEL_NULL(mob_occupant)