/mob/living/carbon/human/npc/proc/Aggro(var/mob/M, var/attacked = FALSE)
	if(attacked && danger_source != M)
		walk(src,0)
	if(M == src)
		return
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.frakcja == frakcja && !H.client)
			return
	if(stat != DEAD)
		danger_source = M
		if(attacked)
			last_attacker = M
			if(health != last_health)
				last_health = health
				last_damager = M
	if(CheckMove())
		return
	if(last_danger_meet+50 < world.time)
		last_danger_meet = world.time
		if(prob(50))
			if(!my_weapon)
				if(prob(50))
					emote("scream")
				else
					RealisticSay(pick(socialrole.help_phrases))
			else
				RealisticSay(pick(socialrole.help_phrases))