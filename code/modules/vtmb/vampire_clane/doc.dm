/datum/vampireclane/doc
	name = "Daughters of Cacaphony"
	desc = "Currently composed mostly of women (due to the associated difficulty in educating someone with the vocal range of most males), the Daughters practice Melpominee, a Discipline which allows the Daughters to invoke strange effects through singing. The Daughters are the choralistes par excellence of the undead, and hosting a gathering of them is worth high prestige for the Toreador."
	curse = "Hunted and only con feeding."
	clane_disciplines = list(/datum/discipline/fortitude = 1,
														/datum/discipline/melpominee = 2,
														/datum/discipline/presence = 3)
	male_clothes = "/obj/item/clothing/under/vampire/sexy"
	female_clothes = "/obj/item/clothing/under/vampire/toreador/female"
	whitelist = list("badteammate", "meomoor", "leonko", "fourty2")
	enlightement = FALSE