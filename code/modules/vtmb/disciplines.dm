/datum/discipline
	var/name = "Shit Aggresively"
	var/desc = "Shit with blood, cope and seethe"
	var/icon_state
	var/cost = 2
	var/ranged = FALSE
	var/range_sh = 8
	var/delay = 5
	var/violates_masquerade = FALSE
	var/level = 1
	var/activate_sound = 'code/modules/ziggers/sounds/bloodhealing.ogg'
	var/leveldelay = FALSE
	var/fearless = FALSE

	var/level_casting = 1	//which level we want to cast
	var/clane_restricted = FALSE	//Only for specified clans
	var/dead_restricted = TRUE

/datum/discipline/proc/post_gain(var/mob/living/carbon/human/H)
	return

/mob/living
	var/resistant_to_disciplines = FALSE
	var/auspex_examine = FALSE

/atom/examine(mob/user)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/Z = user
		if(Z.auspex_examine)
			if(!isturf(src) && !isobj(src) && !ismob(src))
				return
			var/list/fingerprints = list()
			var/list/blood = return_blood_DNA()
			var/list/fibers = return_fibers()
			var/list/reagents = list()

			if(ishuman(src))
				var/mob/living/carbon/human/H = src
				if(!H.gloves)
					fingerprints += md5(H.dna.uni_identity)

			else if(!ismob(src))
				fingerprints = return_fingerprints()


				if(isturf(src))
					var/turf/T = src
					// Only get reagents from non-mobs.
					if(T.reagents && T.reagents.reagent_list.len)

						for(var/datum/reagent/R in T.reagents.reagent_list)
							T.reagents[R.name] = R.volume

							// Get blood data from the blood reagent.
							if(istype(R, /datum/reagent/blood))

								if(R.data["blood_DNA"] && R.data["blood_type"])
									var/blood_DNA = R.data["blood_DNA"]
									var/blood_type = R.data["blood_type"]
									LAZYINITLIST(blood)
									blood[blood_DNA] = blood_type
				if(isobj(src))
					var/obj/T = src
					// Only get reagents from non-mobs.
					if(T.reagents && T.reagents.reagent_list.len)

						for(var/datum/reagent/R in T.reagents.reagent_list)
							T.reagents[R.name] = R.volume

							// Get blood data from the blood reagent.
							if(istype(R, /datum/reagent/blood))

								if(R.data["blood_DNA"] && R.data["blood_type"])
									var/blood_DNA = R.data["blood_DNA"]
									var/blood_type = R.data["blood_type"]
									LAZYINITLIST(blood)
									blood[blood_DNA] = blood_type

			// We gathered everything. Create a fork and slowly display the results to the holder of the scanner.

			var/found_something = FALSE

			// Fingerprints
			if(length(fingerprints))
				to_chat(user, "<span class='info'><B>Prints:</B></span>")
				for(var/finger in fingerprints)
					to_chat(user, "[finger]")
				found_something = TRUE

			// Blood
			if (length(blood))
				to_chat(user, "<span class='info'><B>Blood:</B></span>")
				found_something = TRUE
				for(var/B in blood)
					to_chat(user, "Type: <font color='red'>[blood[B]]</font> DNA (UE): <font color='red'>[B]</font>")

			//Fibers
			if(length(fibers))
				to_chat(user, "<span class='info'><B>Fibers:</B></span>")
				for(var/fiber in fibers)
					to_chat(user, "[fiber]")
				found_something = TRUE

			//Reagents
			if(length(reagents))
				to_chat(user, "<span class='info'><B>Reagents:</B></span>")
				for(var/R in reagents)
					to_chat(user, "Reagent: <font color='red'>[R]</font> Volume: <font color='red'>[reagents[R]]</font>")
				found_something = TRUE

			if(!found_something)
				to_chat(user, "<I># No forensic traces found #</I>") // Don't display this to the holder user
			return

/datum/discipline/proc/check_activated(var/mob/living/target, var/mob/living/carbon/human/caster)
	if(caster.stat >= 2 || caster.IsSleeping() || caster.IsUnconscious() || caster.IsParalyzed() || caster.IsKnockdown() || caster.IsStun() || HAS_TRAIT(caster, TRAIT_RESTRAINED) || !isturf(caster.loc))
		return FALSE
	var/plus = 0
	if(HAS_TRAIT(caster, TRAIT_HUNGRY))
		plus = 1
	if(caster.bloodpool < cost+plus)
		return FALSE
	if(target.stat == DEAD && dead_restricted)
		return FALSE
	if(ranged)
		if(get_dist(caster, target) > range_sh)
			return FALSE
	if(HAS_TRAIT(caster, TRAIT_PACIFISM))
		return FALSE
	if(HAS_TRAIT(caster, TRAIT_ELYSIUM) && violates_masquerade)
		caster.check_elysium(FALSE)
	if(target.resistant_to_disciplines || target.spell_immunity)
		to_chat(caster, "<span class='danger'>[target] resists your powers!</span>")
		return FALSE
	caster.bloodpool = max(0, caster.bloodpool-(cost+plus))
	caster.update_blood_hud()
	if(ranged)
		to_chat(caster, "<span class='notice'>You activate the [name] on [target].</span>")
	else
		to_chat(caster, "<span class='notice'>You activate the [name].</span>")
	if(ranged)
		if(isnpc(target) && !fearless)
			var/mob/living/carbon/human/npc/NPC = target
			NPC.Aggro(caster, TRUE)
	if(activate_sound)
		playsound(caster, activate_sound, 50, FALSE)
//	if(caster.key)
//		var/datum/preferences/P = GLOB.preferences_datums[ckey(caster.key)]
//		if(P)
//			if(!HAS_TRAIT(caster, TRAIT_NON_INT))
//				P.exper = min(calculate_mob_max_exper(caster), P.exper+10+caster.experience_plus)
//			P.save_preferences()
//			P.save_character()
	if(violates_masquerade)
		if(caster.CheckEyewitness(target, caster, 7, TRUE))
			caster.AdjustMasquerade(-1)
	return TRUE

/datum/discipline/proc/activate(var/mob/living/target, var/mob/living/carbon/human/caster)
	if(!target)
		return
	if(!caster)
		return
//	if(!target)
//		var/choice = input(caster, "Choose your target", "Available Targets") as mob in oviewers(4, caster)
//		if(choice)
//			target = choice
//		else
//			return

/datum/discipline/animalism
	name = "Animalism"
	desc = "Summons Spectral Animals over your targets. Violates Masquerade."
	icon_state = "animalism"
	cost = 1
	delay = 20
	ranged = FALSE
	violates_masquerade = TRUE
	activate_sound = 'code/modules/ziggers/sounds/wolves.ogg'
	dead_restricted = FALSE
	var/obj/effect/proc_holder/spell/targeted/shapeshift/animalism/AN

/obj/effect/spectral_wolf
	name = "Spectral Wolf"
	desc = "Bites enemies in other dimensions."
	icon = 'code/modules/ziggers/icons.dmi'
	icon_state = "wolf"
	plane = GAME_PLANE
	layer = ABOVE_ALL_MOB_LAYER

/obj/effect/proc_holder/spell/targeted/shapeshift/animalism
	name = "Animalism Form"
	desc = "Take on the shape a rat."
	charge_max = 50
	cooldown_min = 50
	revert_on_death = TRUE
	die_with_shapeshifted_form = FALSE
	shapeshift_type = /mob/living/simple_animal/pet/rat

/datum/discipline/animalism/activate(mob/living/target, mob/living/carbon/human/caster)
	. = ..()
	if(!AN)
		AN = new(caster)
	var/limit = level+caster.social
	if(length(caster.beastmaster) >= limit)
		var/mob/living/simple_animal/hostile/beastmaster/B = pick(caster.beastmaster)
		B.death()
	switch(level_casting)
		if(1)
			if(!length(caster.beastmaster))
				var/datum/action/beastmaster_stay/E1 = new()
				E1.Grant(caster)
				var/datum/action/beastmaster_deaggro/E2 = new()
				E2.Grant(caster)
			var/mob/living/simple_animal/hostile/beastmaster/rat/R = new(get_turf(caster))
			R.my_creator = caster
			caster.beastmaster |= R
			R.beastmaster = caster
		if(2)
			if(!length(caster.beastmaster))
				var/datum/action/beastmaster_stay/E1 = new()
				E1.Grant(caster)
				var/datum/action/beastmaster_deaggro/E2 = new()
				E2.Grant(caster)
			var/mob/living/simple_animal/hostile/beastmaster/cat/C = new(get_turf(caster))
			C.my_creator = caster
			caster.beastmaster |= C
			C.beastmaster = caster
		if(3)
			if(!length(caster.beastmaster))
				var/datum/action/beastmaster_stay/E1 = new()
				E1.Grant(caster)
				var/datum/action/beastmaster_deaggro/E2 = new()
				E2.Grant(caster)
			var/mob/living/simple_animal/hostile/beastmaster/D = new(get_turf(caster))
			D.my_creator = caster
			caster.beastmaster |= D
			D.beastmaster = caster
		if(4)
			if(!length(caster.beastmaster))
				var/datum/action/beastmaster_stay/E1 = new()
				E1.Grant(caster)
				var/datum/action/beastmaster_deaggro/E2 = new()
				E2.Grant(caster)
			var/mob/living/simple_animal/hostile/beastmaster/rat/flying/F = new(get_turf(caster))
			F.my_creator = caster
			caster.beastmaster |= F
			F.beastmaster = caster
		if(5)
			AN.Shapeshift(caster)
//			caster.dna.species.attack_verb = "slash"
//			caster.dna.species.attack_sound = 'sound/weapons/slash.ogg'
//			caster.dna.species.punchdamagelow = caster.dna.species.punchdamagelow+20
//			caster.dna.species.punchdamagehigh = caster.dna.species.punchdamagehigh+20
//			caster.add_movespeed_modifier(/datum/movespeed_modifier/protean3)
//			caster.remove_overlay(PROTEAN_LAYER)
//			caster.overlays_standing[PROTEAN_LAYER] = protean_overlay
//			caster.apply_overlay(PROTEAN_LAYER)
			spawn(200+caster.discipline_time_plus)
				if(caster && caster.stat != DEAD)
					AN.Restore(AN.myshape)
					caster.Stun(15)

/datum/discipline/auspex
	name = "Auspex"
	desc = "Allows to see entities, auras and their health through walls."
	icon_state = "auspex"
	cost = 1
	ranged = FALSE
	delay = 50
	leveldelay = TRUE

/datum/discipline/auspex/activate(mob/living/target, mob/living/carbon/human/caster)
	. = ..()
	var/sound/auspexbeat = sound('code/modules/ziggers/sounds/auspex.ogg', repeat = TRUE)
	caster.playsound_local(caster, auspexbeat, 75, 0, channel = CHANNEL_DISCIPLINES, use_reverb = FALSE)
	ADD_TRAIT(caster, TRAIT_THERMAL_VISION, TRAIT_GENERIC)
	var/loh = FALSE
	if(!HAS_TRAIT(caster, TRAIT_NIGHT_VISION))
		ADD_TRAIT(caster, TRAIT_NIGHT_VISION, TRAIT_GENERIC)
		loh = TRUE
	caster.update_sight()
	caster.add_client_colour(/datum/client_colour/glass_colour/lightblue)
	var/shitcasted = FALSE
	if(level_casting >= 2)
		var/datum/atom_hud/abductor_hud = GLOB.huds[DATA_HUD_ABDUCTOR]
		abductor_hud.add_hud_to(caster)
	if(level_casting >= 3)
		var/datum/atom_hud/health_hud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
		health_hud.add_hud_to(caster)
	if(level_casting >= 4)
		caster.auspex_examine = TRUE
	if(level_casting >= 5)
		caster.see_invisible = SEE_INVISIBLE_OBSERVER
		GLOB.auspex_list += caster
		shitcasted = TRUE
	spawn((delay*level_casting)+caster.discipline_time_plus)
		if(caster)
			if(shitcasted)
				GLOB.auspex_list -= caster
			caster.auspex_examine = FALSE
			caster.see_invisible = initial(caster.see_invisible)
			var/datum/atom_hud/abductor_hud = GLOB.huds[DATA_HUD_ABDUCTOR]
			abductor_hud.remove_hud_from(caster)
			var/datum/atom_hud/health_hud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
			health_hud.remove_hud_from(caster)
			caster.stop_sound_channel(CHANNEL_DISCIPLINES)
			playsound(caster.loc, 'code/modules/ziggers/sounds/auspex_deactivate.ogg', 50, FALSE)
			REMOVE_TRAIT(caster, TRAIT_THERMAL_VISION, TRAIT_GENERIC)
			if(loh)
				REMOVE_TRAIT(caster, TRAIT_NIGHT_VISION, TRAIT_GENERIC)
			caster.remove_client_colour(/datum/client_colour/glass_colour/lightblue)
			caster.update_sight()

/datum/discipline/celerity
	name = "Celerity"
	desc = "Boosts your speed. Violates Masquerade."
	icon_state = "celerity"
	cost = 1
	ranged = FALSE
	delay = 50
	violates_masquerade = FALSE
	activate_sound = 'code/modules/ziggers/sounds/celerity_activate.ogg'
	leveldelay = TRUE

/obj/effect/celerity
	name = "Damn"
	desc = "..."
	anchored = 1

/obj/effect/celerity/Initialize()
	. = ..()
	spawn(5)
		qdel(src)

/mob/living/carbon/human
	var/celerity_visual = FALSE
	var/potential = 0

/mob/living/carbon/human/Move(atom/newloc, direct, glide_size_override)
	..()
	if(celerity_visual)
		var/obj/effect/celerity/C = new(loc)
		C.name = name
		C.appearance = appearance
		C.dir = dir
		animate(C, pixel_x = rand(-16, 16), pixel_y = rand(-16, 16), alpha = 0, time = 5)
		if(CheckEyewitness(src, src, 7, FALSE))
			AdjustMasquerade(-1)

/datum/movespeed_modifier/celerity
	multiplicative_slowdown = -0.5

/datum/movespeed_modifier/celerity2
	multiplicative_slowdown = -0.75

/datum/movespeed_modifier/celerity3
	multiplicative_slowdown = -1

/datum/movespeed_modifier/celerity4
	multiplicative_slowdown = -1.25

/datum/movespeed_modifier/celerity5
	multiplicative_slowdown = -1.5

/datum/movespeed_modifier/wing
	multiplicative_slowdown = -0.25

/datum/movespeed_modifier/dominate
	multiplicative_slowdown = 5

/datum/discipline/celerity/activate(mob/living/target, mob/living/carbon/human/caster)
	. = ..()
	switch(level_casting)
		if(1)
			caster.add_movespeed_modifier(/datum/movespeed_modifier/celerity)
			caster.celerity_visual = TRUE
			spawn((delay*level_casting)+caster.discipline_time_plus)
				if(caster)
					playsound(caster.loc, 'code/modules/ziggers/sounds/celerity_deactivate.ogg', 50, FALSE)
					caster.remove_movespeed_modifier(/datum/movespeed_modifier/celerity)
					caster.celerity_visual = FALSE
		if(2)
			caster.add_movespeed_modifier(/datum/movespeed_modifier/celerity2)
			caster.celerity_visual = TRUE
			spawn((delay*level_casting)+caster.discipline_time_plus)
				if(caster)
					playsound(caster.loc, 'code/modules/ziggers/sounds/celerity_deactivate.ogg', 50, FALSE)
					caster.remove_movespeed_modifier(/datum/movespeed_modifier/celerity2)
					caster.celerity_visual = FALSE
		if(3)
			caster.add_movespeed_modifier(/datum/movespeed_modifier/celerity3)
			caster.celerity_visual = TRUE
			spawn((delay*level_casting)+caster.discipline_time_plus)
				if(caster)
					playsound(caster.loc, 'code/modules/ziggers/sounds/celerity_deactivate.ogg', 50, FALSE)
					caster.remove_movespeed_modifier(/datum/movespeed_modifier/celerity3)
					caster.celerity_visual = FALSE
		if(4)
			caster.add_movespeed_modifier(/datum/movespeed_modifier/celerity4)
			caster.celerity_visual = TRUE
			spawn((delay*level_casting)+caster.discipline_time_plus)
				if(caster)
					playsound(caster.loc, 'code/modules/ziggers/sounds/celerity_deactivate.ogg', 50, FALSE)
					caster.remove_movespeed_modifier(/datum/movespeed_modifier/celerity4)
					caster.celerity_visual = FALSE
		if(5)
			caster.add_movespeed_modifier(/datum/movespeed_modifier/celerity5)
			caster.celerity_visual = TRUE
			spawn((delay*level_casting)+caster.discipline_time_plus)
				if(caster)
					playsound(caster.loc, 'code/modules/ziggers/sounds/celerity_deactivate.ogg', 50, FALSE)
					caster.remove_movespeed_modifier(/datum/movespeed_modifier/celerity5)
					caster.celerity_visual = FALSE

/datum/discipline/dominate
	name = "Dominate"
	desc = "Supresses will of your targets and forces them to obey you, if their will is not more powerful than yours."
	icon_state = "dominate"
	cost = 1
	ranged = TRUE
	delay = 150
	activate_sound = 'code/modules/ziggers/sounds/dominate.ogg'
	fearless = TRUE

/datum/discipline/dominate/activate(mob/living/target, mob/living/carbon/human/caster)
	. = ..()
	if(target.spell_immunity)
		return
	var/mypower = 13-caster.generation+caster.social
	var/theirpower = 13-target.generation+target.mentality
	if(theirpower > mypower)
		to_chat(caster, "<span class='warning'>[target] is too powerful for you!</span>")
		return
	if(HAS_TRAIT(caster, TRAIT_MUTE))
		to_chat(caster, "<span class='warning'>You find yourself unable to speak!</span>")
		return
	var/mob/living/carbon/human/TRGT
	if(ishuman(target))
		TRGT = target
		TRGT.remove_overlay(MUTATIONS_LAYER)
		var/mutable_appearance/dominate_overlay = mutable_appearance('code/modules/ziggers/icons.dmi', "dominate", -MUTATIONS_LAYER)
		dominate_overlay.pixel_z = 2
		TRGT.overlays_standing[MUTATIONS_LAYER] = dominate_overlay
		TRGT.apply_overlay(MUTATIONS_LAYER)
	switch(level_casting)
		if(1)
			to_chat(target, "<span class='userdanger'><b>FORGET ABOUT IT</b></span>")
			caster.say("FORGET ABOUT IT!!")
			ADD_TRAIT(target, TRAIT_BLIND, "dominate")
			spawn(30)
				if(target)
					REMOVE_TRAIT(target, TRAIT_BLIND, "dominate")
		if(2)
			target.Immobilize(5)
			if(target.body_position == STANDING_UP)
				to_chat(target, "<span class='userdanger'><b>GET DOWN</b></span>")
				target.toggle_resting()
				caster.say("GET DOWN!!")
			else
				to_chat(target, "<span class='userdanger'><b>STAY DOWN</b></span>")
				caster.say("STAY DOWN!!")
		if(3)
			to_chat(target, "<span class='userdanger'><b>THINK TWICE</b></span>")
			caster.say("THINK TWICE!!")
			target.add_movespeed_modifier(/datum/movespeed_modifier/dominate)
			spawn(30)
				if(target)
					target.remove_movespeed_modifier(/datum/movespeed_modifier/dominate)
		if(4)
			to_chat(target, "<span class='userdanger'><b>THINK TWICE</b></span>")
			caster.say("THINK TWICE!!")
			target.add_movespeed_modifier(/datum/movespeed_modifier/dominate)
			spawn(60)
				if(target)
					target.remove_movespeed_modifier(/datum/movespeed_modifier/dominate)
		if(5)
			if(!target.spell_immunity)
				to_chat(target, "<span class='userdanger'><b>YOU SHOULD KILL YOURSELF NOW</b></span>")
				caster.say("YOU SHOULD KILL YOURSELF NOW!!")
				if(iskindred(target))
					target.Immobilize(5*level_casting)
					target.drop_all_held_items()
					target.visible_message("<span class='warning'><b>[target] tries to wring \his neck!</b></span>", "<span class='warning'><b>You try to wring your own neck!</b></span>")
					playsound(target.loc, 'code/modules/ziggers/sounds/suicide.ogg', 80, TRUE)
					target.apply_damage(5*level_casting, BRUTE, BODY_ZONE_HEAD)
				else
					target.drop_all_held_items()
					target.Immobilize(10)
					spawn(10)
						target.visible_message("<span class='warning'><b>[target] wrings \his neck!</b></span>", "<span class='warning'><b>You wring your own neck!</b></span>")
						playsound(target.loc, 'code/modules/ziggers/sounds/suicide.ogg', 80, TRUE)
						target.death()
	spawn(20)
		if(TRGT)
			TRGT.remove_overlay(MUTATIONS_LAYER)

/datum/discipline/dementation
	name = "Dementation"
	desc = "Makes all humans in radius mentally ill for a moment, supressing their defending ability."
	icon_state = "dementation"
	cost = 2
	ranged = TRUE
	delay = 100
	activate_sound = 'code/modules/ziggers/sounds/insanity.ogg'
	clane_restricted = TRUE

/mob/living
	var/dancing = FALSE

/proc/dancefirst(mob/living/M)
	if(M.dancing)
		return
	M.dancing = TRUE
	var/matrix/initial_matrix = matrix(M.transform)
	for (var/i in 1 to 75)
		if (!M)
			return
		switch(i)
			if (1 to 15)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(0,1)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if (16 to 30)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(1,-1)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if (31 to 45)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(-1,-1)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if (46 to 60)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(-1,1)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if (61 to 75)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(1,0)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
		M.setDir(turn(M.dir, 90))
		switch (M.dir)
			if (NORTH)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(0,3)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if (SOUTH)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(0,-3)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if (EAST)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(3,0)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if (WEST)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(-3,0)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
		sleep(1)
	M.lying_fix()
	M.dancing = FALSE

/proc/dancesecond(mob/living/M)
	if(M.dancing)
		return
	M.dancing = TRUE
	animate(M, transform = matrix(180, MATRIX_ROTATE), time = 1, loop = 0)
	var/matrix/initial_matrix = matrix(M.transform)
	for (var/i in 1 to 60)
		if (!M)
			return
		if (i<31)
			initial_matrix = matrix(M.transform)
			initial_matrix.Translate(0,1)
			animate(M, transform = initial_matrix, time = 1, loop = 0)
		if (i>30)
			initial_matrix = matrix(M.transform)
			initial_matrix.Translate(0,-1)
			animate(M, transform = initial_matrix, time = 1, loop = 0)
		M.setDir(turn(M.dir, 90))
		switch (M.dir)
			if (NORTH)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(0,3)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if (SOUTH)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(0,-3)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if (EAST)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(3,0)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if (WEST)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(-3,0)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
		sleep(1)
	M.lying_fix()
	M.dancing = FALSE

/datum/discipline/dementation/activate(mob/living/target, mob/living/carbon/human/caster)
	. = ..()
	//1 - instant laugh
	//2 - hallucinations and less damage
	//3 - victim dances
	//4 - victim fake dies
	//5 - victim starts to attack themself
	if(target.spell_immunity)
		return
	var/mypower = 13-caster.generation+caster.social
	var/theirpower = 13-target.generation+target.mentality
	if(theirpower > mypower)
		to_chat(caster, "<span class='warning'>[target] is too powerful for you!</span>")
		return
	if(!ishuman(target))
		to_chat(caster, "<span class='warning'>[target] doesn't have enough mind to get affected by this discipline!</span>")
		return
	var/mob/living/carbon/human/H = target
	H.remove_overlay(MUTATIONS_LAYER)
	var/mutable_appearance/dementation_overlay = mutable_appearance('code/modules/ziggers/icons.dmi', "dementation", -MUTATIONS_LAYER)
	dementation_overlay.pixel_z = 1
	H.overlays_standing[MUTATIONS_LAYER] = dementation_overlay
	H.apply_overlay(MUTATIONS_LAYER)
	switch(level_casting)
		if(1)
			H.Stun(5)
			H.emote("laugh")
			to_chat(target, "<span class='userdanger'><b>HAHAHAHAHAHAHAHAHAHAHAHA!!</b></span>")
			playsound(get_turf(H), pick('sound/items/SitcomLaugh1.ogg', 'sound/items/SitcomLaugh2.ogg', 'sound/items/SitcomLaugh3.ogg'), 100, FALSE)
			if(target.body_position == STANDING_UP)
				target.toggle_resting()
		if(2)
//			H.Immobilize(10)
			H.hallucination += 50
			new /datum/hallucination/oh_yeah(H, TRUE)
		if(3)
			H.Immobilize(20)
			if(H.stat <= 2 && !H.IsSleeping() && !H.IsUnconscious() && !H.IsParalyzed() && !H.IsKnockdown() && !HAS_TRAIT(H, TRAIT_RESTRAINED))
				if(prob(50))
					dancefirst(H)
				else
					dancesecond(H)
		if(4)
//			H.Immobilize(20)
			new /datum/hallucination/death(H, TRUE)
		if(5)
			var/datum/cb = CALLBACK(H,/mob/living/carbon/human/proc/attack_myself_shit)
			for(var/i in 1 to 20)
				addtimer(cb, (i - 1)*15)
	spawn(delay+caster.discipline_time_plus)
		if(H)
			H.remove_overlay(MUTATIONS_LAYER)

/datum/discipline/potence
	name = "Potence"
	desc = "Boosts melee and unarmed damage."
	icon_state = "potence"
	cost = 1
	ranged = FALSE
	delay = 100
	activate_sound = 'code/modules/ziggers/sounds/potence_activate.ogg'
	var/datum/component/tackler

/datum/discipline/potence/activate(mob/living/target, mob/living/carbon/human/caster)
	. = ..()
	var/mod = 8*level_casting
	var/armah = 0.4*level_casting
	caster.remove_overlay(POTENCE_LAYER)
	var/mutable_appearance/potence_overlay = mutable_appearance('code/modules/ziggers/icons.dmi', "potence", -POTENCE_LAYER)
	caster.overlays_standing[POTENCE_LAYER] = potence_overlay
	caster.apply_overlay(POTENCE_LAYER)
	caster.dna.species.punchdamagelow += mod
	caster.dna.species.punchdamagehigh += mod
	caster.dna.species.meleemod += armah
	caster.dna.species.attack_sound = 'code/modules/ziggers/sounds/heavypunch.ogg'
	tackler = caster.AddComponent(/datum/component/tackler, stamina_cost=0, base_knockdown = 1 SECONDS, range = 2+level_casting, speed = 1, skill_mod = 0, min_distance = 0)
	caster.potential = level_casting
	spawn(delay+caster.discipline_time_plus)
		if(caster)
			if(caster.dna)
				if(caster.dna.species)
					playsound(caster.loc, 'code/modules/ziggers/sounds/potence_deactivate.ogg', 50, FALSE)
					caster.dna.species.punchdamagelow -= mod
					caster.dna.species.punchdamagehigh -= mod
					caster.dna.species.meleemod -= armah
					caster.dna.species.attack_sound = initial(caster.dna.species.attack_sound)
					caster.remove_overlay(POTENCE_LAYER)
					caster.potential = 0
					qdel(tackler)

/datum/discipline/fortitude
	name = "Fortitude"
	desc = "Boosts armor."
	icon_state = "fortitude"
	cost = 1
	ranged = FALSE
	delay = 100
	activate_sound = 'code/modules/ziggers/sounds/fortitude_activate.ogg'

/datum/discipline/fortitude/activate(mob/living/target, mob/living/carbon/human/caster)
	. = ..()
	var/mod = min(3, level_casting)
	var/armah = 15*mod
	caster.remove_overlay(FORTITUDE_LAYER)
	var/mutable_appearance/fortitude_overlay = mutable_appearance('code/modules/ziggers/icons.dmi', "fortitude", -FORTITUDE_LAYER)
	caster.overlays_standing[FORTITUDE_LAYER] = fortitude_overlay
	caster.apply_overlay(FORTITUDE_LAYER)
	caster.physiology.armor.melee += armah
	caster.physiology.armor.bullet += armah
	spawn(delay+caster.discipline_time_plus)
		if(caster)
			playsound(caster.loc, 'code/modules/ziggers/sounds/fortitude_deactivate.ogg', 50, FALSE)
			caster.physiology.armor.melee -= armah
			caster.physiology.armor.bullet -= armah
			caster.remove_overlay(FORTITUDE_LAYER)

/datum/discipline/obfuscate
	name = "Obfuscate"
	desc = "Makes you less noticable for living and un-living beings."
	icon_state = "obfuscate"
	cost = 1
	ranged = FALSE
	delay = 100
	activate_sound = 'code/modules/ziggers/sounds/obfuscate_activate.ogg'
	leveldelay = TRUE

/mob/living/carbon/human
	var/obfuscate_level = 0

/datum/discipline/obfuscate/activate(mob/living/target, mob/living/carbon/human/caster)
	. = ..()
	for(var/mob/living/carbon/human/npc/NPC in GLOB.npc_list)
		if(NPC)
			if(NPC.danger_source == caster)
				NPC.danger_source = null
	caster.alpha = 10
	caster.obfuscate_level = level_casting
	spawn((delay*level_casting)+caster.discipline_time_plus)
		if(caster)
			if(caster.alpha != 255)
				playsound(caster.loc, 'code/modules/ziggers/sounds/obfuscate_deactivate.ogg', 50, FALSE)
				caster.alpha = 255

/datum/discipline/presence
	name = "Presence"
	desc = "Makes targets in radius more vulnerable to damages."
	icon_state = "presence"
	cost = 1
	ranged = TRUE
	delay = 50
	activate_sound = 'code/modules/ziggers/sounds/presence_activate.ogg'
	leveldelay = FALSE
	fearless = TRUE

/mob/living/carbon/human
	var/mob/living/my_nigga

/mob/living/carbon/human/proc/walk_to_my_nigga()
	walk(src, 0)
	if(!CheckFrenzyMove())
		set_glide_size(DELAY_TO_GLIDE_SIZE(total_multiplicative_slowdown()))
		step_to(src,my_nigga,0)
		face_atom(my_nigga)

/mob/living/carbon/human/proc/step_away_my_nigga()
	walk(src, 0)
	if(!CheckFrenzyMove())
		set_glide_size(DELAY_TO_GLIDE_SIZE(total_multiplicative_slowdown()))
		step_away(src,my_nigga,99)
		face_atom(my_nigga)

/mob/living/carbon/human/proc/attack_myself_shit()
	if(!CheckFrenzyMove())
		a_intent = INTENT_HARM
		var/obj/item/I = get_active_held_item()
		if(I)
			if(I.force)
				ClickOn(src)
			else
				drop_all_held_items()
				ClickOn(src)
		else
			ClickOn(src)

/datum/discipline/presence/activate(mob/living/target, mob/living/carbon/human/caster)
	. = ..()
	var/mypower = 13-caster.generation+caster.social
	var/theirpower = 13-target.generation+target.mentality
	if(theirpower > mypower)
		to_chat(caster, "<span class='warning'>[target] is too powerful for you!</span>")
		return
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.remove_overlay(MUTATIONS_LAYER)
		var/mutable_appearance/presence_overlay = mutable_appearance('code/modules/ziggers/icons.dmi', "presence", -MUTATIONS_LAYER)
		presence_overlay.pixel_z = 1
		H.overlays_standing[MUTATIONS_LAYER] = presence_overlay
		H.apply_overlay(MUTATIONS_LAYER)
		H.my_nigga = caster
		switch(level_casting)
			if(1)
				var/datum/cb = CALLBACK(H,/mob/living/carbon/human/proc/walk_to_my_nigga)
				for(var/i in 1 to 30)
					addtimer(cb, (i - 1)*H.total_multiplicative_slowdown())
				to_chat(target, "<span class='userlove'><b>COME HERE</b></span>")
				caster.say("COME HERE!!")
			if(2)
				target.Stun(10)
				to_chat(target, "<span class='userlove'><b>REST</b></span>")
				caster.say("REST!!")
				if(target.body_position == STANDING_UP)
					target.toggle_resting()
			if(3)
				var/obj/item/I1 = H.get_active_held_item()
				var/obj/item/I2 = H.get_inactive_held_item()
				to_chat(target, "<span class='userlove'><b>PLEASE ME</b></span>")
				caster.say("PLEASE ME!!")
				target.face_atom(caster)
				target.do_jitter_animation(30)
				target.Immobilize(10)
				target.drop_all_held_items()
				if(I1)
					I1.throw_at(get_turf(caster), 3, 1, target)
				if(I2)
					I2.throw_at(get_turf(caster), 3, 1, target)
			if(4)
				to_chat(target, "<span class='userlove'><b>FEAR ME</b></span>")
				caster.say("FEAR ME!!")
				var/datum/cb = CALLBACK(H,/mob/living/carbon/human/proc/step_away_my_nigga)
				for(var/i in 1 to 30)
					addtimer(cb, (i - 1)*H.total_multiplicative_slowdown())
				target.emote("scream")
				target.do_jitter_animation(30)
			if(5)
				to_chat(target, "<span class='userlove'><b>UNDRESS YOURSELF</b></span>")
				caster.say("UNDRESS YOURSELF!!")
				target.Immobilize(10)
				for(var/obj/item/clothing/W in H.contents)
					if(W)
						H.dropItemToGround(W, TRUE)
		spawn(delay+caster.discipline_time_plus)
			if(H)
				H.remove_overlay(MUTATIONS_LAYER)
				if(caster)
					playsound(caster.loc, 'code/modules/ziggers/sounds/presence_deactivate.ogg', 50, FALSE)

/datum/discipline/protean
	name = "Protean"
	desc = "Lets your beast out, making you stronger and faster. Violates Masquerade."
	icon_state = "protean"
	cost = 1
	ranged = FALSE
	delay = 200
	violates_masquerade = TRUE
	activate_sound = 'code/modules/ziggers/sounds/protean_activate.ogg'
	clane_restricted = TRUE
	var/obj/effect/proc_holder/spell/targeted/shapeshift/gangrel/GA

/datum/movespeed_modifier/protean2
	multiplicative_slowdown = -0.15

/obj/effect/proc_holder/spell/targeted/shapeshift/gangrel
	name = "Gangrel Form"
	desc = "Take on the shape a wolf."
	charge_max = 50
	cooldown_min = 50
	revert_on_death = TRUE
	die_with_shapeshifted_form = FALSE
	shapeshift_type = /mob/living/simple_animal/hostile/gangrel

/datum/discipline/protean/activate(mob/living/target, mob/living/carbon/human/caster)
	. = ..()
	var/mod = min(4, level_casting)
//	var/mutable_appearance/protean_overlay = mutable_appearance('code/modules/ziggers/icons.dmi', "protean[mod]", -PROTEAN_LAYER)
	if(!GA)
		GA = new(caster)
	switch(mod)
		if(1)
			caster.drop_all_held_items()
			caster.put_in_r_hand(new /obj/item/melee/vampirearms/knife/gangrel(caster))
			caster.put_in_l_hand(new /obj/item/melee/vampirearms/knife/gangrel(caster))
			caster.add_client_colour(/datum/client_colour/glass_colour/red)
//			caster.dna.species.attack_verb = "slash"
//			caster.dna.species.attack_sound = 'sound/weapons/slash.ogg'
//			caster.dna.species.punchdamagelow = caster.dna.species.punchdamagelow+10
//			caster.dna.species.punchdamagehigh = caster.dna.species.punchdamagehigh+10
//			caster.remove_overlay(PROTEAN_LAYER)
//			caster.overlays_standing[PROTEAN_LAYER] = protean_overlay
//			caster.apply_overlay(PROTEAN_LAYER)
			spawn(delay+caster.discipline_time_plus)
				if(caster)
					for(var/obj/item/melee/vampirearms/knife/gangrel/G in caster.contents)
						if(G)
							qdel(G)
					caster.remove_client_colour(/datum/client_colour/glass_colour/red)
//					if(caster.dna)
					playsound(caster.loc, 'code/modules/ziggers/sounds/protean_deactivate.ogg', 50, FALSE)
//						caster.dna.species.attack_verb = initial(caster.dna.species.attack_verb)
//						caster.dna.species.attack_sound = initial(caster.dna.species.attack_sound)
//						caster.dna.species.punchdamagelow = caster.dna.species.punchdamagelow-10
//						caster.dna.species.punchdamagehigh = caster.dna.species.punchdamagehigh-10
//						caster.remove_overlay(PROTEAN_LAYER)
		if(2)
			caster.drop_all_held_items()
			caster.put_in_r_hand(new /obj/item/melee/vampirearms/knife/gangrel(caster))
			caster.put_in_l_hand(new /obj/item/melee/vampirearms/knife/gangrel(caster))
			caster.add_client_colour(/datum/client_colour/glass_colour/red)
//			caster.dna.species.attack_verb = "slash"
//			caster.dna.species.attack_sound = 'sound/weapons/slash.ogg'
//			caster.dna.species.punchdamagelow = caster.dna.species.punchdamagelow+15
//			caster.dna.species.punchdamagehigh = caster.dna.species.punchdamagehigh+15
			caster.add_movespeed_modifier(/datum/movespeed_modifier/protean2)
//			caster.remove_overlay(PROTEAN_LAYER)
//			caster.overlays_standing[PROTEAN_LAYER] = protean_overlay
//			caster.apply_overlay(PROTEAN_LAYER)
			spawn(delay+caster.discipline_time_plus)
				if(caster)
					for(var/obj/item/melee/vampirearms/knife/gangrel/G in caster.contents)
						if(G)
							qdel(G)
					caster.remove_client_colour(/datum/client_colour/glass_colour/red)
//					if(caster.dna)
					playsound(caster.loc, 'code/modules/ziggers/sounds/protean_deactivate.ogg', 50, FALSE)
//						caster.dna.species.attack_verb = initial(caster.dna.species.attack_verb)
//						caster.dna.species.attack_sound = initial(caster.dna.species.attack_sound)
//						caster.dna.species.punchdamagelow = caster.dna.species.punchdamagelow-15
//						caster.dna.species.punchdamagehigh = caster.dna.species.punchdamagehigh-15
					caster.remove_movespeed_modifier(/datum/movespeed_modifier/protean2)
//						caster.remove_overlay(PROTEAN_LAYER)
		if(3)
			caster.drop_all_held_items()
			GA.Shapeshift(caster)
//			caster.dna.species.attack_verb = "slash"
//			caster.dna.species.attack_sound = 'sound/weapons/slash.ogg'
//			caster.dna.species.punchdamagelow = caster.dna.species.punchdamagelow+20
//			caster.dna.species.punchdamagehigh = caster.dna.species.punchdamagehigh+20
//			caster.add_movespeed_modifier(/datum/movespeed_modifier/protean3)
//			caster.remove_overlay(PROTEAN_LAYER)
//			caster.overlays_standing[PROTEAN_LAYER] = protean_overlay
//			caster.apply_overlay(PROTEAN_LAYER)
			spawn(delay+caster.discipline_time_plus)
				if(caster && caster.stat != DEAD)
					GA.Restore(GA.myshape)
					caster.Stun(15)
					caster.do_jitter_animation(30)
//					if(caster.dna)
					playsound(caster, 'code/modules/ziggers/sounds/protean_deactivate.ogg', 50, FALSE)
//						caster.dna.species.attack_verb = initial(caster.dna.species.attack_verb)
//						caster.dna.species.attack_sound = initial(caster.dna.species.attack_sound)
//						caster.dna.species.punchdamagelow = caster.dna.species.punchdamagelow-20
//						caster.dna.species.punchdamagehigh = caster.dna.species.punchdamagehigh-20
//						caster.remove_movespeed_modifier(/datum/movespeed_modifier/protean3)
//						caster.remove_overlay(PROTEAN_LAYER)
		if(4 to 5)
			caster.drop_all_held_items()
			if(level_casting == 4)
				GA.shapeshift_type = /mob/living/simple_animal/hostile/gangrel/better
			if(level_casting == 5)
				GA.shapeshift_type = /mob/living/simple_animal/hostile/gangrel/best
			GA.Shapeshift(caster)
//			caster.dna.species.attack_verb = "slash"
//			caster.dna.species.attack_sound = 'sound/weapons/slash.ogg'
//			caster.dna.species.punchdamagelow = caster.dna.species.punchdamagelow+25
//			caster.dna.species.punchdamagehigh = caster.dna.species.punchdamagelow+25
//			if(level_casting == 5)
//				caster.add_movespeed_modifier(/datum/movespeed_modifier/protean5)
//			else
//				caster.add_movespeed_modifier(/datum/movespeed_modifier/protean4)
//			caster.remove_overlay(PROTEAN_LAYER)
//			caster.overlays_standing[PROTEAN_LAYER] = protean_overlay
//			caster.apply_overlay(PROTEAN_LAYER)
			spawn(delay+caster.discipline_time_plus)
				if(caster && caster.stat != DEAD)
					GA.Restore(GA.myshape)
					caster.Stun(15)
					caster.do_jitter_animation(30)
//					if(caster.dna)
					playsound(caster, 'code/modules/ziggers/sounds/protean_deactivate.ogg', 50, FALSE)
//						caster.dna.species.attack_verb = initial(caster.dna.species.attack_verb)
//						caster.dna.species.attack_sound = initial(caster.dna.species.attack_sound)
//						caster.dna.species.punchdamagelow = caster.dna.species.punchdamagelow-25
//						caster.dna.species.punchdamagehigh = caster.dna.species.punchdamagehigh-25
//						if(level_casting == 5)
//							caster.remove_movespeed_modifier(/datum/movespeed_modifier/protean5)
//						else
//							caster.remove_movespeed_modifier(/datum/movespeed_modifier/protean4)
//						caster.remove_overlay(PROTEAN_LAYER)

/mob/living/proc/tremere_gib()
	Stun(50)
	new /obj/effect/temp_visual/tremere(loc, "gib")
	animate(src, pixel_y = 16, color = "#ff0000", time = 50, loop = 1)

	spawn(50)
		if(stat != DEAD)
			death()
		var/list/items = list()
		items |= get_equipped_items(TRUE)
		for(var/obj/item/I in items)
			dropItemToGround(I)
		drop_all_held_items()
		spawn_gibs()
		spawn_gibs()
		spawn_gibs()
		qdel(src)

/obj/effect/projectile/tracer/thaumaturgy
	name = "blood beam"
	icon_state = "cult"

/obj/effect/projectile/muzzle/thaumaturgy
	name = "blood beam"
	icon_state = "muzzle_cult"

/obj/effect/projectile/impact/thaumaturgy
	name = "blood beam"
	icon_state = "impact_cult"

/obj/projectile/thaumaturgy
	name = "blood beam"
	icon_state = "thaumaturgy"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 5
	damage_type = BURN
	hitsound = 'code/modules/ziggers/sounds/drinkblood1.ogg'
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	flag = LASER
	light_system = MOVABLE_LIGHT
	light_range = 1
	light_power = 1
	light_color = COLOR_SOFT_RED
	ricochets_max = 0
	ricochet_chance = 0
	tracer_type = /obj/effect/projectile/tracer/thaumaturgy
	muzzle_type = /obj/effect/projectile/muzzle/thaumaturgy
	impact_type = /obj/effect/projectile/impact/thaumaturgy
	var/level = 1

/obj/projectile/thaumaturgy/on_hit(atom/target, blocked = FALSE, pierce_hit)
	if(ishuman(firer))
		var/mob/living/carbon/human/VH = firer
		if(isliving(target))
			var/mob/living/VL = target
			if(!iskindred(target))
				if(VL.bloodpool >= 1 && VL.stat != DEAD)
					var/sucked = min(VL.bloodpool, 2)
					VL.bloodpool = VL.bloodpool-sucked
					VL.blood_volume = max(VL.blood_volume-50, 0)
					if(ishuman(VL))
						var/mob/living/carbon/human/VHL = VL
						VHL.blood_volume = max(VHL.blood_volume-10*sucked, 0)
						if(VL.bloodpool == 0)
							VHL.blood_volume = 0
							VL.death()
//							if(isnpc(VL))
//								AdjustHumanity(VH, -1, 3)
					else
						if(VL.bloodpool == 0)
							VL.death()
					VH.bloodpool = VH.bloodpool+(sucked*max(1, VL.bloodquality-1))
					VH.bloodpool = min(VH.maxbloodpool, VH.bloodpool)
			else
				if(VL.bloodpool >= 1)
					var/sucked = min(VL.bloodpool, 1*level)
					VH.bloodpool = VH.bloodpool+sucked
					VH.bloodpool = min(VH.maxbloodpool, VH.bloodpool)

/datum/discipline/thaumaturgy
	name = "Thaumaturgy"
	desc = "Opens the secrets of blood magic and how you use it, allows to steal other's blood. Violates Masquerade."
	icon_state = "thaumaturgy"
	cost = 1
	ranged = TRUE
	delay = 10
	violates_masquerade = TRUE
	activate_sound = 'code/modules/ziggers/sounds/thaum.ogg'
	clane_restricted = TRUE
	dead_restricted = FALSE

/datum/discipline/thaumaturgy/activate(mob/living/target, mob/living/carbon/human/caster)
	. = ..()
	switch(level_casting)
		if(1)
			var/turf/start = get_turf(caster)
			var/obj/projectile/thaumaturgy/H = new(start)
			H.firer = caster
			H.preparePixelProjectile(target, start)
			H.fire(direct_target = target)
		if(2)
			var/turf/start = get_turf(caster)
			var/obj/projectile/thaumaturgy/H = new(start)
			H.firer = caster
			H.damage = 10+caster.thaum_damage_plus
			H.preparePixelProjectile(target, start)
			H.level = 2
			H.fire(direct_target = target)
		if(3)
			var/turf/start = get_turf(caster)
			var/obj/projectile/thaumaturgy/H = new(start)
			H.firer = caster
			H.damage = 15+caster.thaum_damage_plus
			H.preparePixelProjectile(target, start)
			H.level = 2
			H.fire(direct_target = target)
		else
			if(iskindred(target))
				var/turf/start = get_turf(caster)
				var/obj/projectile/thaumaturgy/H = new(start)
				H.firer = caster
				H.damage = (5*level_casting)+caster.thaum_damage_plus
				H.preparePixelProjectile(target, start)
				H.level = round(level_casting/2)
				H.fire(direct_target = target)
			else
				caster.bloodpool = min(caster.maxbloodpool, caster.bloodpool+target.bloodpool)
				if(!istype(target, /mob/living/simple_animal/hostile/megafauna))
//				if(isnpc(target))
//					AdjustHumanity(caster, -1, 0)
					target.tremere_gib()
/*
/datum/discipline/bloodshield
	name = "Blood shield"
	desc = "Boosts armor."
	icon_state = "bloodshield"
	cost = 2
	ranged = FALSE
	delay = 150
	activate_sound = 'code/modules/ziggers/sounds/thaum.ogg'

/datum/discipline/bloodshield/activate(mob/living/target, mob/living/carbon/human/caster)
	..()
	var/mod = level_casting
	caster.physiology.armor.melee = caster.physiology.armor.melee+(15*mod)
	caster.physiology.armor.bullet = caster.physiology.armor.bullet+(15*mod)
	animate(caster, color = "#ff0000", time = 10, loop = 1)
//	caster.color = "#ff0000"
	spawn(delay+caster.discipline_time_plus)
		if(caster)
			playsound(caster.loc, 'code/modules/ziggers/sounds/thaum.ogg', 50, FALSE)
			caster.physiology.armor.melee = caster.physiology.armor.melee-(15*mod)
			caster.physiology.armor.bullet = caster.physiology.armor.bullet-(15*mod)
			caster.color = initial(caster.color)
*/

/datum/discipline/serpentis
	name = "Serpentis"
	desc = "Act like a cobra, get the powers to stun targets with your gaze and your tongue, praise the mummy traditions and spread them to your childe. Violates Masquerade."
	icon_state = "serpentis"
	cost = 1
	ranged = TRUE
	delay = 5
//	range_sh = 2
	violates_masquerade = TRUE
	clane_restricted = TRUE
	dead_restricted = FALSE

/datum/discipline/serpentis/activate(mob/living/target, mob/living/carbon/human/caster)
	. = ..()
	if(level_casting == 1)
		var/antidir = NORTH
		switch(caster.dir)
			if(NORTH)
				antidir = SOUTH
			if(SOUTH)
				antidir = NORTH
			if(WEST)
				antidir = EAST
			if(EAST)
				antidir = WEST
		if(target.dir == antidir)
			target.Immobilize(10)
			target.visible_message("<span class='warning'><b>[caster] hypnotizes [target] with his eyes!</b></span>", "<span class='warning'><b>[caster] hypnotizes you like a cobra!</b></span>")
			playsound(target.loc, 'code/modules/ziggers/sounds/serpentis.ogg', 50, TRUE)
			if(ishuman(target))
				var/mob/living/carbon/human/H = target
				H.remove_overlay(MUTATIONS_LAYER)
				var/mutable_appearance/serpentis_overlay = mutable_appearance('code/modules/ziggers/icons.dmi', "serpentis", -MUTATIONS_LAYER)
				H.overlays_standing[MUTATIONS_LAYER] = serpentis_overlay
				H.apply_overlay(MUTATIONS_LAYER)
				spawn(5)
					H.remove_overlay(MUTATIONS_LAYER)
	if(level_casting >= 2)
//		var/turf/start = get_turf(caster)
//		var/obj/projectile/tentacle/H = new(start)
//		H.hitsound = 'code/modules/ziggers/sounds/tongue.ogg'
		var/bloodpoints_to_suck = max(0, min(target.bloodpool, level_casting-1))
		if(bloodpoints_to_suck)
			caster.bloodpool = min(caster.maxbloodpool, caster.bloodpool+bloodpoints_to_suck)
			target.bloodpool = max(0, target.bloodpool-bloodpoints_to_suck)
		var/obj/item/ammo_casing/magic/tentacle/casing = new (caster.loc)
		playsound(caster.loc, 'code/modules/ziggers/sounds/tongue.ogg', 100, TRUE)
		casing.fire_casing(target, caster, null, null, null, ran_zone(), 0,  caster)
		playsound(target.loc, 'code/modules/ziggers/sounds/serpentis.ogg', 50, TRUE)
		qdel(casing)

/datum/discipline/vicissitude
	name = "Vicissitude"
	desc = "It is widely known as Tzimisce art of flesh and bone shaping. Violates Masquerade."
	icon_state = "vicissitude"
	cost = 1
	ranged = TRUE
	delay = 100
	range_sh = 2
	violates_masquerade = TRUE
	clane_restricted = TRUE
	dead_restricted = FALSE

/datum/discipline/vicissitude/activate(mob/living/target, mob/living/carbon/human/caster)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		playsound(target.loc, 'code/modules/ziggers/sounds/vicissitude.ogg', 50, TRUE)
		if(target.stat >= 2)
			if(istype(target, /mob/living/carbon/human/npc))
				var/mob/living/carbon/human/npc/NPC = target
				NPC.last_attacker = null
			if(!iskindred(target))
				if(H.stat != DEAD)
					H.death()
				switch(level_casting)
					if(1)
						new /obj/item/stack/human_flesh(target.loc)
						new /obj/item/guts(target.loc)
						qdel(target)
					if(2)
						new /obj/item/stack/human_flesh/five(target.loc)
						new /obj/item/guts(target.loc)
						new /obj/item/spine(target.loc)
						var/obj/item/bodypart/B = H.get_bodypart(pick(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))
						if(B)
							B.drop_limb()
						qdel(target)
					if(3)
						var/obj/item/bodypart/B1 = H.get_bodypart(BODY_ZONE_R_ARM)
						var/obj/item/bodypart/B2 = H.get_bodypart(BODY_ZONE_L_ARM)
						var/obj/item/bodypart/B3 = H.get_bodypart(BODY_ZONE_R_LEG)
						var/obj/item/bodypart/B4 = H.get_bodypart(BODY_ZONE_L_LEG)
						if(B1)
							B1.drop_limb()
						if(B2)
							B2.drop_limb()
						if(B3)
							B3.drop_limb()
						if(B4)
							B4.drop_limb()
						new /obj/item/stack/human_flesh/ten(target.loc)
						new /obj/item/guts(target.loc)
						new /obj/item/spine(target.loc)
						qdel(target)
					if(4)
						var/obj/item/bodypart/B1 = H.get_bodypart(BODY_ZONE_R_ARM)
						var/obj/item/bodypart/B2 = H.get_bodypart(BODY_ZONE_L_ARM)
						var/obj/item/bodypart/B3 = H.get_bodypart(BODY_ZONE_R_LEG)
						var/obj/item/bodypart/B4 = H.get_bodypart(BODY_ZONE_L_LEG)
						var/obj/item/bodypart/CH = H.get_bodypart(BODY_ZONE_CHEST)
						if(B1)
							B1.drop_limb()
						if(B2)
							B2.drop_limb()
						if(B3)
							B3.drop_limb()
						if(B4)
							B4.drop_limb()
						if(CH)
							CH.dismember()
						new /obj/item/stack/human_flesh/twenty(target.loc)
						qdel(target)
					if(5)
						var/obj/item/bodypart/B1 = H.get_bodypart(BODY_ZONE_R_ARM)
						var/obj/item/bodypart/B2 = H.get_bodypart(BODY_ZONE_L_ARM)
						var/obj/item/bodypart/B3 = H.get_bodypart(BODY_ZONE_R_LEG)
						var/obj/item/bodypart/B4 = H.get_bodypart(BODY_ZONE_L_LEG)
						var/obj/item/bodypart/CH = H.get_bodypart(BODY_ZONE_CHEST)
						var/obj/item/bodypart/HE = H.get_bodypart(BODY_ZONE_HEAD)
						if(B1)
							B1.drop_limb()
						if(B2)
							B2.drop_limb()
						if(B3)
							B3.drop_limb()
						if(B4)
							B4.drop_limb()
						if(CH)
							CH.dismember()
						if(HE)
							HE.dismember()
						new /obj/item/stack/human_flesh/fifty(target.loc)
						new /obj/item/guts(target.loc)
						new /obj/item/spine(target.loc)
						qdel(target)
		else
			target.emote("scream")
			target.apply_damage(10*level_casting, BRUTE, BODY_ZONE_CHEST)
			if(prob(5*level_casting))
				var/obj/item/bodypart/B = H.get_bodypart(pick(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))
				if(B)
					B.drop_limb()
	else
		target.death()

/turf
	var/silented = FALSE

/obj/projectile/quietus
	name = "acid spit"
	icon_state = "har4ok"
	pass_flags = PASSTABLE
	damage = 80
	damage_type = BURN
	hitsound = 'sound/weapons/effects/searwall.ogg'
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	ricochets_max = 0
	ricochet_chance = 0

/datum/discipline/quietus
	name = "Quietus"
	desc = "Make a poison out of nowhere and forces all beings in range to mute, poison your touch, poison your weapon, poison your spit and make it acid. Violates Masquerade."
	icon_state = "quietus"
	cost = 1
	ranged = FALSE
	delay = 50
//	range = 2
	violates_masquerade = TRUE
	clane_restricted = TRUE

/datum/discipline/quietus/activate(mob/living/target, mob/living/carbon/human/caster)
	. = ..()
	playsound(target.loc, 'code/modules/ziggers/sounds/quietus.ogg', 50, TRUE)
	switch(level_casting)
		if(1)
			for(var/mob/living/carbon/human/H in oviewers(7, caster))
				ADD_TRAIT(H, TRAIT_MUTE, "quietus")
				H.remove_overlay(MUTATIONS_LAYER)
				var/mutable_appearance/quietus_overlay = mutable_appearance('code/modules/ziggers/icons.dmi', "quietus", -MUTATIONS_LAYER)
				H.overlays_standing[MUTATIONS_LAYER] = quietus_overlay
				H.apply_overlay(MUTATIONS_LAYER)
				if(H.get_confusion() < 15)
					var/diff = 15 - H.get_confusion()
					H.add_confusion(min(15, diff))
				spawn(50)
					if(H)
						REMOVE_TRAIT(H, TRAIT_MUTE, "quietus")
						H.remove_overlay(MUTATIONS_LAYER)
		if(2)
			caster.drop_all_held_items()
			caster.put_in_active_hand(new /obj/item/melee/touch_attack/quietus(caster))
		if(3)
			if(caster.lastattacked)
				if(isliving(caster.lastattacked))
					var/mob/living/L = caster.lastattacked
					L.adjustStaminaLoss(80)
					L.adjustFireLoss(10)
					to_chat(caster, "You send your curse on [L], the last creature you attacked.")
				else
					to_chat(caster, "You don't seem to have last attacked soul earlier...")
					return
			else
				to_chat(caster, "You don't seem to have last attacked soul earlier...")
				return
		if(4)
			caster.drop_all_held_items()
			caster.put_in_active_hand(new /obj/item/quietus_upgrade(caster))
		if(5)
			caster.drop_all_held_items()
			caster.put_in_active_hand(new /obj/item/gun/magic/quietus(caster))

/obj/item/gun/magic/quietus
	name = "acid spit"
	desc = "Spit poison on your targets."
	icon = 'code/modules/ziggers/items.dmi'
	icon_state = "har4ok"
	item_flags = NEEDS_PERMIT | ABSTRACT | DROPDEL | NOBLUDGEON
	flags_1 = NONE
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = NONE
	ammo_type = /obj/item/ammo_casing/magic/quietus
	fire_sound = 'sound/effects/splat.ogg'
	force = 0
	max_charges = 1
	fire_delay = 1
	throwforce = 0 //Just to be on the safe side
	throw_range = 0
	throw_speed = 0
	item_flags = DROPDEL

/obj/item/ammo_casing/magic/quietus
	name = "acid spit"
	desc = "A spit."
	projectile_type = /obj/projectile/quietus
	caliber = CALIBER_TENTACLE
	firing_effect_type = null
	item_flags = DROPDEL

/obj/item/gun/magic/quietus/process_fire()
	. = ..()
	if(charges == 0)
		qdel(src)
/*
	playsound(target.loc, 'code/modules/ziggers/sounds/quietus.ogg', 50, TRUE)
	target.Stun(5*level_casting)
	if(level_casting >= 3)
		if(target.bloodpool > 1)
			var/transfered = max(1, target.bloodpool-3)
			caster.bloodpool = min(caster.maxbloodpool, caster.bloodpool+transfered)
			target.bloodpool = transfered
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.remove_overlay(MUTATIONS_LAYER)
		var/mutable_appearance/quietus_overlay = mutable_appearance('code/modules/ziggers/icons.dmi', "quietus", -MUTATIONS_LAYER)
		H.overlays_standing[MUTATIONS_LAYER] = quietus_overlay
		H.apply_overlay(MUTATIONS_LAYER)
		spawn(5*level_casting)
			H.remove_overlay(MUTATIONS_LAYER)
*/
/datum/discipline/necromancy
	name = "Necromancy"
	desc = "Offers control over another, undead reality."
	icon_state = "necromancy"
	cost = 1
	ranged = TRUE
	range_sh = 2
	delay = 50
	violates_masquerade = TRUE
	clane_restricted = TRUE
	dead_restricted = FALSE

/datum/discipline/necromancy/activate(mob/living/target, mob/living/carbon/human/caster)
	. = ..()
	playsound(target.loc, 'code/modules/ziggers/sounds/necromancy.ogg', 50, TRUE)
	var/limit = level+caster.social
	if(length(caster.beastmaster) >= limit)
		var/mob/living/simple_animal/hostile/beastmaster/B = pick(caster.beastmaster)
		B.death()
	if(target.stat == DEAD)
		switch(level_casting)
			if(1)
				if(!length(caster.beastmaster))
					var/datum/action/beastmaster_stay/E1 = new()
					E1.Grant(caster)
					var/datum/action/beastmaster_deaggro/E2 = new()
					E2.Grant(caster)
				var/mob/living/simple_animal/hostile/beastmaster/giovanni_zombie/M = new /mob/living/simple_animal/hostile/beastmaster/giovanni_zombie/level1(caster.loc)
				M.my_creator = caster
				caster.beastmaster |= M
				M.beastmaster = caster
//				if(target.key)
//					M.key = target.key
//				else
//					M.give_player()
				target.gib()
			if(2)
				if(!length(caster.beastmaster))
					var/datum/action/beastmaster_stay/E1 = new()
					E1.Grant(caster)
					var/datum/action/beastmaster_deaggro/E2 = new()
					E2.Grant(caster)
				var/mob/living/simple_animal/hostile/beastmaster/giovanni_zombie/M = new /mob/living/simple_animal/hostile/beastmaster/giovanni_zombie/level2(caster.loc)
				M.my_creator = caster
				caster.beastmaster |= M
				M.beastmaster = caster
				target.gib()
			if(3)
				if(!length(caster.beastmaster))
					var/datum/action/beastmaster_stay/E1 = new()
					E1.Grant(caster)
					var/datum/action/beastmaster_deaggro/E2 = new()
					E2.Grant(caster)
				var/mob/living/simple_animal/hostile/beastmaster/giovanni_zombie/M = new /mob/living/simple_animal/hostile/beastmaster/giovanni_zombie/level3(caster.loc)
				M.my_creator = caster
				caster.beastmaster |= M
				M.beastmaster = caster
				target.gib()
			if(4)
				if(!length(caster.beastmaster))
					var/datum/action/beastmaster_stay/E1 = new()
					E1.Grant(caster)
					var/datum/action/beastmaster_deaggro/E2 = new()
					E2.Grant(caster)
				var/mob/living/simple_animal/hostile/beastmaster/giovanni_zombie/M = new /mob/living/simple_animal/hostile/beastmaster/giovanni_zombie/level4(caster.loc)
				M.my_creator = caster
				caster.beastmaster |= M
				M.beastmaster = caster
				target.gib()
			if(5)
				if(!length(caster.beastmaster))
					var/datum/action/beastmaster_stay/E1 = new()
					E1.Grant(caster)
					var/datum/action/beastmaster_deaggro/E2 = new()
					E2.Grant(caster)
				var/mob/living/simple_animal/hostile/beastmaster/giovanni_zombie/M = new /mob/living/simple_animal/hostile/beastmaster/giovanni_zombie/level5(caster.loc)
				M.my_creator = caster
				caster.beastmaster |= M
				M.beastmaster = caster
				target.gib()
	else
		target.apply_damage(10*level_casting, BRUTE, BODY_ZONE_CHEST)
		target.emote("scream")

/datum/discipline/obtenebration
	name = "Obtenebration"
	desc = "Controls the darkness around you."
	icon_state = "obtenebration"
	cost = 1
	ranged = TRUE
	delay = 100
	violates_masquerade = TRUE
	clane_restricted = TRUE
	activate_sound = 'sound/magic/voidblink.ogg'

/datum/discipline/obtenebration/activate(mob/living/target, mob/living/carbon/human/caster)
	. = ..()
	if(level_casting == 1)
		var/atom/movable/AM = new(target)
		AM.set_light(3, -7)
		spawn(delay+caster.discipline_time_plus)
			AM.set_light(0)
	else
		target.Stun(10*(level_casting-1))
		var/obj/item/ammo_casing/magic/tentacle/lasombra/casing = new (caster.loc)
		casing.fire_casing(target, caster, null, null, null, ran_zone(), 0,  caster)

/datum/discipline/daimonion
	name = "Daimonion"
	desc = "Get a help from the Hell creatures, resist THE FIRE, transform into an imp. Violates Masquerade."
	icon_state = "daimonion"
	cost = 1
	ranged = FALSE
	delay = 150
	violates_masquerade = TRUE
	activate_sound = 'code/modules/ziggers/sounds/protean_activate.ogg'
	clane_restricted = TRUE
	var/obj/effect/proc_holder/spell/targeted/shapeshift/bat/BAT

/datum/discipline/daimonion/activate(mob/living/target, mob/living/carbon/human/caster)
	. = ..()
	var/mod = min(4, level_casting)
//	var/mutable_appearance/protean_overlay = mutable_appearance('code/modules/ziggers/icons.dmi', "protean[mod]", -PROTEAN_LAYER)
	if(!BAT)
		BAT = new(caster)
	switch(mod)
		if(1)
			caster.physiology.burn_mod *= 1/100
			caster.color = "#884200"
			spawn(delay+caster.discipline_time_plus)
				if(caster)
					caster.color = initial(caster.color)
					caster.physiology.burn_mod *= 100
					playsound(caster.loc, 'code/modules/ziggers/sounds/protean_deactivate.ogg', 50, FALSE)
		if(2)
			caster.dna.species.GiveSpeciesFlight(caster)
			spawn(delay+caster.discipline_time_plus)
				if(caster)
					caster.dna.species.RemoveSpeciesFlight(caster)
					playsound(caster.loc, 'code/modules/ziggers/sounds/protean_deactivate.ogg', 50, FALSE)
		if(3)
			caster.drop_all_held_items()
			caster.put_in_r_hand(new /obj/item/melee/vampirearms/knife/gangrel(caster))
			caster.put_in_l_hand(new /obj/item/melee/vampirearms/knife/gangrel(caster))
			spawn(delay+caster.discipline_time_plus)
				if(caster)
					for(var/obj/item/melee/vampirearms/knife/gangrel/G in caster)
						if(G)
							qdel(G)
					playsound(caster.loc, 'code/modules/ziggers/sounds/protean_deactivate.ogg', 50, FALSE)
		if(4 to 5)
			caster.drop_all_held_items()
			BAT.Shapeshift(caster)
			spawn(delay+caster.discipline_time_plus)
				if(caster && caster.stat != DEAD)
					BAT.Restore(BAT.myshape)
					caster.Stun(15)
					caster.do_jitter_animation(30)
					playsound(caster.loc, 'code/modules/ziggers/sounds/protean_deactivate.ogg', 50, FALSE)

/datum/discipline/valeren
	name = "Valeren"
	desc = "Use your third eye in healing or protecting needs."
	icon_state = "valeren"
	cost = 1
	ranged = TRUE
	delay = 50
	violates_masquerade = FALSE
	activate_sound = 'code/modules/ziggers/sounds/valeren.ogg'
	clane_restricted = TRUE
	dead_restricted = FALSE
	var/datum/beam/current_beam

/datum/discipline/valeren/activate(mob/living/target, mob/living/carbon/human/caster)
	. = ..()
	switch(level_casting)
		if(1)
			healthscan(caster, target, 1, FALSE)
			chemscan(caster, target)
//			woundscan(caster, target, src)
			to_chat(caster, "<b>[target]</b> has <b>[target.bloodpool]/[target.maxbloodpool]</b> blood points.")
		if(2)
			if(current_beam)
				qdel(current_beam)
			caster.Beam(target, icon_state="sm_arc", time = 50, maxdistance = 9, beam_type = /obj/effect/ebeam/medical)
			target.Paralyze(30)
			if(target.generation >= caster.generation)
				if(ishuman(target))
					var/mob/living/carbon/human/H = target
					if(!H.handcuffed)
						H.set_handcuffed(new /obj/item/restraints/handcuffs/energy/cult/used(target))
						H.update_handcuffed()
		if(3)
			if(current_beam)
				qdel(current_beam)
			caster.Beam(target, icon_state="sm_arc", time = 50, maxdistance = 9, beam_type = /obj/effect/ebeam/medical)
			target.adjustBruteLoss(-50, TRUE)
			if(ishuman(target))
				var/mob/living/carbon/human/H = target
				if(length(H.all_wounds))
					var/datum/wound/W = pick(H.all_wounds)
					W.remove_wound()
			target.adjustFireLoss(-50, TRUE)
			target.update_damage_overlays()
			target.update_health_hud()
		if(4)
			if(iskindred(target) || isghoul(target))
				if(current_beam)
					qdel(current_beam)
				caster.Beam(target, icon_state="sm_arc", time = 50, maxdistance = 9, beam_type = /obj/effect/ebeam/medical)
				target.bloodpool = 0
				target.update_blood_hud()
		if(5)
			if(current_beam)
				qdel(current_beam)
			caster.Beam(target, icon_state="sm_arc", time = 50, maxdistance = 9, beam_type = /obj/effect/ebeam/medical)
			if(target.revive(full_heal = TRUE, admin_revive = TRUE))
				target.grab_ghost(force = TRUE)

/datum/discipline/melpominee
	name = "Melpominee"
	desc = "Named for the Greek Muse of Tragedy, Melpominee is a unique discipline of the Daughters of Cacophony. It explores the power of the voice, shaking the very soul of those nearby and allowing the vampire to perform sonic feats otherwise impossible."
	icon_state = "melpominee"
	cost = 1
	ranged = TRUE
	delay = 75
	violates_masquerade = FALSE
	activate_sound = 'code/modules/ziggers/sounds/melpominee.ogg'
	clane_restricted = TRUE
	dead_restricted = FALSE

/mob/living/carbon/human/proc/create_walk_to(var/max)
	var/datum/cb = CALLBACK(src,/mob/living/carbon/human/proc/walk_to_my_nigga)
	for(var/i in 1 to max)
		addtimer(cb, (i - 1)*total_multiplicative_slowdown())

/datum/discipline/melpominee/activate(mob/living/target, mob/living/carbon/human/caster)
	. = ..()
	switch(level_casting)
		if(1)
			var/new_say = input(caster, "What will your target hear?") as text|null
			if(new_say)
				new /datum/hallucination/chat(target, TRUE, FALSE, new_say)
				to_chat(caster, "You throw \"[new_say]\" at [target]'s ears.")
		if(2)
			var/new_say = input(caster, "What will your target say?") as text|null
			if(new_say)
				target.say("[new_say]")
		if(3)
			for(var/mob/living/carbon/human/HU in oviewers(7, caster))
				if(HU)
					HU.my_nigga = caster
					HU.create_walk_to(20)
					HU.remove_overlay(MUTATIONS_LAYER)
					var/mutable_appearance/song_overlay = mutable_appearance('code/modules/ziggers/icons.dmi', "song", -MUTATIONS_LAYER)
					HU.overlays_standing[MUTATIONS_LAYER] = song_overlay
					HU.apply_overlay(MUTATIONS_LAYER)
					spawn(20)
						if(HU)
							HU.remove_overlay(MUTATIONS_LAYER)
		if(4)
			playsound(caster.loc, 'code/modules/ziggers/sounds/killscream.ogg', 100, FALSE)
			for(var/mob/living/carbon/human/HU in oviewers(7, caster))
				if(HU)
					HU.Stun(20)
					HU.remove_overlay(MUTATIONS_LAYER)
					var/mutable_appearance/song_overlay = mutable_appearance('code/modules/ziggers/icons.dmi', "song", -MUTATIONS_LAYER)
					HU.overlays_standing[MUTATIONS_LAYER] = song_overlay
					HU.apply_overlay(MUTATIONS_LAYER)
					spawn(20)
						if(HU)
							HU.remove_overlay(MUTATIONS_LAYER)
		if(5)
			playsound(caster.loc, 'code/modules/ziggers/sounds/killscream.ogg', 100, FALSE)
			for(var/mob/living/carbon/human/HU in oviewers(7, caster))
				if(HU)
					HU.Stun(20)
					HU.apply_damage(50, BRUTE, BODY_ZONE_HEAD)
					HU.remove_overlay(MUTATIONS_LAYER)
					var/mutable_appearance/song_overlay = mutable_appearance('code/modules/ziggers/icons.dmi', "song", -MUTATIONS_LAYER)
					HU.overlays_standing[MUTATIONS_LAYER] = song_overlay
					HU.apply_overlay(MUTATIONS_LAYER)
					spawn(20)
						if(HU)
							HU.remove_overlay(MUTATIONS_LAYER)