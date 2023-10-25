SUBSYSTEM_DEF(masquerade)
	name = "Masquerade"
	init_order = INIT_ORDER_DEFAULT
	wait = 1200
	priority = FIRE_PRIORITY_VERYLOW

	var/total_level = 1000
	var/dead_level = 0
	var/last_level = "stable"

/datum/controller/subsystem/masquerade/proc/get_description()
	switch(total_level)
		if(0 to 250)
			return "MASSIVE BREACH"
		if(251 to 500)
			return "MODERATE VIOLATION"
		if(501 to 750)
			return "SUSPICIOUS"
		if(751 to 1000)
			return "STABLE"

/datum/controller/subsystem/masquerade/fire()
	var/masquerade_violators = 0
	var/sabbat = 0
	if(length(GLOB.masquerade_breakers_list))
		masquerade_violators = (2000/length(GLOB.player_list))*length(GLOB.masquerade_breakers_list)
	if(length(GLOB.sabbatites))
		sabbat = (2000/length(GLOB.player_list))*length(GLOB.sabbatites)

	total_level = max(0, 1000+dead_level-masquerade_violators-sabbat)

	var/shit_happens = "stable"
	switch(total_level)
		if(0 to 250)
			shit_happens = "breach"
		if(251 to 500)
			shit_happens = "moderate"
		if(501 to 750)
			shit_happens = "slightly"
		if(751 to 1000)
			shit_happens = "stable"

	if(last_level != shit_happens)
		last_level = shit_happens
		for(var/mob/living/carbon/human/H in GLOB.player_list)
			if(H)
				if(iskindred(H) || isghoul(H))
					switch(last_level)
						if("stable")
							to_chat(H, "Night becomes clear, nothing can threat the Masquerade...")
						if("slightly")
							to_chat(H, "Something is going wrong here...")
						if("moderate")
							to_chat(H, "People start noticing...")
						if("breach")
							to_chat(H, "Masquerade is about to fall...")

	if(total_level <= 250)
		for(var/mob/living/carbon/human/H in GLOB.player_list)
			if(H)
				if(iskindred(H))
					if(!H.warrant)
						H.last_nonraid = world.time
						H.warrant = TRUE
						SEND_SOUND(H, sound('code/modules/ziggers/sounds/humanity_loss.ogg', 0, 0, 75))
						to_chat(H, "<span class='userdanger'><b>POLICE ASSAULT IN PROGRESS</b></span>")
//Spotted body -25
//Blood -5 for each
//Masquerade violation -50
//Masquerade reinforcement +25
//Final death +50