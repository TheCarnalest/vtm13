/obj/structure/werewolf_totem
	name = "Tribe Totem"
	desc = "Gives power to all Garou of that tribe and steals it from others."
	icon = 'icons/mob/32x64.dmi'
	icon_state = "glassw"
	plane = GAME_PLANE
	layer = SPACEVINE_LAYER
	anchored = TRUE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	var/tribe
	var/totem_health = 500
	var/obj/overlay/totem_light_overlay
	var/totem_overlay_color = "#FFFFFF"

	var/last_rage = 0

/obj/structure/werewolf_totem/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(I.force)
		adjust_totem_health(round(I.force/2))

/obj/structure/werewolf_totem/bullet_act(obj/projectile/P, def_zone, piercing_hit = FALSE)
	. = ..()
	adjust_totem_health(round(P.damage/2))

/obj/structure/werewolf_totem/Initialize()
	. = ..()
	set_light(3, 0.5, totem_overlay_color)
	GLOB.totems += src
	totem_light_overlay = new(src)
	totem_light_overlay.icon = icon
	totem_light_overlay.icon_state = "[icon_state]_overlay"
	totem_light_overlay.plane = ABOVE_LIGHTING_PLANE
	totem_light_overlay.layer = ABOVE_LIGHTING_LAYER
	totem_light_overlay.color = totem_overlay_color
	overlays |= totem_light_overlay

/obj/structure/werewolf_totem/proc/adjust_totem_health(var/amount)
	if(amount > 0)
		if(totem_health == 0)
			return
		totem_health = max(0, totem_health-amount)
		if(totem_health == 0)
			icon_state = "[initial(icon_state)]_broken"
			overlays -= totem_light_overlay
			totem_light_overlay.icon_state = "[icon_state]_overlay"
			overlays |= totem_light_overlay
			for(var/mob/living/carbon/C in GLOB.player_list)
				if(iswerewolf(C) || isgarou(C))
					if(C.stat != DEAD)
						if(C.auspice.tribe == tribe)
							set_light(0)
							to_chat(C, "<span class='userdanger'><b>YOUR TOTEM IS DESTROYED</b></span>")
							SEND_SOUND(C, sound('sound/effects/tendril_destroyed.ogg', 0, 0, 75))
							adjust_gnosis(-5, C, FALSE)
		else
			for(var/mob/living/carbon/C in GLOB.player_list)
				if(iswerewolf(C) || isgarou(C))
					if(C.stat != DEAD)
						if(C.auspice.tribe == tribe)
							if(last_rage+50 < world.time)
								last_rage = world.time
								to_chat(C, "<span class='userdanger'><b>YOUR TOTEM IS BREAKING DOWN</b></span>")
								SEND_SOUND(C, sound('code/modules/ziggers/sounds/bumps.ogg', 0, 0, 75))
								adjust_rage(1, C, FALSE)
	if(amount < 0)
		totem_health = min(initial(totem_health), totem_health-amount)
		if(totem_health > 0)
			if(icon_state != initial(icon_state))
				for(var/mob/living/carbon/C in GLOB.player_list)
					if(iswerewolf(C) || isgarou(C))
						if(C.stat != DEAD)
							if(C.auspice.tribe == tribe)
								to_chat(C, "<span class='userhelp'><b>YOUR TOTEM IS RESTORED</b></span>")
								SEND_SOUND(C, sound('code/modules/ziggers/sounds/inspire.ogg', 0, 0, 75))
								adjust_gnosis(1, C, FALSE)
				icon_state = "[initial(icon_state)]"
				overlays -= totem_light_overlay
				totem_light_overlay.icon_state = "[icon_state]_overlay"
				overlays |= totem_light_overlay

/obj/structure/werewolf_totem/wendigo
	name = "Wendigo Totem"
	desc = "Gives power to all Garou of that tribe and steals it from others."
	icon_state = "wendigo"
	tribe = "Wendigo"
	totem_overlay_color = "#81ff4f"

/obj/structure/werewolf_totem/glasswalker
	name = "Glasswalker Totem"
	desc = "Gives power to all Garou of that tribe and steals it from others."
	icon_state = "glassw"
	tribe = "Glasswalkers"
	totem_overlay_color = "#35b0ff"

/obj/structure/werewolf_totem/spiral
	name = "Spiral Totem"
	desc = "Gives power to all Garou of that tribe and steals it from others."
	icon = 'code/modules/ziggers/64x32.dmi'
	icon_state = "spiral"
	tribe = "Black Spiral"
	totem_overlay_color = "#ff5235"
	pixel_w = -16