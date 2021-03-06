//Fallout 13 general destructible floor directory

/turf/open/floor/f13
	name = "пол"
	desc = "Самый обычный пол."
	eng_name = "floor"
	eng_desc = "An regular floor."
	icon_state = "floor"
	icon_regular_floor = "floor"
	icon_plating = "plating"
	icon = 'icons/fallout/turfs/floors.dmi'

/turf/open/floor/f13/ReplaceWithLattice()
	ChangeTurf(baseturf)

/turf/open/floor/f13/wood
	name = "деревянный пол"
	icon_state = "housewood1"
	icon = 'icons/fallout/turfs/ground.dmi'
	floor_tile = /obj/item/stack/tile/wood
	sheet_type = /obj/item/stack/sheet/mineral/wood
	icon_plating = "housebase"
	step_sounds = list("human" = "woodfootsteps")
	broken_states = list("housewood1-broken", "housewood2-broken", "housewood3-broken", "housewood4-broken")

/turf/open/floor/f13/wood/New()
	..()
	if(prob(5))
		broken = 1
		icon_state = pick(broken_states)
	else
		icon_state = "housewood[rand(1,4)]"

/turf/open/floor/f13/wood/make_plating()
	return ChangeTurf(/turf/open/floor/plating/wooden)

/turf/open/floor/f13/wood/attackby(obj/item/C, mob/user, params)
	if(..())
		return
	if(istype(C, /obj/item/weapon/screwdriver))
		if(broken || burnt)
			new /obj/item/stack/sheet/mineral/wood(src)
		else
			new floor_tile(src)
		to_chat(user, "<span class='danger'>You unscrew the planks.</span>")
		make_plating()
		playsound(src, C.usesound, 80, 1)
		return

///Вуна, ты костыльный пидорас, знай это. Удивительно что это вообще работает.

/turf/open/floor/f13/wood/stage
	icon_state = "housewood_stage1"

/turf/open/floor/f13/wood/housebase
	icon_state = "housebase"

/turf/open/floor/f13/wood/housebase/sand
	icon_state = "housebase_sand"

/turf/open/floor/f13/wood/housebase/sand/corner
	icon_state = "housebase_sandcorner"

/turf/open/floor/f13/wood_st
	icon_state = "wood_st"
	icon_plating = "plating"
	name = "пол"
	eng_name = "floor"
	icon = 'icons/fallout/turfs/ground.dmi'
	floor_tile = /obj/item/stack/tile/wood
	sheet_type = /obj/item/stack/sheet/mineral/wood
	icon_plating = "housebase"
	step_sounds = list("human" = "woodfootsteps")