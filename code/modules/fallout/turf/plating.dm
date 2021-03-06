//Fallout 13 floor plating directory

/turf/open/floor/plating/wooden
	name = "фундамент"
	eng_name = "house base"
	icon_state = "housebase"
	icon = 'icons/fallout/turfs/ground.dmi'
	intact = 0
	sheet_type = /obj/item/stack/sheet/mineral/wood
	broken_states = list("housebase1-broken", "housebase2-broken", "housebase3-broken", "housebase4-broken")
	burnt_states = list("housebase")
	step_sounds = list("human" = "woodfootsteps")

/turf/open/floor/plating/wooden/make_plating()
	return src

/turf/open/floor/plating/tunnel
	name = "металлический пол"
	eng_name = "metal floor"
	icon_state = "tunneldirty"
	icon = 'icons/fallout/turfs/ground.dmi'
	baseturf = /turf/open/indestructible/ground/mountain