/mob/living/carbon/human/npc
	name = "Loh ebanii"
	a_intent = INTENT_HELP
	var/datum/socialrole/socialrole

	var/is_talking = FALSE
	var/last_annoy = 0

	var/last_danger_meet = 0
	var/mob/living/danger_source
	var/mob/living/last_attacker

	var/turf/walktarget	//dlya movementa

	var/last_grab = 0

	var/tupik_steps = 0
	var/tupik_loc

	var/stopturf = 1

	var/obj/item/my_weapon

	//Zdes hranim oruzhie
	var/obj/item/storage/backpack/inventory

	var/ghoulificating = FALSE
	var/ghoulificated = FALSE

/datum/socialrole
	//For randomizing
	var/list/s_tones = list("albino",
													"caucasian1",
													"caucasian2",
													"caucasian3",
													"latino",
													"mediterranean",
													"asian1",
													"asian2",
													"arab",
													"indian",
													"african1",
													"african2")
	var/min_age = 18
	var/max_age = 85
	var/preferedgender
	var/list/male_names = list("Jack",
															"Robert",
															"Cornelius",
															"Tyler")
	var/list/female_names = list("Marla")
	var/list/surnames = list("Durden",
														"Polson",
														"Singer")

	//Hair shit
	var/list/hair_colors = list("040404",	//Black
															"120b05",	//Dark Brown
															"342414",	//Brown
															"554433",	//Light Brown
															"695c3b",	//Dark Blond
															"ad924e",	//Blond
															"dac07f",	//Light Blond
															"802400",	//Ginger
															"a5380e",	//Ginger alt
															"ffeace",	//Albino
															"650b0b",	//Punk Red
															"14350e",	//Punk Green
															"080918")	//Punk Blue

	var/list/male_hair = list("Bald",
														"Afro",
														"Afro 2",
														"Afro (Large)",
														"Balding Hair",
														"Bedhead",
														"Bedhead 2",
														"Bedhead 3",
														"Boddicker",
														"Bowlcut",
														"Bowlcut 2",
														"Business Hair",
														"Business Hair 2",
														"Business Hair 3",
														"Business Hair 4",
														"Bun (Manbun)",
														"Buzzcut",
														"Comet",
														"CIA",
														"Coffee House",
														"Combover",
														"Crewcut",
														"Father",
														"Flat Top",
														"Gelled Back",
														"Joestar",
														"Keanu Hair",
														"Mohawk",
														"Mohawk (Shaved)",
														"Mohawk (Unshaven)",
														"Oxton",
														"Pompadour",
														"Ronin",
														"Shaved")
	var/list/male_facial = list("Beard (Abraham Lincoln)",
															"Beard (Chinstrap)",
															"Beard (Dwarf)",
															"Beard (Full)",
															"Beard (Cropped Fullbeard)",
															"Beard (Goatee)",
															"Beard (Hipster)",
															"Beard (Neckbeard)",
															"Beard (Very Long)",
															"Beard (Martial Artist)",
															"Beard (Moonshiner)",
															"Beard (Long)",
															"Beard (Volaju)",
															"Beard (Three o Clock Shadow)",
															"Beard (Five o Clock Shadow)",
															"Beard (Seven o Clock Shadow)",
															"Moustache (Fu Manchu)",
															"Moustache (Hulk Hogan)",
															"Moustache (Watson)",
															"Sideburns (Elvis)",
															"Sideburns (Mutton Chops)",
															"Sideburns",
															"Shaved")
	var/list/female_hair = list("Ahoge",
															"Long Bedhead",
															"Beehive",
															"Beehive 2",
															"Bob Hair",
															"Bob Hair 2",
															"Bob Hair 3",
															"Bob Hair 4",
															"Bobcurl",
															"Braided",
															"Braided Front",
															"Braid (Short)",
															"Braid (Low)",
															"Bun Head",
															"Bun Head 2",
															"Bun Head 3",
															"Bun (Large)",
															"Bun (Tight)",
															"Double Bun",
															"Emo",
															"Emo Fringe",
															"Feather",
															"Gentle",
															"Long Hair 1",
															"Long Hair 2",
															"Long Hair 3",
															"Long Over Eye",
															"Long Emo",
															"Long Fringe",
															"Ponytail",
															"Ponytail 2",
															"Ponytail 3",
															"Ponytail 4",
															"Ponytail 5",
															"Ponytail 6",
															"Ponytail 7",
															"Ponytail (High)",
															"Ponytail (Short)",
															"Ponytail (Long)",
															"Ponytail (Country)",
															"Ponytail (Fringe)",
															"Poofy",
															"Short Hair Rosa",
															"Shoulder-length Hair",
															"Volaju")

	//For equiping with random
	var/list/backpacks = list(/obj/item/storage/backpack/satchel,
														/obj/item/storage/backpack/satchel/leather)
	var/list/shoes = list()
	var/list/uniforms = list()
	var/list/belts = list()
	var/list/suits = list()
	var/list/hats = list()
	var/list/gloves = list()
	var/list/masks = list()
	var/list/neck = list()
	var/list/ears = list()
	var/list/glasses = list()
	var/list/inhand_items = list()
	var/list/pockets = list()

	//For workers and police
	var/obj/item/card/id/id_type

	//What will npc use in fight, if so
	var/obj/item/melee/melee_weapon
	var/obj/item/gun/range_weapon

	//For reaction
	var/list/male_phrases = list("Меня жена дома ждёт...",
																"Прости, дружище, не сегодня.",
																"Сходи найди себе кого-нибудь в баре, я занят.")
	var/list/female_phrases = list("Купи себе часы.",
																	"Я сейчас закричу!",
																	"Не трогай меня.")
	var/list/neutral_phrases = list("Отвали.",
																	"Иди своей дорогой.",
																	"Сейчас не лучшее время для разговоров.",
																	"Мгм...",
																	"Разве я тебя знаю?",
																	"У меня мало времени.")
	var/list/random_phrases = list("Опять приезжие...",
																	"Кажется я уже третий круг тут мотаю.",
																	"Чёртовы либералы!",
																	"Хах, опять выборы?",
																	"Крысы с канализации сбежали. Во дела...",
																	"Слухи быстро расходятся.")
	var/list/answer_phrases = list("Соглашусь.",
																	"Да-да...",
																	"Именно.",
																	"Наверное.",
																	"Точно.",
																	"Ага...")
	var/list/help_phrases = list("На помощь!",
																"Помогите!!",
																"Что же это такое творится?!",
																"Чёрт!!")

/mob/living/carbon/human/npc/proc/AssignSocialRole(var/datum/socialrole/S, var/dont_random = FALSE)
	if(!S)
		return
	socialrole = new S()
	if(!dont_random)
		gender = pick(MALE, FEMALE)
		if(socialrole.preferedgender)
			gender = socialrole.preferedgender
		var/list/m_names = list()
		var/list/f_names = list()
		var/list/s_names = list()
		if(socialrole.male_names)
			m_names = socialrole.male_names
		else
			m_names = GLOB.first_names_male
		if(socialrole.female_names)
			f_names = socialrole.female_names
		else
			f_names = GLOB.first_names_female
		if(socialrole.surnames)
			s_names = socialrole.surnames
		else
			s_names = GLOB.last_names
		age = rand(socialrole.min_age, socialrole.max_age)
		skin_tone = pick(socialrole.s_tones)
		if(age >= 55)
			hair_color = "a2a2a2"
			facial_hair_color = hair_color
		else
			hair_color = pick(socialrole.hair_colors)
			facial_hair_color = hair_color
		if(gender == MALE)
			hairstyle = pick(socialrole.male_hair)
			if(prob(25) || age >= 25)
				facial_hairstyle = pick(socialrole.male_facial)
			else
				facial_hairstyle = "Shaved"
			real_name = "[pick(m_names)] [pick(s_names)]"
		else
			hairstyle = pick(socialrole.female_hair)
			facial_hairstyle = "Shaved"
			real_name = "[pick(f_names)] [pick(s_names)]"
		name = real_name
		dna.real_name = real_name
		var/obj/item/organ/eyes/organ_eyes = getorgan(/obj/item/organ/eyes)
		organ_eyes.eye_color = random_eye_color()
		underwear = random_underwear(gender)
		if(prob(50))
			underwear_color = organ_eyes.eye_color
		if(prob(50) || gender == FEMALE)
			undershirt = random_undershirt(gender)
		if(prob(25))
			socks = random_socks()
		update_body()
		update_hair()
		update_body_parts()

	var/datum/outfit/O = new()
	if(length(socialrole.backpacks))
		O.back = pick(socialrole.backpacks)
	if(length(socialrole.uniforms))
		O.uniform = pick(socialrole.uniforms)
	if(length(socialrole.belts))
		O.belt = pick(socialrole.belts)
	if(length(socialrole.suits))
		O.suit = pick(socialrole.suits)
	if(length(socialrole.gloves))
		O.gloves = pick(socialrole.gloves)
	if(length(socialrole.shoes))
		O.shoes = pick(socialrole.shoes)
	if(length(socialrole.hats))
		O.head = pick(socialrole.hats)
	if(length(socialrole.masks))
		O.mask = pick(socialrole.masks)
	if(length(socialrole.neck))
		O.neck = pick(socialrole.neck)
	if(length(socialrole.ears))
		O.ears = pick(socialrole.ears)
	if(length(socialrole.glasses))
		O.glasses = pick(socialrole.glasses)
	if(length(socialrole.inhand_items))
		O.r_hand = pick(socialrole.inhand_items)
	if(socialrole.id_type)
		O.id = socialrole.id_type
	if(O.uniform && length(socialrole.pockets))
		O.l_pocket = pick(socialrole.pockets)
		if(length(socialrole.pockets)-1 > 0 && prob(50))
			var/list/another_pocket = socialrole.pockets.Copy()
			another_pocket -= O.l_pocket
			O.r_pocket = pick(another_pocket)
	equipOutfit(O)
	qdel(O)

/mob/living/carbon/human/npc/proc/GetSayDelay(var/message)
	var/delay = length_char(message)
	return delay

/mob/living/carbon/human/npc/proc/RealisticSay(var/message)
	if(!message)
		return
	if(is_talking)
		return
	if(stat >= 2)
		return
	is_talking = TRUE
	var/delay = length_char(message)
	spawn(rand(5, 10))
		remove_overlay(FIGHT_LAYER)
		var/mutable_appearance/parry_overlay = mutable_appearance('icons/mob/talk.dmi', "default0", -FIGHT_LAYER)
		overlays_standing[FIGHT_LAYER] = parry_overlay
		apply_overlay(FIGHT_LAYER)
		spawn(delay)
			if(stat != DEAD)
				remove_overlay(FIGHT_LAYER)
				say(message)
				is_talking = FALSE

/mob/living/carbon/human/npc/proc/Annoy(var/atom/source)
	if(client)
		return
	if(is_talking)
		return
	if(danger_source)
		return
	if(stat >= 2)
		return
	if(world.time <= last_annoy+50)
		return
	if(source)
		spawn(rand(3, 7))
			face_atom(source)
	last_annoy = world.time
	var/phrase
	if(prob(50))
		phrase = pick(socialrole.neutral_phrases)
	else
		if(gender == MALE)
			phrase = pick(socialrole.male_phrases)
		else
			phrase = pick(socialrole.female_phrases)
	RealisticSay(phrase)

/mob/living/carbon/human/Move(NewLoc, direct)
	update_shadow()
	var/mob/living/carbon/human/npc/NPC = locate() in NewLoc
	if(NPC)
		if(a_intent != INTENT_HELP)
			NPC.Annoy(src)
	..()


/mob/living/carbon/human/toggle_resting()
	..()
	update_shadow()

/mob/living/carbon/human/proc/update_shadow()
	if(body_position != LYING_DOWN)
		if(!overlays_standing[UNDERSHADOW_LAYER])
			var/mutable_appearance/lying_overlay = mutable_appearance('code/modules/ziggers/icons.dmi', "shadow", -UNDERSHADOW_LAYER)
			lying_overlay.pixel_z = -4
			lying_overlay.alpha = 64
			overlays_standing[UNDERSHADOW_LAYER] = lying_overlay
			apply_overlay(UNDERSHADOW_LAYER)
	else if(overlays_standing[UNDERSHADOW_LAYER])
		remove_overlay(UNDERSHADOW_LAYER)

/mob/living/carbon/human/npc/Move(NewLoc, direct)
	var/mob/living/carbon/human/npc/NPC = locate() in NewLoc
	if(NPC)
		if(prob(10))
			NPC.Annoy(src)
	..()

/mob/living/carbon/human/npc/attack_hand(mob/user)
	if(user.a_intent == INTENT_HELP)
		Annoy(user)
	if(user.a_intent == INTENT_DISARM)
		Aggro(user, TRUE)
	if(user.a_intent == INTENT_HARM)
		for(var/mob/living/carbon/human/npc/NEPIC in viewers(7, src))
			NEPIC.Aggro(user)
			if(NEPIC == src)
				NEPIC.Aggro(user, TRUE)
	..()

/mob/living/carbon/human/npc/on_hit(obj/projectile/P)
	. = ..()
	Aggro(P.firer, TRUE)

/mob/living/carbon/human/npc/hitby(atom/movable/AM, skipcatch, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	. = ..()
	Aggro(throwingdatum.thrower, TRUE)

/mob/living/carbon/human/npc/attackby(obj/item/W, mob/living/user, params)
	. = ..()
	Aggro(user, TRUE)

/mob/living/carbon/human/npc/grabbedby(mob/living/carbon/user, supress_message = FALSE)
	. = ..()
	last_grab = world.time

/mob/living/carbon/human/npc/proc/EmoteAction()
	var/shitemote = pick("sigh", "smile", "stare", "look", "spin", "giggle", "blink", "blush", "nod", "sniff", "shrug", "cough", "yawn")
	if(!is_talking)
		is_talking = TRUE
		spawn(rand(5, 10))
			emote(shitemote)
			is_talking = FALSE

/mob/living/carbon/human/npc/proc/StareAction()
	if(!is_talking)
		var/list/interest_persons = list()
		for(var/mob/living/carbon/human/H in viewers(4, src))
			if(H)
				if(H != src)
					interest_persons += H
		if(length(interest_persons))
			is_talking = TRUE
			spawn(rand(2, 7))
				face_atom(pick(interest_persons))
				spawn(rand(1, 5))
					is_talking = FALSE

/mob/living/carbon/human/npc/proc/SpeechAction()
	if(!is_talking)
		var/list/interest_persons = list()
		for(var/mob/living/carbon/human/npc/H in viewers(4, src))
			if(H)
				if(H != src)
					interest_persons += H
		if(length(interest_persons))
			var/mob/living/carbon/human/npc/N = pick(interest_persons)
			face_atom(N)
			var/question = pick(socialrole.random_phrases)
			RealisticSay(question)
			spawn(rand(1, 5))
				N.face_atom(src)
				N.is_talking = TRUE
				spawn(GetSayDelay(question))
					N.is_talking = FALSE
					N.RealisticSay(pick(N.socialrole.answer_phrases))

/mob/living/carbon/human/npc/proc/ghoulificate(mob/owner)
	set waitfor = FALSE
	var/list/mob/dead/observer/candidates = pollCandidatesForMob("Do you want to play as [owner]`s ghoul?", null, null, null, 50, src)
	for(var/mob/dead/observer/G in GLOB.player_list)
		if(G.key)
			to_chat(G, "<span class='ghostalert'>[owner] is ghoulificating [src].</span>")
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		src.key = C.key
		ghoulificated = TRUE
		to_chat(src, "<span class='warning'><b>You feel blood connection with [owner]. Serve your master.</b></span>")

/mob/living/carbon/human/npc/AltClick(mob/user)
	. = ..()
	if(iskindred(user) && !ghoulificated && !ghoulificating)
		ghoulificating = TRUE
		if(do_mob(user, src, 7 SECONDS))
			to_chat(user, "<span class='warning'>I gave my <b>BLOOD</b> to mortal.</span>")
			ghoulificating = FALSE
			if(!ghoulificated)
				src.ghoulificate(user)
		else
			ghoulificating = FALSE

/mob/living/carbon/human/npc/Destroy()
	. = ..()
	SShumannpcpool.npclost()
