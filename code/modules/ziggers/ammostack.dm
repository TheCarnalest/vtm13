/obj/projectile/beam/beam_rifle/vampire
	name = "bullet"
	icon = null
	damage = 20
	pass_flags = PASSTABLE
	damage_type = BRUTE
	nodamage = FALSE
	flag = BULLET
	reflectable = NONE
	ricochets_max = 0
	hitsound = 'sound/weapons/pierce.ogg'
	hitsound_wall = "ricochet"
	sharpness = SHARP_POINTY
	impact_effect_type = /obj/effect/temp_visual/impact_effect
	shrapnel_type = /obj/item/shrapnel/bullet
	embedding = list(embed_chance=15, fall_chance=2, jostle_chance=0, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.5, pain_mult=3, rip_time=10)
	wound_falloff_tile = -5
	embed_falloff_tile = -5
	range = 50
	eyeblur = 0
	light_range = 0
	light_power = 0
//	jitter = 10
	icon_state = ""
	hitscan = TRUE
	tracer_type = /obj/effect/projectile/tracer/tracer/beam_rifle/vampire

/obj/projectile/beam/beam_rifle/vampire/generate_hitscan_tracers(cleanup = TRUE, duration = 5, impacting = TRUE, highlander)
	set waitfor = FALSE
	if(isnull(highlander))
		highlander = TRUE
	if(highlander && istype(gun))
		QDEL_LIST(gun.current_tracers)
		for(var/datum/point/p in beam_segments)
			gun.current_tracers += generate_tracer_between_points(p, beam_segments[p], tracer_type, color, 0, hitscan_light_range, hitscan_light_color_override, hitscan_light_intensity)
	else
		for(var/datum/point/p in beam_segments)
			generate_tracer_between_points(p, beam_segments[p], tracer_type, color, duration, hitscan_light_range, hitscan_light_color_override, hitscan_light_intensity)
	if(cleanup)
		QDEL_LIST(beam_segments)
		beam_segments = null
		QDEL_NULL(beam_index)

/obj/projectile/beam/beam_rifle/vampire/vamp9mm
	name = "9mm bullet"
	damage = 25

/obj/projectile/beam/beam_rifle/vampire/vamp45acp
	name = ".45 ACP bullet"
	damage = 25

/obj/projectile/beam/beam_rifle/vampire/vamp44
	name = ".44 bullet"
	damage = 35
	armour_penetration = 15

/obj/projectile/beam/beam_rifle/vampire/vamp556mm
	name = "5.56mm bullet"
	damage = 45
	armour_penetration = 30

/obj/projectile/beam/beam_rifle/vampire/vamp545mm
	name = "5.45mm bullet"
	damage = 45
	armour_penetration = 30

/obj/projectile/beam/beam_rifle/vampire/vamp12g
	name = "12g shotgun slug"
	damage = 55

/obj/projectile/beam/beam_rifle/vampire/vamp12g/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.Stun(20)

/obj/projectile/beam/beam_rifle/vampire/vamp556mm/incendiary
	armour_penetration = 0
	damage = 30
	var/fire_stacks = 4

/obj/projectile/beam/beam_rifle/vampire/vamp556mm/incendiary/on_hit(atom/target, blocked = FALSE)
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.adjust_fire_stacks(fire_stacks)
		M.IgniteMob()

/obj/projectile/bullet/crossbow_bolt
	name = "bolt"
	damage = 200
	armour_penetration = 100
	sharpness = SHARP_POINTY
	wound_bonus = 50

/obj/item/ammo_casing/vampire
	icon = 'code/modules/ziggers/ammo.dmi'
	onflooricon = 'code/modules/ziggers/onfloor.dmi'
	var/base_iconstate

/obj/item/ammo_casing/vampire/c9mm
	name = "9mm bullet casing"
	desc = "A 9mm bullet casing."
	caliber = CALIBER_9MM
	projectile_type = /obj/projectile/beam/beam_rifle/vampire/vamp9mm
	icon_state = "9"
	base_iconstate = "9"

/obj/item/ammo_casing/vampire/c45acp
	name = ".45 ACP bullet casing"
	desc = "A .45 ACP bullet casing."
	caliber = CALIBER_45
	projectile_type = /obj/projectile/beam/beam_rifle/vampire/vamp45acp
	icon_state = "45"
	base_iconstate = "45"

/obj/item/ammo_casing/vampire/c44
	name = ".44 bullet casing"
	desc = "A .44 bullet casing."
	caliber = CALIBER_44
	projectile_type = /obj/projectile/beam/beam_rifle/vampire/vamp44
	icon_state = "44"
	base_iconstate = "44"

/obj/item/ammo_casing/vampire/c556mm
	name = "5.56mm bullet casing"
	desc = "A 5.56mm bullet casing."
	caliber = CALIBER_556
	projectile_type = /obj/projectile/beam/beam_rifle/vampire/vamp556mm
	icon_state = "556"
	base_iconstate = "556"

/obj/item/ammo_casing/vampire/c545mm
	name = "5.45mm bullet casing"
	desc = "A 5.45mm bullet casing."
	caliber = CALIBER_545
	projectile_type = /obj/projectile/beam/beam_rifle/vampire/vamp545mm
	icon_state = "545"
	base_iconstate = "545"

/obj/item/ammo_casing/vampire/c556mm/incendiary
	projectile_type = /obj/projectile/beam/beam_rifle/vampire/vamp556mm/incendiary

/obj/item/ammo_casing/vampire/c12g
	name = "12g bullet casing"
	desc = "A 12g bullet casing."
	caliber = CALIBER_12G
	projectile_type = /obj/projectile/beam/beam_rifle/vampire/vamp12g
	icon_state = "12"
	base_iconstate = "12"

/*
/obj/item/storage/ammostack
	icon = 'code/modules/ziggers/ammo.dmi'
	var/base_caliber = "tut base_iconstate"
	var/max_patroni = 5

/obj/item/storage/ammostack/update_icon()
	. = ..()
	var/patroni = 0
	for(var/obj/item/ammo_casing/vampire/V in src)
		if(V)
			patroni = max(0, patroni+1)
	if(patroni)
		if(patroni > 1)
			icon_state = "[base_caliber]-[patroni]"
		else
			icon_state = "[base_caliber]-live"

/obj/item/storage/ammostack/attackby(obj/item/I, mob/user, params)
	. = ..()
	var/patroni = 0
	for(var/obj/item/ammo_casing/vampire/V in src)
		if(V)
			patroni = max(0, patroni+1)
	if(istype(I, /obj/item/ammo_casing/vampire))
		var/obj/item/ammo_casing/vampire/V = I
		if(patroni < max_patroni && V.base_iconstate = base_caliber)
			I.forceMove(src)
			update_icon()

/obj/item/storage/ammostack/Initialize()
	. = ..()
*/

/obj/item/ammo_box/vampire
	icon = 'code/modules/ziggers/ammo.dmi'
	onflooricon = 'code/modules/ziggers/onfloor.dmi'

/obj/item/ammo_box/vampire/c9mm
	name = "ammo box (9mm)"
	icon_state = "9box"
	ammo_type = /obj/item/ammo_casing/vampire/c9mm
	max_ammo = 100

/obj/item/ammo_box/vampire/c45acp
	name = "ammo box (.45 ACP)"
	icon_state = "45box"
	ammo_type = /obj/item/ammo_casing/vampire/c45acp
	max_ammo = 100

/obj/item/ammo_box/vampire/c44
	name = "ammo box (.44)"
	icon_state = "44box"
	ammo_type = /obj/item/ammo_casing/vampire/c44
	max_ammo = 60

/obj/item/ammo_box/vampire/c556
	name = "ammo box (5.56)"
	icon_state = "556box"
	ammo_type = /obj/item/ammo_casing/vampire/c556mm
	max_ammo = 60

/obj/item/ammo_box/vampire/c545
	name = "ammo box (5.45)"
	icon_state = "545box"
	ammo_type = /obj/item/ammo_casing/vampire/c545mm
	max_ammo = 60

/obj/item/ammo_box/vampire/c556/incendiary
	name = "incendiary ammo box (5.56)"
	icon_state = "incendiary"
	ammo_type = /obj/item/ammo_casing/vampire/c556mm/incendiary

/obj/item/ammo_box/vampire/c12g
	name = "ammo box (12g)"
	icon_state = "12box"
	ammo_type = /obj/item/ammo_casing/vampire/c12g
	max_ammo = 30

/obj/item/ammo_box/vampire/arrows
	name = "ammo box (arrows)"
	icon_state = "arrows"
	ammo_type = /obj/item/ammo_casing/caseless/bolt
	max_ammo = 30

/obj/projectile/beam/beam_rifle/vampire/vamp556mm/silver
	name = "5.56mm silver bullet"
	armour_penetration = 10
	damage = 30

/obj/projectile/beam/beam_rifle/vampire/vamp556mm/silver/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iswerewolf(target) || isgarou(target))
		var/mob/living/carbon/M = target
		if(M.auspice.gnosis)
			if(prob(40))
				adjust_gnosis(-1, M)
		else
			M.Stun(10)
			M.adjustBruteLoss(50, TRUE)

/obj/projectile/beam/beam_rifle/vampire/vamp9mm/silver
	name = "9mm silver bullet"
	damage = 25

/obj/projectile/beam/beam_rifle/vampire/vamp9mm/silver/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iswerewolf(target) || isgarou(target))
		var/mob/living/carbon/M = target
		if(M.auspice.gnosis)
			if(prob(40))
				adjust_gnosis(-1, M)
		else
			M.Stun(10)
			M.adjustBruteLoss(50, TRUE)

/obj/projectile/beam/beam_rifle/vampire/vamp45acp/silver
	name = ".45 ACP silver bullet"
	damage = 25

/obj/projectile/beam/beam_rifle/vampire/vamp45acp/silver/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iswerewolf(target) || isgarou(target))
		var/mob/living/carbon/M = target
		if(M.auspice.gnosis)
			if(prob(40))
				adjust_gnosis(-1, M)
		else
			M.Stun(10)
			M.adjustBruteLoss(50, TRUE)

/obj/projectile/beam/beam_rifle/vampire/vamp44/silver
	name = ".44 silver bullet"
	damage = 35
	armour_penetration = 15

/obj/projectile/beam/beam_rifle/vampire/vamp44/silver/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iswerewolf(target) || isgarou(target))
		var/mob/living/carbon/M = target
		if(M.auspice.gnosis)
			if(prob(40))
				adjust_gnosis(-1, M)
		else
			M.Stun(10)
			M.adjustBruteLoss(50, TRUE)

/obj/item/ammo_casing/vampire/c9mm/silver
	name = "9mm silver bullet casing"
	desc = "A 9mm silver bullet casing."
	projectile_type = /obj/projectile/beam/beam_rifle/vampire/vamp9mm/silver

/obj/item/ammo_casing/vampire/c45acp/silver
	name = ".45 ACP silver bullet casing"
	desc = "A .45 ACP silver bullet casing."
	projectile_type = /obj/projectile/beam/beam_rifle/vampire/vamp45acp/silver

/obj/item/ammo_casing/vampire/c44/silver
	name = ".44 silver bullet casing"
	desc = "A .44 silver bullet casing."
	projectile_type = /obj/projectile/beam/beam_rifle/vampire/vamp44/silver

/obj/item/ammo_casing/vampire/c556mm/silver
	name = "5.56mm silver bullet casing"
	desc = "A 5.56mm silver bullet casing."
	projectile_type = /obj/projectile/beam/beam_rifle/vampire/vamp556mm/silver

/obj/item/ammo_box/vampire/c9mm/silver
	name = "ammo box (9mm silver)"
	icon_state = "9box-silver"
	ammo_type = /obj/item/ammo_casing/vampire/c9mm/silver
	max_ammo = 100

/obj/item/ammo_box/vampire/c45acp/silver
	name = "ammo box (.45 ACP silver)"
	icon_state = "45box-silver"
	ammo_type = /obj/item/ammo_casing/vampire/c45acp/silver
	max_ammo = 100

/obj/item/ammo_box/vampire/c44/silver
	name = "ammo box (.44 silver)"
	icon_state = "44box-silver"
	ammo_type = /obj/item/ammo_casing/vampire/c44/silver
	max_ammo = 60

/obj/item/ammo_box/vampire/c556/silver
	name = "ammo box (5.56 silver)"
	icon_state = "556box-silver"
	ammo_type = /obj/item/ammo_casing/vampire/c556mm/silver
	max_ammo = 60