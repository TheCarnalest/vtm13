/datum/species/kindred
	name = "Vampire"
	id = "kindred"
	default_color = "FFFFFF"
	toxic_food = MEAT | VEGETABLES | RAW | JUNKFOOD | GRAIN | FRUIT | DAIRY | FRIED | ALCOHOL | SUGAR | PINEAPPLE
	species_traits = list(EYECOLOR, HAIR, FACEHAIR, LIPS, HAS_FLESH, HAS_BONE)
	inherent_traits = list(TRAIT_ADVANCEDTOOLUSER, TRAIT_VIRUSIMMUNE, TRAIT_NOHUNGER, TRAIT_NOBREATH, TRAIT_TOXIMMUNE, TRAIT_NOCRITDAMAGE, TRAIT_LIMBATTACHMENT)
	use_skintones = TRUE
	limbs_id = "human"
	wings_icon = "Dragon"
	mutant_bodyparts = list("tail_human" = "None", "ears" = "None", "wings" = "None")
	brutemod = 0.5	//0.8 bilo
	heatmod = 2		//Sosut ot peregreva
	burnmod = 2
	punchdamagelow = 10
	punchdamagehigh = 20
	dust_anim = "dust-h"
	var/datum/vampireclane/clane

/mob/living
	var/list/knowscontacts = list()

/datum/action/vampireinfo
	name = "About Me"
	desc = "Check assigned role, clane, generation, humanity, masquerade, known disciplines, known contacts etc."
	button_icon_state = "masquerade"
	check_flags = NONE
	var/mob/living/carbon/human/host

/datum/action/vampireinfo/Trigger()
	if(host)
		var/dat = {"
			<style type="text/css">

			body {
				background-color: #090909; color: white;
			}

			</style>
			"}
		dat += "<center><h2>Memories</h2><BR></center>"
		dat += "[icon2html(getFlatIcon(host), host)]I am "
		if(host.real_name)
			dat += "[host.real_name],"
		if(!host.real_name)
			dat += "Unknown,"
		if(host.clane)
			dat += " the [host.clane.name]"
		if(!host.clane)
			dat += " the caitiff"

		if(host.mind)

			if(host.mind.assigned_role)
				if(host.mind.special_role)
					dat += ", carrying the [host.mind.assigned_role] (<font color=red>[host.mind.special_role]<font>) role."
				else
					dat += ", carrying the [host.mind.assigned_role] role."
			if(!host.mind.assigned_role)
				dat += "."
			dat += "<BR>"
			if(host.mind.enslaved_to)
				dat += "My Regnant is [host.mind.enslaved_to], I should obey their wants.<BR>"
		if(host.generation)
			dat += "I'm from [host.generation] generation.<BR>"
		if(host.mind.special_role)
			for(var/datum/antagonist/A in host.mind.antag_datums)
				if(A.objectives)
					dat += "[printobjectives(A.objectives)]<BR>"
		else
			var/masquerade_level = " followed the Masquerade Tradition perfectly."
			switch(host.masquerade)
				if(4)
					masquerade_level = " broke the Masquerade rule once."
				if(3)
					masquerade_level = " made a couple of Masquerade breaches."
				if(2)
					masquerade_level = " provoked a moderate Masquerade breach."
				if(1)
					masquerade_level = " almost ruined the Masquerade."
				if(0)
					masquerade_level = "'m danger to the Masquerade and my own kind."
			dat += "Camarilla thinks I[masquerade_level]<BR>"
			var/humanity = "I'm out of my mind."
			var/enlight = FALSE
			if(host.clane)
				if(host.clane.enlightement)
					enlight = TRUE

			if(!enlight)
				switch(host.humanity)
					if(8 to 10)
						humanity = "I'm the best example of mercy and kindness."
					if(7)
						humanity = "I have nothing to complain about my humanity."
					if(5 to 6)
						humanity = "I'm slightly above the humane."
					if(4)
						humanity = "I don't care about kine."
					if(2 to 3)
						humanity = "There's nothing bad in murdering for <b>BLOOD</b>."
					if(1)
						humanity = "I'm slowly falling into madness..."

			else
				switch(host.humanity)
					if(8 to 10)
						humanity = "I'm <b>ENLIGHTED</b> and in the true harmony with my <b>BEAST</b>."
					if(7)
						humanity = "I'm slightly <b>ENLIGHTED</b>."
					if(5 to 6)
						humanity = "I'm about to be <b>ENLIGHTED</b>."
					if(4)
						humanity = "I'm purely trying to be <b>ENLIGHTED</b>."
					if(2 to 3)
						humanity = "My <b>BEAST</b> is calling me to be <b>ENLIGHTED</b>."
					if(1)
						humanity = "Am I <b>ENLIGHTED</b> or <b>HUMANE</b>?"

			dat += "[humanity]<BR>"
		if(host.hud_used.discipline1_icon.dscpln)
			dat += "<b>Known disciplines:</b><BR>"
			if(host.hud_used.discipline1_icon.dscpln)
				dat += "[host.hud_used.discipline1_icon.dscpln.name] [host.hud_used.discipline1_icon.dscpln.level] - [host.hud_used.discipline1_icon.dscpln.desc]<BR>"
			if(host.hud_used.discipline2_icon.dscpln)
				dat += "[host.hud_used.discipline2_icon.dscpln.name] [host.hud_used.discipline2_icon.dscpln.level] - [host.hud_used.discipline2_icon.dscpln.desc]<BR>"
			if(host.hud_used.discipline3_icon.dscpln)
				dat += "[host.hud_used.discipline3_icon.dscpln.name] [host.hud_used.discipline3_icon.dscpln.level] - [host.hud_used.discipline3_icon.dscpln.desc]<BR>"
		if(host.friend_name)
			dat += "<b>Friend: [host.friend_name]</b><BR>"
		if(host.enemy_name)
			dat += "<b>Enemy: [host.enemy_name]</b><BR>"
		if(host.lover_name)
			dat += "<b>Lover: [host.lover_name]</b><BR>"
		if(length(host.knowscontacts) > 0)
			dat += "<b>I know some other of my kind in this city. Need to check my phone, there definetely should be:</b><BR>"
			for(var/i in host.knowscontacts)
				dat += "-[i] contact<BR>"
		host << browse(dat, "window=vampire;size=400x450;border=1;can_resize=1;can_minimize=0")
		onclose(host, "vampire", src)

/datum/species/kindred/on_species_gain(mob/living/carbon/human/C)
	. = ..()
//	ADD_TRAIT(C, TRAIT_NOBLEED, HIGHLANDER)
	C.update_body(0)
	C.last_experience = world.time+3000
	var/datum/action/vampireinfo/infor = new()
	infor.host = C
	infor.Grant(C)
	var/datum/action/give_vitae/vitae = new()
	vitae.Grant(C)

/datum/species/kindred/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	for(var/datum/action/vampireinfo/VI in C.actions)
		qdel(VI)
	for(var/datum/action/give_vitae/GI in C.actions)
		qdel(GI)

/datum/action/give_vitae
	name = "Give Vitae"
	desc = "Give your vitae to someone, make the Blood Bond."
	button_icon_state = "vitae"
	check_flags = AB_CHECK_HANDS_BLOCKED|AB_CHECK_IMMOBILE|AB_CHECK_LYING|AB_CHECK_CONSCIOUS
	var/giving = FALSE

/datum/action/give_vitae/Trigger()
	if(istype(owner, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = owner
		if(H.bloodpool < 2)
			to_chat(owner, "<span class='warning'>You don't have enough <b>BLOOD</b> to do that!</span>")
			return
		if(istype(H.pulling, /mob/living/carbon/human))
			var/mob/living/carbon/human/BLOODBONDED = H.pulling
			if(!BLOODBONDED.client && !istype(H.pulling, /mob/living/carbon/human/npc))
				to_chat(owner, "<span class='warning'>You need [BLOODBONDED]'s attention to do that!</span>")
				return
			if(giving)
				return
			giving = TRUE
			to_chat(owner, "<span class='notice'>You started to feed [BLOODBONDED] with your own blood.</span>")
			if(do_mob(owner, BLOODBONDED, 10 SECONDS))
				var/new_master = FALSE
				BLOODBONDED.faction |= H.faction
				BLOODBONDED.drunked_of |= "[H.dna.real_name]"
				if(BLOODBONDED.stat == DEAD && !iskindred(BLOODBONDED))
					if(BLOODBONDED.respawntimeofdeath+6000 > world.time)
						if(BLOODBONDED.revive(full_heal = TRUE, admin_revive = TRUE))
							BLOODBONDED.grab_ghost(force = TRUE)
							to_chat(BLOODBONDED, "<span class='userdanger'>You rise with a start, you're alive! Or not... You feel your soul going somewhere, as you realize you are embraced by a vampire...</span>")
						BLOODBONDED.set_species(/datum/species/kindred)
						BLOODBONDED.generation = H.generation+1
						if(H.generation < 13)
							BLOODBONDED.skin_tone = get_vamp_skin_color(BLOODBONDED.skin_tone)
							BLOODBONDED.update_body()
							BLOODBONDED.clane = new H.clane.type()
							BLOODBONDED.clane.on_gain(BLOODBONDED)
							if(BLOODBONDED.clane.alt_sprite)
								BLOODBONDED.skin_tone = "albino"
								BLOODBONDED.update_body()
							BLOODBONDED.create_disciplines(FALSE, BLOODBONDED.clane.clane_disciplines[1], BLOODBONDED.clane.clane_disciplines[2], BLOODBONDED.clane.clane_disciplines[3])
							BLOODBONDED.maxbloodpool = 10+((13-BLOODBONDED.generation)*5)
							BLOODBONDED.clane.enlightement = H.clane.enlightement
							if(BLOODBONDED.generation < 13)
								BLOODBONDED.maxHealth = initial(BLOODBONDED.maxHealth)+50*(13-BLOODBONDED.generation)
								BLOODBONDED.health = initial(BLOODBONDED.health)+50*(13-BLOODBONDED.generation)
						else
							BLOODBONDED.clane = new /datum/vampireclane/caitiff()
					else
						to_chat(owner, "<span class='notice'>[BLOODBONDED] is totally <b>DEAD</b>!</span>")
						giving = FALSE
						return
				H.bloodpool = max(0, H.bloodpool-2)
				to_chat(owner, "<span class='notice'>You successfuly fed [BLOODBONDED] with vitae.</span>")
				BLOODBONDED.adjustBruteLoss(-25, TRUE)
				if(length(BLOODBONDED.all_wounds))
					var/datum/wound/W = pick(BLOODBONDED.all_wounds)
					W.remove_wound()
				BLOODBONDED.adjustFireLoss(-25, TRUE)
				BLOODBONDED.bloodpool = min(BLOODBONDED.maxbloodpool, BLOODBONDED.bloodpool+2)
				giving = FALSE
				if(istype(H.pulling, /mob/living/carbon/human/npc))
					var/mob/living/carbon/human/npc/NPC = H.pulling
					if(NPC.ghoulificate(owner))
						new_master = TRUE
				if(BLOODBONDED.mind)
					if(BLOODBONDED.mind.enslaved_to != owner)
						BLOODBONDED.mind.enslave_mind_to_creator(owner)
						to_chat(BLOODBONDED, "<span class='userdanger'><b>AS PRECIOUS VITAE ENTER YOUR MOUTH, YOU NOW ARE IN THE BLOODBOND OF [H]. SERVE YOUR REGNANT CORRECTLY, OR YOUR ACTIONS WILL NOT BE TOLERATED.</b></span>")
						new_master = TRUE
				if(isghoul(BLOODBONDED))
					var/datum/species/ghoul/G = BLOODBONDED.dna.species
					G.master = owner
					G.last_vitae = world.time
					if(new_master)
						G.changed_master = TRUE
				else if(!iskindred(BLOODBONDED))
					BLOODBONDED.set_species(/datum/species/ghoul)
					var/datum/species/ghoul/G = BLOODBONDED.dna.species
					G.master = owner
					G.last_vitae = world.time
					if(new_master)
						G.changed_master = TRUE
			else
				giving = FALSE

/datum/species/kindred/check_roundstart_eligible()
	return TRUE
