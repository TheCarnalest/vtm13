/mob/living/carbon/human/proc/AdjustHumanity(var/value, var/limit)
	var/special_role_name
	if(mind)
		if(mind.special_role)
			var/datum/antagonist/A = mind.special_role
			special_role_name = A.name
	if(!is_special_character(src) || special_role_name == "Ambitious")
		if(!in_frenzy)
			var/mod = 1
			var/enlight = FALSE
			if(clane)
				mod = clane.humanitymod
				enlight = clane.enlightement
			if(enlight)
				if(value < 0)
					if(humanity < 10)
						humanity = max(limit, humanity-(value*mod))
						SEND_SOUND(src, sound('code/modules/ziggers/sounds/humanity_gain.ogg', 0, 0, 75))
						to_chat(src, "<span class='us-erhelp'><b>ENLIGHTEMENT INCREASES</b></span>")
				if(value > 0)
					if(humanity > 0)
						humanity = min(limit, humanity-(value*mod))
						SEND_SOUND(src, sound('code/modules/ziggers/sounds/humanity_loss.ogg', 0, 0, 75))
						to_chat(src, "<span class='userdanger'><b>ENLIGHTEMENT DECREASES</b></span>")
			else
				if(value < 0)
					if(humanity > limit)
						humanity = max(limit, humanity+(value*mod))
						SEND_SOUND(src, sound('code/modules/ziggers/sounds/humanity_loss.ogg', 0, 0, 75))
						to_chat(src, "<span class='userdanger'><b>HUMANITY DECREASES</b></span>")
				if(value > 0)
					if(humanity < limit)
						humanity = min(limit, humanity+(value*mod))
						SEND_SOUND(src, sound('code/modules/ziggers/sounds/humanity_gain.ogg', 0, 0, 75))
						to_chat(src, "<span class='us-erhelp'><b>HUMANITY INCREASES</b></span>")

/mob/living/carbon/human/proc/AdjustMasquerade(var/value)
	var/special_role_name
	if(mind)
		if(mind.special_role)
			var/datum/antagonist/A = mind.special_role
			special_role_name = A.name
	if(!is_special_character(src) || special_role_name == "Ambitious")
		if(last_masquerade_violation+100 < world.time)
			last_masquerade_violation = world.time
			if(value < 0)
				if(masquerade > 0)
					masquerade = max(0, masquerade+value)
					SEND_SOUND(src, sound('code/modules/ziggers/sounds/masquerade_violation.ogg', 0, 0, 75))
					to_chat(src, "<span class='userdanger'><b>MASQUERADE VIOLATION</b></span>")
				SSbad_guys_party.next_fire = max(world.time, SSbad_guys_party.next_fire-1200)
			if(value > 0)
				for(var/mob/living/carbon/human/H in GLOB.player_list)
					H.voted_for -= dna.real_name
				if(masquerade < 5)
					masquerade = min(5, masquerade+value)
					SEND_SOUND(src, sound('code/modules/ziggers/sounds/general_good.ogg', 0, 0, 75))
					to_chat(src, "<span class='userhelp'><b>MASQUERADE REINFORCEMENT</b></span>")
				SSbad_guys_party.next_fire = max(world.time, SSbad_guys_party.next_fire+600)

	if(src in GLOB.masquerade_breakers_list)
		if(masquerade > 1)
			GLOB.masquerade_breakers_list -= src
	else if(masquerade < 2)
		GLOB.masquerade_breakers_list |= src

/mob/living/carbon/human/npc/proc/backinvisible(var/atom/A)
	switch(dir)
		if(NORTH)
			if(A.y >= y)
				return TRUE
		if(SOUTH)
			if(A.y <= y)
				return TRUE
		if(EAST)
			if(A.x >= x)
				return TRUE
		if(WEST)
			if(A.x <= x)
				return TRUE
	return FALSE

/mob/living/proc/CheckEyewitness(var/mob/living/source, var/mob/attacker, var/range = 0, var/affects_source = FALSE)
	var/actual_range = max(1, round(range*(attacker.alpha/255)))
	if(SScityweather.fogging)
		actual_range = round(actual_range/2)
	var/list/seenby = list()
	for(var/mob/living/carbon/human/npc/NPC in viewers(2, source))
		if(!NPC.CheckMove())
			seenby |= NPC
			NPC.Aggro(attacker, FALSE)
	for(var/mob/living/carbon/human/npc/NPC in viewers(actual_range, source))
		if(!NPC.CheckMove())
			if(affects_source)
				if(NPC == source)
					NPC.Aggro(attacker, TRUE)
					seenby |= NPC
			if(!NPC.pulledby)
				var/turf/LC = get_turf(attacker)
				if(LC.get_lumcount() > 0.25 || get_dist(NPC, attacker) <= 1)
					if(NPC.backinvisible(attacker))
						seenby |= NPC
						NPC.Aggro(attacker, FALSE)
	if(length(seenby) >= 1)
		return TRUE
	return FALSE

/proc/vampireroll(var/dices_num = 1, var/hardness = 1, var/atom/rollviewer)
	var/wins = 0
	var/crits = 0
	var/brokes = 0
	for(var/i in 1 to dices_num)
		var/roll = rand(1, 10)
		if(roll == 10)
			crits += 1
		if(roll == 1)
			brokes += 1
		else if(roll >= hardness)
			wins += 1
	if(crits > brokes)
		if(rollviewer)
			to_chat(rollviewer, "<b>Critical <span class='nicegreen'>hit</span>!</b>")
			return DICE_CRIT_WIN
	if(crits < brokes)
		if(rollviewer)
			to_chat(rollviewer, "<b>Critical <span class='danger'>failure</span>!</b>")
			return DICE_CRIT_FAILURE
	if(crits == brokes && !wins)
		if(rollviewer)
			to_chat(rollviewer, "<span class='danger'>Failed</span>")
			return DICE_FAILURE
	if(wins)
		switch(wins)
			if(1)
				to_chat(rollviewer, "<span class='tinynotice'>Maybe</span>")
				return DICE_WIN
			if(2)
				to_chat(rollviewer, "<span class='smallnotice'>Okay</span>")
				return DICE_WIN
			if(3)
				to_chat(rollviewer, "<span class='notice'>Good</span>")
				return DICE_WIN
			if(4)
				to_chat(rollviewer, "<span class='notice'>Lucky</span>")
				return DICE_WIN
			else
				to_chat(rollviewer, "<span class='boldnotice'>Phenomenal</span>")
				return DICE_WIN

/proc/get_vamp_skin_color(var/value = "albino")
	switch(value)
		if("caucasian1")
			return "vamp1"
		if("caucasian2")
			return "vamp2"
		if("caucasian3")
			return "vamp3"
		if("latino")
			return "vamp4"
		if("mediterranean")
			return "vamp5"
		if("asian1")
			return "vamp6"
		if("asian2")
			return "vamp7"
		if("arab")
			return "vamp8"
		if("indian")
			return "vamp9"
		if("african1")
			return "vamp10"
		if("african2")
			return "vamp11"
		else
			return value
