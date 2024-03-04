/datum/action/gift/stoic_pose
	name = "Stoic Pose"
	desc = "With this gift garou sends theirself into cryo-state, ignoring all incoming damage but also covering themself in a block of ice."
	button_icon_state = "stoic_pose"
//	rage_req = 1

/datum/action/gift/stoic_pose/Trigger()
	. = ..()
	if(allowed_to_proceed)
		playsound(get_turf(owner), 'code/modules/ziggers/sounds/ice_blocking.ogg', 100, FALSE)
		var/mob/living/carbon/C = owner
		if(isgarou(C))
			var/obj/were_ice/W = new (get_turf(owner))
			C.Stun(200)
			C.forceMove(W)
			spawn(200)
				C.forceMove(get_turf(W))
				qdel(W)
		if(iscrinos(C))
			var/obj/were_ice/crinos/W = new (get_turf(owner))
			C.Stun(200)
			C.forceMove(W)
			spawn(200)
				C.forceMove(get_turf(W))
				qdel(W)
		if(islupus(C))
			var/obj/were_ice/lupus/W = new (get_turf(owner))
			C.Stun(200)
			C.forceMove(W)
			spawn(200)
				C.forceMove(get_turf(W))
				qdel(W)

/datum/action/gift/freezing_wind
	name = "Freezing Wind"
	desc = "Garou of Wendigo Tribe can create a stream of cold, freezing wind, and strike her foes with it."
	button_icon_state = "freezing_wind"
	gnosis_req = 1

/datum/action/gift/freezing_wind/Trigger()
	. = ..()
	if(allowed_to_proceed)
		playsound(get_turf(owner), 'code/modules/ziggers/sounds/wind_cast.ogg', 100, FALSE)
		for(var/turf/T in range(3, get_step(get_step(owner, owner.dir), owner.dir)))
			if(owner.loc != T)
				var/obj/effect/wind/W = new(T)
				W.dir = owner.dir
				W.strength = 100
				spawn(200)
					qdel(W)
//	if(allowed_to_proceed)

/datum/action/gift/bloody_feast
	name = "Bloody Feast"
	desc = "By eating a grabbed corpse, garou can redeem their lost health and heal the injuries."
	button_icon_state = "bloody_feast"
	rage_req = 1

/datum/action/gift/bloody_feast/Trigger()
	. = ..()
	if(allowed_to_proceed)
		var/mob/living/carbon/C = owner
		if(C.pulling)
			if(isliving(C.pulling))
				var/mob/living/L = C.pulling
				if(L.stat == DEAD)
					playsound(get_turf(owner), 'code/modules/ziggers/sounds/bloody_feast.ogg', 50, FALSE)
					qdel(L)
					C.revive(full_heal = TRUE, admin_revive = TRUE)

/datum/action/gift/stinky_fur
	name = "Stinky Fur"
	desc = "Garou creates an aura of very toxic smell, which disorientates everyone around."
	button_icon_state = "stinky_fur"

/datum/action/gift/stinky_fur/Trigger()
	. = ..()
	if(allowed_to_proceed)
		playsound(get_turf(owner), 'code/modules/ziggers/sounds/necromancy.ogg', 75, FALSE)
		for(var/mob/living/carbon/C in orange(5, src))
			if(C)
				if(prob(25))
					C.vomit()
				C.dizziness += 10
				C.add_confusion(10)

/mob/living/carbon
	var/tox_damage_plus = 0

/datum/action/gift/venom_claws
	name = "Venom Claws"
	desc = "While this ability is active, strikes with claws poison foes of garou."
	button_icon_state = "venom_claws"

/datum/action/gift/venom_claws/Trigger()
	. = ..()
	if(allowed_to_proceed)
		if(ishuman(owner))
			playsound(get_turf(owner), 'code/modules/ziggers/sounds/venom_claws.ogg', 75, FALSE)
			var/mob/living/carbon/human/H = owner
			H.tox_damage_plus = 25
			to_chat(owner, "<span class='notice'>You feel your claws filling with pure venom...</span>")
			spawn(150)
				H.tox_damage_plus = 0
				to_chat(owner, "<span class='warning'>Your claws are not poison anymore...</span>")
		else
			playsound(get_turf(owner), 'code/modules/ziggers/sounds/venom_claws.ogg', 75, FALSE)
			var/mob/living/carbon/H = owner
			H.melee_damage_lower = initial(H.melee_damage_lower)+20
			H.melee_damage_upper = initial(H.melee_damage_upper)+20
			H.tox_damage_plus = 25
			to_chat(owner, "<span class='notice'>You feel your claws filling with pure venom...</span>")
			spawn(150)
				H.tox_damage_plus = 0
				H.melee_damage_lower = initial(H.melee_damage_lower)
				H.melee_damage_upper = initial(H.melee_damage_upper)
				to_chat(owner, "<span class='warning'>Your claws are not poison anymore...</span>")

/datum/action/gift/burning_scars
	name = "Burning Scars"
	desc = "Garou creates an aura of very hot air, which burns everyone around."
	button_icon_state = "burning_scars"

/datum/action/gift/burning_scars/Trigger()
	. = ..()
	if(allowed_to_proceed)
		for(var/mob/living/L in orange(5, owner))
			if(L)
				L.adjustFireLoss(40)
		for(var/turf/T in orange(4, get_turf(owner)))
			var/obj/effect/fire/F = new(T)
			spawn(5)
				qdel(F)

/datum/action/gift/smooth_move
	name = "Smooth Move"
	desc = "Garou jumps forward, avoiding every damage for a moment."
	button_icon_state = "smooth_move"

/datum/action/gift/smooth_move/Trigger()
	. = ..()
	if(allowed_to_proceed)
		var/turf/T = get_turf(get_step(get_step(get_step(owner, owner.dir), owner.dir), owner.dir))
		if(!T || T == owner.loc)
			return
		owner.visible_message("<span class='danger'>[owner] charges!</span>")
		owner.setDir(get_dir(owner, T))
		var/obj/effect/temp_visual/decoy/D = new /obj/effect/temp_visual/decoy(owner.loc,owner)
		animate(D, alpha = 0, color = "#FF0000", transform = matrix()*2, time = 1)
		spawn(3)
			owner.throw_at(T, get_dist(owner, T), 1, owner, 0)

/datum/action/gift/digital_feelings
	name = "Digital Feelings"
	desc = "Every technology creates an electrical strike, which hits garou's enemies."
	button_icon_state = "digital_feelings"

/datum/action/gift/digital_feelings/Trigger()
	. = ..()
	if(allowed_to_proceed)
		playsound(src, 'sound/magic/lightningshock.ogg', 100, TRUE, extrarange = 5)
		tesla_zap(owner, 3, 30, ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE | ZAP_MOB_STUN | ZAP_ALLOW_DUPLICATES)
		for(var/mob/living/L in orange(6, owner))
			if(L)
				L.electrocute_act(30, owner, siemens_coeff = 1, flags = NONE)

/datum/action/gift/elemental_improvement
	name = "Elemental Improvement"
	desc = "Garou flesh replaces itself with prothesis, making it less vulnerable to brute damage, but more for burn damage."
	button_icon_state = "elemental_improvement"