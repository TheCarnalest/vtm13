/mob/living/carbon/human/proc/add_bite_animation()
	remove_overlay(BITE_LAYER)
	var/mutable_appearance/bite_overlay = mutable_appearance('code/modules/ziggers/icons.dmi', "bite", -BITE_LAYER)
	overlays_standing[BITE_LAYER] = bite_overlay
	apply_overlay(BITE_LAYER)
	spawn(15)
		if(src)
			remove_overlay(BITE_LAYER)

/mob/living/carbon/human
	var/image/suckbar
	var/atom/suckbar_loc

/proc/get_needed_difference_between_numbers(var/number1, var/number2)
	if(number1 > number2)
		return number1 - number2
	else if(number1 < number2)
		return number2 - number1
	else
		return 1

/mob/living/carbon/human/proc/drinksomeblood(var/mob/living/mob)
	last_drinkblood_use = world.time
	if(client)
		client.images -= suckbar
	qdel(suckbar)
	suckbar_loc = mob
	suckbar = image('code/modules/ziggers/bloodcounter.dmi', suckbar_loc, "[round(14*(mob.bloodpool/mob.maxbloodpool))]", HUD_LAYER)
	suckbar.pixel_z = 40
	suckbar.plane = ABOVE_HUD_PLANE
	suckbar.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	if(client)
		client.images += suckbar
	var/sound/heartbeat = sound('code/modules/ziggers/sounds/drinkblood2.ogg', repeat = TRUE)
	if(HAS_TRAIT(src, TRAIT_BLOODY_SUCKER))
		src.emote("moan")
		Immobilize(30, TRUE)
	playsound_local(src, heartbeat, 75, 0, channel = CHANNEL_BLOOD, use_reverb = FALSE)
	if(isnpc(mob))
		var/mob/living/carbon/human/npc/NPC = mob
		NPC.danger_source = null
		NPC.last_attacker = src

	if(iskindred(mob))
		to_chat(src, "<span class='userlove'>You notice a pleasant feeling while siping [mob]'s BLOOD...</span>")
		adjustBruteLoss(-25, TRUE)
		adjustFireLoss(-25, TRUE)
	else
		mob.Stun(30)
		to_chat(src, "<span class='warning'>You sip some <b>BLOOD</b> from your victim. It feels good.</span>")

	if(mob.bloodpool <= 1 && mob.maxbloodpool > 1)
//		if(alert("This action will kill your victim. Are you sure?",,"Yes","No")!="Yes")
//			return
		to_chat(src, "<span class='warning'>You feel small amount of <b>BLOOD</b> in your victim.</span>")
		if(iskindred(mob))
			if(!mob.client)
				to_chat(src, "<span class='warning'>You need [mob]'s attention to do that...</span>")
				return
			message_admins("[src]([key]) is trying to diablerie [mob]([mob.key])!")
			if(mob.key)
				var/vse_taki = FALSE
				var/special_role_name
				if(mind)
					if(mind.special_role)
						var/datum/antagonist/A = mind.special_role
						special_role_name = A.name
				if(clane)
					var/salubri_allowed = FALSE
					var/mob/living/carbon/human/H = mob
					if(H.clane)
						if(H.clane.name == "Salubri")
							salubri_allowed = TRUE
					if(clane.name != "Banu Haqim" && clane.name != "Caitiff")
						if(!salubri_allowed)
							if(!mind.special_role || special_role_name == "Ambitious")
								to_chat(src, "<span class='warning'>You find the idea of drinking your own <b>KIND</b> disgusting!</span>")
								last_drinkblood_use = 0
								if(client)
									client.images -= suckbar
								qdel(suckbar)
								stop_sound_channel(CHANNEL_BLOOD)
								return
							else
								vse_taki = TRUE
						else
							vse_taki = TRUE
					else
						vse_taki = TRUE

				if(!GLOB.canon_event)
					to_chat(src, "<span class='warning'>It's not a canon event!</span>")
					return

				if(vse_taki)
					to_chat(src, "<span class='userdanger'><b>YOU TRY TO COMMIT DIABLERIE OVER [mob].</b></span>")
				else
					to_chat(src, "<span class='warning'>You find the idea of drinking your own <b>KIND</b> disgusting!</span>")
					return
			else
				to_chat(src, "<span class='warning'>You need [mob]'s attention to do that...</span>")
				return

	if(!HAS_TRAIT(src, TRAIT_BLOODY_LOVER))
		if(CheckEyewitness(src, src, 7, FALSE))
			AdjustMasquerade(-1)
	if(do_after(src, 30, target = mob, timed_action_flags = NONE, progress = FALSE))
		mob.bloodpool = max(0, mob.bloodpool-1)
		suckbar.icon_state = "[round(14*(mob.bloodpool/mob.maxbloodpool))]"
		if(ishuman(mob))
			var/mob/living/carbon/human/H = mob
			drunked_of |= "[H.dna.real_name]"
			if(!iskindred(mob))
				H.blood_volume = max(H.blood_volume-50, 150)
			if(H.reagents)
				if(length(H.reagents.reagent_list))
					if(prob(50))
						H.reagents.trans_to(src, min(10, H.reagents.total_volume), transfered_by = mob, methods = VAMPIRE)
		if(clane)
			if(clane.name == "Giovanni")
				mob.adjustBruteLoss(20, TRUE)
			if(clane.name == "Ventrue" && mob.bloodquality < BLOOD_QUALITY_NORMAL)	//Ventrue mozhet sosat norm, no ne bomzhei i zhivotnih. BLOOD_QUALITY_LOW - 1, BLOOD_QUALITY_NORMAL - 2, BLOOD_QUALITY_HIGH - 3. Golubaya krov daet +1 k otsosu
				to_chat(src, "<span class='warning'>You are too privileged to drink that awful <b>BLOOD</b>. Go get something better.</span>")
				visible_message("<span class='danger'>[src] throws up!</span>", "<span class='userdanger'>You throw up!</span>")
				playsound(get_turf(src), 'sound/effects/splat.ogg', 50, TRUE)
				if(isturf(loc))
					add_splatter_floor(loc)
				stop_sound_channel(CHANNEL_BLOOD)
				if(client)
					client.images -= suckbar
				qdel(suckbar)
				return
		bloodpool = min(maxbloodpool, bloodpool+1*max(1, mob.bloodquality-1))
		adjustBruteLoss(-10, TRUE)
		adjustFireLoss(-10, TRUE)
		update_damage_overlays()
		update_health_hud()
		update_blood_hud()
		if(mob.bloodpool <= 0)
			if(ishuman(mob))
				var/mob/living/carbon/human/K = mob
				if(iskindred(mob))
					var/datum/preferences/P = GLOB.preferences_datums[ckey(key)]
					var/datum/preferences/P2 = GLOB.preferences_datums[ckey(mob.key)]
					message_admins("[src]([key]) tries to diablerie [mob](mob.key])!")
					AdjustHumanity(-1, 0)
					AdjustMasquerade(-1)
					if(K.generation >= generation)
						message_admins("[src]([key]) successes in diablerie over [mob](mob.key])!")
						mob.death()
						if(K.client)
							reset_shit(K)
							K.ghostize(FALSE)
						if(P2)
							P2.reason_of_death =  "Diablerized by [true_real_name ? true_real_name : real_name] ([time2text(world.timeofday, "YYYY-MM-DD hh:mm:ss")])."
						adjustBruteLoss(-50, TRUE)
						adjustFireLoss(-50, TRUE)
						if(key)
							if(P)
								P.diablerist = 1
							diablerist = 1
					else
						if(prob(20+((generation-K.generation)*10)))
							to_chat(src, "<span class='userdanger'><b>[K]'s SOUL OVERCOMES YOURS AND GAIN CONTROL OF YOUR BODY.</b></span>")
							message_admins("[src]([key]) failed to diablerie [mob](mob.key])!")
							death()
							reset_shit(src)
							if(P)
								P.reason_of_death = "Failed the Diablerie ([time2text(world.timeofday, "YYYY-MM-DD hh:mm:ss")])."
//							ghostize(FALSE)
//							key = K.key
//							generation = K.generation
//							maxHealth = initial(maxHealth)+100*(13-generation)
//							health = initial(health)+100*(13-generation)
//							mob.death()
						else
							message_admins("[src]([key]) successes in diablerie over [mob](mob.key])!")
							if(P)
								P.diablerist = 1
								P.generation = K.generation
								generation = P.generation
							diablerist = 1
							maxHealth = initial(maxHealth)+max(0, 50*(13-generation))
							health = initial(health)+max(0, 50*(13-generation))
							mob.death()
							if(K.client)
								reset_shit(K)
								K.ghostize(FALSE)
							if(P2)
								P2.reason_of_death = "Diablerized by [true_real_name ? true_real_name : real_name] ([time2text(world.timeofday, "YYYY-MM-DD hh:mm:ss")])."
					if(client)
						client.images -= suckbar
					qdel(suckbar)
					return
				else
					K.blood_volume = 0
			if(ishuman(mob) && !iskindred(mob))
				if(mob.stat != DEAD)
					if(isnpc(mob))
						var/mob/living/carbon/human/npc/Npc = mob
						Npc.last_attacker = null
						killed_count = killed_count+1
						if(killed_count >= 5)
//							GLOB.fuckers |= src
							SEND_SOUND(src, sound('code/modules/ziggers/sounds/humanity_loss.ogg', 0, 0, 75))
							to_chat(src, "<span class='userdanger'><b>POLICE ASSAULT IN PROGRESS</b></span>")
					SEND_SOUND(src, sound('code/modules/ziggers/sounds/feed_failed.ogg', 0, 0, 75))
					to_chat(src, "<span class='warning'>This sad sacrifice for your own pleasure affects something deep in your mind.</span>")
					AdjustHumanity(-1, 0)
					mob.death()
			if(!ishuman(mob))
				if(mob.stat != DEAD)
					mob.death()
			stop_sound_channel(CHANNEL_BLOOD)
			last_drinkblood_use = 0
			if(client)
				client.images -= suckbar
			qdel(suckbar)
			return
		if(grab_state >= GRAB_PASSIVE)
			stop_sound_channel(CHANNEL_BLOOD)
			drinksomeblood(mob)
	else
		last_drinkblood_use = 0
		if(client)
			client.images -= suckbar
		qdel(suckbar)
		stop_sound_channel(CHANNEL_BLOOD)
		if(!iskindred(mob))
			mob.SetSleeping(50)
