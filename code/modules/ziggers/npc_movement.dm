/obj/effect/landmark/npcbeacon
	name = "NPC beacon"
	var/directionwalk
/obj/effect/landmark/npc_spawn_point
/obj/effect/landmark/npc_spawn_point/Initialize()
	. = ..()
	GLOB.npc_spawn_points |= src
/obj/effect/landmark/npcbeacon/directed
	name = "NPC traffic"
	icon_state = "npc"

/obj/effect/landmark/npcbeacon/directed/Initialize()
	..()
	directionwalk = dir

/obj/effect/landmark/npcwall
	name = "NPC Wall"
	icon_state = "x"

/obj/effect/landmark/npcactivity
	name = "NPC Activity"
	icon_state = "bullets"

/obj/effect/landmark/npcactivity/Initialize()
	. = ..()
	GLOB.npc_activities += src

/mob/living/carbon/human/npc/Initialize()
	..()
	GLOB.npc_list += src

/mob/living/carbon/human
	var/last_showed = 0
	var/last_raid = 0
	var/killed_count = 0

/mob/living/carbon/human/npc/death()
	walk(src,0)
	if(last_attacker && !key && !hostile)
		if(get_dist(src, last_attacker) < 30)
			if(istype(last_attacker, /mob/living/simple_animal/hostile))
				var/mob/living/simple_animal/hostile/HS = last_attacker
				if(HS.my_creator)
					HS.my_creator.AdjustHumanity(-1, 0)
					HS.my_creator.killed_count = HS.my_creator.killed_count+1
					HS.my_creator.last_nonraid = world.time
					if(HS.my_creator.killed_count >= 5)
//						GLOB.fuckers |= HS.my_creator
						HS.my_creator.warrant = TRUE
						SEND_SOUND(HS.my_creator, sound('code/modules/ziggers/sounds/humanity_loss.ogg', 0, 0, 75))
						to_chat(HS.my_creator, "<span class='userdanger'><b>POLICE ASSAULT IN PROGRESS</b></span>")
			else
				if(ishuman(last_attacker))
					var/mob/living/carbon/human/HM = last_attacker
					HM.AdjustHumanity(-1, 0)
					HM.killed_count = HM.killed_count+1
					HM.last_nonraid = world.time
					if(HM.killed_count >= 5)
//						GLOB.fuckers |= HM
						HM.warrant = TRUE
						SEND_SOUND(HM, sound('code/modules/ziggers/sounds/humanity_loss.ogg', 0, 0, 75))
						to_chat(HM, "<span class='userdanger'><b>POLICE ASSAULT IN PROGRESS</b></span>")
	remove_overlay(FIGHT_LAYER)
	GLOB.npc_list -= src
//	SShumannpcpool.npclost()
	..()

/mob/living/carbon/human/npc/Destroy()
	..()
	GLOB.npc_list -= src
	SShumannpcpool.npclost()

/mob/living/carbon/human/npc/Life()
	if(stat == DEAD)
		return
	..()
	var/list/checklist = list()
	for(var/mob/living/carbon/human/H in oviewers(5, src))
		if(H)
			if(H.stat == DEAD)
				checklist += H
	var/mob/living/carbon/human/H = pick(checklist)
	var/skip = FALSE
	for(var/i in spotted_bodies)
		if(i == H.real_name)
			skip = TRUE
	if(!skip)
		spotted_bodies += H.real_name
		SSmasquerade.total_level = max(0, SSmasquerade.total_level-10)

	if(pulledby)
		if(!CheckMove() && prob(50))
			var/pre_intent = a_intent
			a_intent = INTENT_DISARM
			ClickOn(pulledby)
			a_intent = pre_intent
		if(prob(25))
			Aggro(pulledby, TRUE)
		if(fights_anyway)
			Aggro(pulledby, TRUE)
	if(!CheckMove())
		nutrition = 400
		if(get_dist(danger_source, src) < 7)
			last_danger_meet = world.time
		if(fire_stacks >= 1)
			resist()
		if(!staying)
			if(!walktarget)
				walktarget = ChoosePath()
			if(loc == tupik_loc)
				tupik_steps += 1
			if(loc != tupik_loc)
				tupik_loc = loc
				tupik_steps = 0
			if(tupik_steps > 3)
				var/turf/T = get_step(src, pick(NORTH, SOUTH, WEST, EAST))
				face_atom(T)
				step_to(src,T,0)
		if(prob(5) && !danger_source)
			var/activity = rand(1, 3)
			switch(activity)
				if(1)
					StareAction()
				if(2)
					EmoteAction()
				if(3)
					SpeechAction()

/mob/living/carbon/human/npc/proc/CreateWay(var/direction)
	var/turf/location = get_turf(src)
	for(var/distance = 1 to 50)
		location = get_step(location, direction)
		if(iswallturf(location))
			return location
		for(var/atom/A in location)
			if(A.density && !istype(A, /obj/structure/lamppost))
				return location
			if(istype(A, /obj/effect/landmark/npcwall))
				return get_step_towards(location, get_turf(src))
			if(istype(A, /obj/effect/decal/cleanable/blood))
				var/obj/effect/decal/cleanable/blood/B = A
				if(B.bloodiness)
					return get_step_towards(location, get_turf(src))
			if(istype(A, /obj/effect/fire))
				return get_turf(src)
			if(isnpcbeacon(A) && prob(50))
//				var/opposite_dir = turn(direction, 180)				Nado
				stopturf = 1
				return get_step(location, direction)
//		if(distance == 50)
//			return location

/mob/living/carbon/human/npc/proc/ChoosePath()
	if(!old_movement)
		var/list/possible_list = list()
		for(var/obj/effect/landmark/npcactivity/N in GLOB.npc_activities)
			if(get_dist(src, N) > 40)
				if(N.x > x-3 && N.x < x+3)
					possible_list += N
				if(N.y > y-3 && N.y < y+3)
					possible_list += N
		if(!length(possible_list))
			var/atom/shitshit
			for(var/obj/effect/landmark/npcactivity/N in GLOB.npc_activities)
				if(N)
					if(!shitshit)
						shitshit = N
					if(get_dist(src, N) > 1 && get_dist(src, N) < get_dist(src, shitshit))
						shitshit = N
			if(shitshit)
				return shitshit
			else
				return pick(GLOB.npc_activities)

		return pick(possible_list)
	else
		var/turf/north_steps = CreateWay(NORTH)
		var/turf/south_steps = CreateWay(SOUTH)
		var/turf/west_steps = CreateWay(WEST)
		var/turf/east_steps = CreateWay(EAST)

		if(dir == NORTH || dir == SOUTH)
			if(get_dist(src, west_steps) >= 7 && get_dist(src, east_steps) >= 7)
				return(pick(west_steps, east_steps))
			if(get_dist(src, west_steps) > get_dist(src, east_steps))
				if(prob(75))
					return west_steps
			else if(get_dist(src, east_steps) > get_dist(src, west_steps))
				if(prob(75))
					return east_steps
			else
				if(dir == NORTH)
					return pick(west_steps, east_steps, south_steps)
				else
					return pick(west_steps, east_steps, north_steps)

		if(dir == WEST || dir == EAST)
			if(get_dist(src, north_steps) >= 7 && get_dist(src, south_steps) >= 7)
				return pick(north_steps, south_steps)
			if(get_dist(src, north_steps) > get_dist(src, south_steps))
				if(prob(75))
					return north_steps
			else if(get_dist(src, south_steps) > get_dist(src, north_steps))
				if(prob(75))
					return south_steps
			else
				if(dir == WEST)
					return pick(north_steps, south_steps, east_steps)
				else
					return pick(north_steps, south_steps, west_steps)
/mob/living/carbon/human/npc/proc/CheckMove()
	if(stat >= 2)
		return TRUE
	if(last_grab+15 > world.time)
		return TRUE
	if(ghoulificated)
		return TRUE
	if(key)
		return TRUE
	if(IsSleeping())
		return TRUE
	if(IsUnconscious())
		return TRUE
	if(IsParalyzed())
		return TRUE
	if(IsKnockdown())
		return TRUE
	if(IsStun())
		return TRUE
	if(HAS_TRAIT(src, TRAIT_RESTRAINED))
		return TRUE
	if(is_talking)
		return TRUE
	if(pulledby)
		if(HAS_TRAIT(pulledby, TRAIT_CHARMER))
			return TRUE
		if(prob(30))
			resist()
			return TRUE
		else
			return TRUE
	return FALSE


/mob/living/carbon/human/npc/proc/route_optimisation()
	var/sosat = FALSE
	for(var/mob/M in viewers(7, src))
		if(M.client)
			sosat = TRUE
	if(sosat)
		return FALSE
	return TRUE

/mob/living/carbon/human/npc/proc/handle_automated_movement()
	if(CheckMove())
		return
	var/fire_danger = FALSE
	for(var/obj/effect/fire/F in range(7, src))
		if(F)
			less_danger = F
			fire_danger = TRUE
	if(!fire_danger)
		less_danger = null
	if(!staying)
		lifespan = lifespan+1
	if(lifespan >= 1000)
		if(route_optimisation())
			qdel(src)
	if(!walktarget && !staying)
		stopturf = rand(1, 2)
		walktarget = ChoosePath()
		face_atom(walktarget)
	if(isturf(loc))
		if(danger_source)
			a_intent = INTENT_HARM
			if(m_intent == MOVE_INTENT_WALK)
				toggle_move_intent(src)
			if(!my_weapon && !fights_anyway)
//				if(last_walkin+5 < world.time)
				var/reqsteps = round((SShumannpcpool.next_fire-world.time)/total_multiplicative_slowdown())
				set_glide_size(DELAY_TO_GLIDE_SIZE(total_multiplicative_slowdown()))
				walk_away(src, danger_source, reqsteps, total_multiplicative_slowdown())
			if(my_weapon || fights_anyway)
				if(!spawned_weapon && my_weapon)
					my_weapon.forceMove(loc)
					drop_all_held_items()
					put_in_active_hand(my_weapon)
					spawned_weapon = TRUE
				if(spawned_weapon && get_active_held_item() != my_weapon)
					my_weapon = null

				if(danger_source)
					if(danger_source == src)
						danger_source = null
					else
						ClickOn(danger_source)
						face_atom(danger_source)
//				if(last_walkin+5 < world.time)
						var/reqsteps = round((SShumannpcpool.next_fire-world.time)/total_multiplicative_slowdown())
						set_glide_size(DELAY_TO_GLIDE_SIZE(total_multiplicative_slowdown()))
//						var/plus_turfs = 0
//						if(istype(my_weapon, /obj/item/gun))
//							plus_turfs = 3
						walk_to(src, danger_source, reqsteps, total_multiplicative_slowdown())

			if(isliving(danger_source))
				var/mob/living/L = danger_source
				if(L.stat > 2)
					danger_source = null
					if(my_weapon)
						if(get_active_held_item() == my_weapon)
							drop_all_held_items()
							my_weapon.forceMove(src)
							spawned_weapon = FALSE
						else
							my_weapon = null
					walktarget = ChoosePath()
					a_intent = INTENT_HELP

			if(last_danger_meet+300 <= world.time)
				danger_source = null
				if(my_weapon)
					if(get_active_held_item() == my_weapon)
						drop_all_held_items()
						my_weapon.forceMove(src)
						spawned_weapon = FALSE
					else
						my_weapon = null
				walktarget = ChoosePath()
				a_intent = INTENT_HELP
		else if(less_danger)
			var/reqsteps = round((SShumannpcpool.next_fire-world.time)/total_multiplicative_slowdown())
			set_glide_size(DELAY_TO_GLIDE_SIZE(total_multiplicative_slowdown()))
			walk_away(src, less_danger, reqsteps, total_multiplicative_slowdown())
			if(prob(25))
				emote("scream")
		else if(walktarget && !staying)
			if(prob(25))
				toggle_move_intent(src)
			var/reqsteps = round((SShumannpcpool.next_fire-world.time)/total_multiplicative_slowdown())
			set_glide_size(DELAY_TO_GLIDE_SIZE(total_multiplicative_slowdown()))
			walk_to(src, walktarget, reqsteps, total_multiplicative_slowdown())

		if(my_weapon && !danger_source)
			if(spawned_weapon)
				if(get_active_held_item() == my_weapon)
					drop_all_held_items()
					my_weapon.forceMove(src)
					spawned_weapon = FALSE
				else
					my_weapon = null

/*
	if(danger_source)
		a_intent = INTENT_HARM
		if(m_intent == MOVE_INTENT_WALK)
			toggle_move_intent(src)
			set_glide_size(DELAY_TO_GLIDE_SIZE(total_multiplicative_slowdown()))
		walk_away(src,danger_source,9,total_multiplicative_slowdown())
		if(last_danger_meet+300 <= world.time)
			danger_source = null
			a_intent = INTENT_HELP
		goto Skip
//			if(!range_weapon && !melee_weapon)

	if(lastgo+total_multiplicative_slowdown() > world.time)
		goto Skip
	if(pulledby && last_grab+30 > world.time)
		goto Skip
	if(!walktarget)
		walktarget = ChoosePath()
		face_atom(walktarget)
		stopturf = rand(1, 2)
	if(get_dist(walktarget, src) <= stopturf)
		walktarget = ChoosePath()
		face_atom(walktarget)
		stopturf = rand(1, 2)
	lastgo = world.time
	var/walkshit = max(stopturf-1, get_dist(walktarget, src)-2)
	walk_to(src, walktarget, walkshit, total_multiplicative_slowdown())
	Skip
*/

//			walk_to(src, walktarget, stopturf, total_multiplicative_slowdown())
//			walk_to(src, walktarget, stopturf, total_multiplicative_slowdown())
