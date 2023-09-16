/datum/vampireclane/gangrel
	name = "Gangrel"
	desc = "Often closer to beasts than other vampires, the Gangrel style themselves apex predators. These Ferals prowl the wilds as easily as the urban jungle, and no clan of vampires can match their ability to endure, survive, and thrive in any environment. Often fiercely territorial, their shapeshifting abilities even give the undead pause."
	curse = "Start with lower humanity."
	clane_disciplines = list(/datum/discipline/animalism = 1,
														/datum/discipline/fortitude = 2,
														/datum/discipline/protean = 3)
	start_humanity = 6
	male_clothes = "/obj/item/clothing/under/vampire/gangrel"
	female_clothes = "/obj/item/clothing/under/vampire/gangrel/female"

/mob/living/simple_animal/hostile/werewolf
	name = "Werewolf"
	desc = "AUF."
	icon = 'code/modules/ziggers/48x64.dmi'
	icon_state = "werewolf"
	icon_living = "werewolf"
	icon_dead = "werewolf_dead"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	speak_chance = 0
	speed = -1
	maxHealth = 1000
	health = 1000
	butcher_results = list(/obj/item/stack/human_flesh = 20)
	harm_intent_damage = 5
	melee_damage_lower = 50
	melee_damage_upper = 50
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	a_intent = INTENT_HARM
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	bloodpool = 10
	maxbloodpool = 10
	pixel_w = -8