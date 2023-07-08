/obj/item/arcane_tome
	name = "arcane tome"
	desc = "The secrets of Blood Magic..."
	icon_state = "arcane"
	icon = 'code/modules/ziggers/items.dmi'
	onflooricon = 'code/modules/ziggers/onfloor.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/list/rituals = list()

/obj/item/arcane_tome/Initialize()
	. = ..()
	for(var/i in subtypesof(/obj/ritualrune))
		if(i)
			var/obj/ritualrune/R = new i(src)
			rituals |= R

/obj/item/arcane_tome/attack_self(mob/user)
	. = ..()
	for(var/obj/ritualrune/R in rituals)
		to_chat(user, "[R.name]([R.word]) - [R.desc]")

/obj/ritualrune
	name = "Tremere Rune"
	desc = "Learn the secrets of blood, neonate..."
	icon = 'code/modules/ziggers/icons.dmi'
	icon_state = "rune1"
	color = rgb(128,0,0)
	flags_1 = HEAR_1
	var/word = "IDI NAH"
	var/activator_bonus = 0

/mob/living
	var/thaumaturgy_knowledge = FALSE

/obj/ritualrune/proc/complete()
	return

/obj/ritualrune/proc/handle_hearing(datum/source, list/hearing_args)
	var/message = hearing_args[HEARING_RAW_MESSAGE]
	if(hearing_args[HEARING_SPEAKER])
		if(isliving(hearing_args[HEARING_SPEAKER]))
			var/mob/living/L = hearing_args[HEARING_SPEAKER]
			if(L.thaumaturgy_knowledge)
				if(message == word)
					complete()
					activator_bonus = L.thaum_damage_plus

/obj/ritualrune/blood_guardian
	name = "Blood Guardian"
	desc = "Creates the Blood Guardian to protect tremere or his domain."
	icon_state = "rune1"
	word = "UR'JOLA"

/obj/ritualrune/blood_guardian/complete()
	var/mob/living/simple_animal/hostile/blood_guard/BG = new(loc)
	BG.melee_damage_lower = BG.melee_damage_lower+activator_bonus
	BG.melee_damage_upper = BG.melee_damage_upper+activator_bonus
	playsound(loc, 'code/modules/ziggers/sounds/thaum.ogg', 50, FALSE)
	qdel(src)

/mob/living/simple_animal/hostile/blood_guard
	name = "blood guardian"
	desc = "A clot of blood in humanoid form."
	icon = 'code/modules/ziggers/mobs.dmi'
	icon_state = "blood_guardian"
	icon_living = "blood_guardian"
	del_on_death = 1
	healable = 0
	mob_biotypes = MOB_SPIRIT
	speak_chance = 0
	turns_per_move = 5
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	emote_taunt = list("gnashes")
	speed = 0
	maxHealth = 50
	health = 50

	harm_intent_damage = 8
	obj_damage = 50
	melee_damage_lower = 10
	melee_damage_upper = 10
	attack_verb_continuous = "punches"
	attack_verb_simple = "punch"
	attack_sound = 'sound/weapons/punch1.ogg'
	speak_emote = list("gnashes")

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	faction = list("Tremere")
	pressure_resistance = 200

/obj/ritualrune/blood_trap
	name = "Blood Trap"
	desc = "Creates the Blood Trap to protect tremere or his domain."
	icon_state = "rune2"
	word = "DUH'K-A'U"
	var/activated = FALSE

/obj/ritualrune/blood_trap/complete()
	if(!activated)
		playsound(loc, 'code/modules/ziggers/sounds/thaum.ogg', 50, FALSE)
		activated = TRUE
		alpha = 28

/obj/ritualrune/blood_trap/Crossed(atom/movable/AM)
	if(isliving(AM) && activated)
		var/mob/living/L = AM
		L.adjustFireLoss(50+activator_bonus)
		playsound(loc, 'code/modules/ziggers/sounds/thaum.ogg', 50, FALSE)
		qdel(src)

/obj/ritualrune/blood_wall
	name = "Blood Wall"
	desc = "Creates the Blood Wall to protect tremere or his domain."
	icon_state = "rune3"
	word = "SOT'PY-O"

/obj/ritualrune/blood_wall/complete()
	new /obj/structure/bloodwall(loc)
	playsound(loc, 'code/modules/ziggers/sounds/thaum.ogg', 50, FALSE)
	qdel(src)

/obj/structure/bloodwall
	name = "blood wall"
	desc = "Wall from BLOOD."
	icon = 'code/modules/ziggers/icons.dmi'
	icon_state = "bloodwall"
	plane = GAME_PLANE
	layer = ABOVE_MOB_LAYER
	anchored = TRUE
	density = TRUE

/obj/ritualrune/identification
	name = "Occult Items Identification"
	desc = "Identificates single occult item"
	icon_state = "rune4"
	word = "IN'DAR"

/obj/ritualrune/identification/complete()
	for(var/obj/item/vtm_artifact/VA in loc)
		if(VA)
			VA.identificate()
			playsound(loc, 'code/modules/ziggers/sounds/thaum.ogg', 50, FALSE)
			qdel(src)
			return

/obj/ritualrune/question
	name = "Question to Ancestors"
	desc = "Summon souls from the dead. Ask a question and get answers."
	icon_state = "rune5"
	word = "TE-ME'LL"

/mob/living/simple_animal/hostile/ghost/tremere
	maxHealth = 1
	health = 1
	melee_damage_lower = 1
	melee_damage_upper = 1
	faction = list("Tremere")

/obj/ritualrune/question/complete()
	var/list/mob/dead/observer/candidates = pollCandidatesForMob("Do you wish to answer a question? (You are allowed to spread meta information)", null, null, null, 50, src)
	for(var/mob/dead/observer/G in GLOB.player_list)
		if(G.key)
			to_chat(G, "<span class='ghostalert'>Question rune has been triggered.</span>")
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		var/mob/living/simple_animal/hostile/ghost/tremere/TR = new(loc)
		TR.key = C.key
		playsound(loc, 'code/modules/ziggers/sounds/thaum.ogg', 50, FALSE)
		qdel(src)

/obj/ritualrune/teleport
	name = "Teleportation Rune"
	desc = "Move your body among the city streets."
	icon_state = "rune6"
	word = "POR'TALE"
	var/activated = FALSE

/obj/ritualrune/teleport/complete()
	if(!activated)
		activated = TRUE
		color = rgb(255,255,255)
		icon_state = "teleport"

/obj/ritualrune/teleport/attack_hand(mob/user)
	var/x_dir = 1
	var/y_dir = 1
	if(activated)
		var/x = input(user, "Choose x direction:\n(1-255)", "Teleportation Rune") as num|null
		if(x)
			x_dir = max(min( round(text2num(x)), 255),1)
			var/y = input(user, "Choose y direction:\n(1-255)", "Teleportation Rune") as num|null
			if(y)
				y_dir = max(min( round(text2num(y)), 255),1)
				for(var/turf/open/floor/plating/P in world)
					if(P.z == user.z && P.x == x_dir && P.y == y_dir && istype(get_area(P), /area/vtm))
						var/area/vtm/V = get_area(P)
						if(V.name != "San Francisco")
							playsound(loc, 'code/modules/ziggers/sounds/thaum.ogg', 50, FALSE)
							user.forceMove(P)
							qdel(src)
							return
					else
						to_chat(user, "<span class='warning'>There is no available teleportation place by this coordinates!</span>")

/obj/ritualrune/curse
	name = "Curse Rune"
	desc = "Curse your enemies in distance."
	icon_state = "rune7"
	word = "CUS-RE'S"
	var/activated = FALSE

/obj/ritualrune/curse/complete()
	if(!activated)
		playsound(loc, 'code/modules/ziggers/sounds/thaum.ogg', 50, FALSE)
		color = rgb(255,0,0)
		activated = TRUE

/obj/ritualrune/curse/attack_hand(mob/user)
	var/cursed
	if(activated)
		var/namem = input(user, "Choose x direction:\n(1-255)", "Curse Rune") as num|null
		if(namem)
			cursed = namem
			for(var/mob/living/carbon/human/H in GLOB.player_list)
				if(H.real_name == cursed)
					H.adjustFireLoss(20)
					playsound(H.loc, 'code/modules/ziggers/sounds/thaum.ogg', 50, FALSE)
					to_chat(H, "<span class='warning'>You feel someone repeating your name from the shadows...</span>")
					H.Stun(10)
					qdel(src)
					return
			to_chat(user, "<span class='warning'>There is no such names in the city!</span>")