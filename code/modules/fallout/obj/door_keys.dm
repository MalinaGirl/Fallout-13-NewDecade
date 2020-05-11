/obj/item/door_key
	name = "неиспользованный ключ"
	desc = "Маленький серый ключ."
	eng_name = "unused key"
	eng_desc = "Small grey key."
	icon = 'icons/fallout/objects/keys.dmi'
	icon_state = "empty_key"
	w_class = WEIGHT_CLASS_TINY
	slot_flags = SLOT_BELT
	var/id = null
	var/static/list/used_ids = list()
	self_weight = 0.1

/obj/item/door_key/New()
	..()
	if(id)
		attach_id(id)

/obj/item/door_key/attack_self(mob/user as mob)
	if(!id)
		return
	src.name = input("Choose key label.",,copytext_char(src.name,0, length(src.name) - 3)) + " key"
	return

/obj/item/door_key/attackby(obj/item/W, mob/user, params)
	if(istype(W,/obj/item/door_key))
		var/obj/item/door_key/K = W
		if((!src.id && !K.id) || (src.id && K.id))
			return 0
		if(alert(user,"You want to make copy of key?",,"Yes","No") == "No")
			return 0
		if(src.id && !K.id)
			K.attach_id(src.id)
		else
			src.attach_id(K.id)
		return 1
	. = ..()

/obj/item/door_key/proc/attach_id(id)
	src.id = id
	src.name = "key"
	src.icon_state = "key"
	if(!overlays_cache || !overlays_cache["usable_key"])
		var/icon/O = icon('icons/fallout/objects/keys.dmi', "key_overlay")
		if(!used_ids[num2text(id)])
			var/color = rgb(rand(50,255), rand(50,255), rand(50,255))
			O.ColorTone(color)
			used_ids[num2text(id)] = color
		else
			O.ColorTone(used_ids[num2text(id)])
		add_cached_overlay("usable_key", O)

/obj/item/door_key/proc/random_id()
	var/try_id = 1
	if(used_ids.len)
		try_id = text2num(used_ids[used_ids.len]) + 1
	CYCLE
	if(!used_ids[num2text(try_id)])
		return try_id
	try_id++
	goto CYCLE
	return null

/obj/item/weapon/storage/keys_set
	name = "key chain"
	desc = "Put your keys here and make using doors comfortable!"
	eng_name = "key chain"
	eng_desc = "Put your keys here and make using doors comfortable!"
	icon = 'icons/fallout/objects/keys.dmi'
	icon_state = "keychain_0"
	storage_slots = 4
	can_hold = list(/obj/item/door_key)
	rustle_jimmies = FALSE
	w_class = WEIGHT_CLASS_TINY
	max_w_class = WEIGHT_CLASS_TINY
	slot_flags = SLOT_BELT
	max_combined_w_class = 4

/obj/item/weapon/storage/keys_set/update_icon()
	icon_state = "keychain_[contents.len]"

/obj/item/weapon/storage/keys_set/proc/get_key_with_id(id)
	for(var/obj/item/door_key/K in contents)
		if(K.id == id)
			return K
	return null


/obj/item/lock
	name = "неиспользованный замок"
	desc = "Маленький серый замок."
	eng_name = "unused lock"
	icon = 'icons/fallout/objects/keys.dmi'
	icon_state = "closed_lock"
	w_class = WEIGHT_CLASS_TINY
	layer = 100
	var/open = FALSE
	var/id = null
	var/jammed = FALSE
	var/jammed_chance = 20
	var/spam_protect_time = 0

/obj/item/lock/New(location)
	..()
	layer = OBJ_LAYER
	if(id)
		attach_id(id)
		var/obj/structure/simple_door/D = locate(/obj/structure/simple_door) in loc
		if(istype(D) && D.can_hold_padlock)
			D.attach_padlock(src, TRUE)

/obj/item/lock/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/weapon/storage/keys_set))
		var/obj/item/weapon/storage/keys_set/S = W
		var/obj/item/door_key/K = S.get_key_with_id(id)
		if(istype(K))
			W = K

	if(istype(W,/obj/item/door_key))
		var/obj/item/door_key/K = W
		if(id)
			if(id == K.id)
				to_chat(user, "<span class='notice'>Вы начинаете [open ? "закрывать" : "открывать"] замок.</span>")
				if(do_after(user, 15, target = loc))
					if(!open && jammed)
						to_chat(user, "<span class='userdanger'>Ключ туго проворачивается в замке, похоже кто-то пытался его взломать!</span>")
					toogle()
			else
				to_chat(user, "<span class='warning'>Неверный ключ!</span>")
		else
			if(K.id)
				attach_id(K.id)
				to_chat(user, "<span class='notice'>[src] is attached by [K].</span>")
			else
				var/new_id
				new_id = K.random_id()
				K.attach_id(new_id)
				src.attach_id(new_id)
				to_chat(user, "<span class='notice'>[K] sets for [src] now.</span>")
		return 1

	if(istype(W,/obj/item/lockpick))
		if(jammed)
			to_chat(user, "<span class='warning'>Этот замок заклинил, теперь его можно открыть только ключом.</span>")
			return

		if(world.time < spam_protect_time)
			to_chat(user, "<span class='warning'>Вам нужно немного времени, чтобы сконцентрироваться.</span>")
			return

		var/obj/item/lockpick/L = W
		var/mob/living/carbon/C
		if(istype(user, /mob/living/carbon))
			C = user

		var/duration = C.skills.skillSpeedMod("lockpick", L.lockpicking_time)
		if(id && !open)
			spam_protect_time = duration + world.time
			to_chat(user, "<span class='warning'>Вы начинаете вскрывать замок.</span>")
			if(do_after(user, duration, target = loc))
				if(prob(C.skills.skillSuccessChance("lockpick")))
					toogle()
					to_chat(user, "<span class='green'>Вы вскрыли замок!.</span>")
					return
				else
					if(prob(jammed_chance))
						jammed = TRUE
						to_chat(user, "<span class='userdanger'>Замок заклинило!</span>")
					else
						to_chat(user, "<span class='warning'>Вам не удалось взломать замок!</span>")
				if(prob(L.broken_chance))
					to_chat(user, "<span class='warning'>[L.name] сломалась!</span>")
					qdel(L)
	. = ..()

/obj/item/lock/proc/attach_id(id)
	src.id = id
	src.name = "padlock"

/obj/item/lock/proc/toogle()
	open = !open
	jammed = FALSE
	update_icon()

/obj/item/lock/update_icon()
	icon_state = open ? "opened_lock" : "closed_lock"


  ////////////
 //LOCKPICK//
/obj/item/lockpick
	name = "заколка"
	desc = "Обычная заколка для волоc, однако в умелых руках может выступать в роли отмычки."
	eng_name = "hairpin"
	eng_desc = "The usual hair clip for hair, but in skilled hands can act as a lockpick."
	icon = 'icons/fallout/objects/keys.dmi'
	icon_state = "Hairpin"
	self_weight = 0.1
	w_class = WEIGHT_CLASS_TINY

	var/lockpicking_time = 100
	var/broken_chance = 50

/obj/item/lockpick/pro
	name = "отмычка"
	desc = "Профессиональный инструмент медвежатника."
	icon_state = "Professional_lockpick_kit"

	lockpicking_time = 50
	broken_chance = 15

/obj/item/lockpick/cheat
	color = "#009933"
	lockpicking_time = 1
	broken_chance = 0


  ////////////////
 //LOCKPICK BOX//
/obj/item/weapon/storage/bag/lockpicks
	name = "коробок шпилек"
	desc = "Маленькая довоенная коробочка со шпильками."
	eng_name = "hairpin box"
	eng_desc = "Small box for hairpins"
	icon = 'icons/fallout/objects/storage.dmi'
	icon_state = "lockpickbox_closed"
	item_state = "zippo"
	storage_slots = 60
	w_class = WEIGHT_CLASS_TINY
	slot_flags = SLOT_BELT
	display_contents_with_number = TRUE
	can_hold = list(/obj/item/lockpick)
	cant_hold = list(/obj/item/lockpick/pro)
	var/opened = FALSE

/obj/item/weapon/storage/bag/lockpicks/attack_self()
	opened = !opened
	update_icon()

/obj/item/weapon/storage/bag/lockpicks/New()
	..()
	var/count = rand(1, 5)
	for(var/i=1; i <= count; i++)
		new /obj/item/lockpick(src)

/obj/item/weapon/storage/bag/lockpicks/update_icon()
	if(!opened)
		icon_state = "lockpickbox_closed"
	else
		switch(contents.len)
			if(0) icon_state = "lockpickbox_open-0"
			if(1) icon_state = "lockpickbox_open-1"
			else icon_state = "lockpickbox_open-2"

/obj/item/weapon/storage/bag/lockpicks/handle_item_insertion(obj/item/W, prevent_warning = 0, mob/user)
	opened = TRUE
	return ..()

/obj/item/weapon/storage/bag/lockpicks/remove_from_storage(obj/item/W, atom/new_location, burn = 0)
	opened = TRUE
	return ..()

/// RANDOM LOCK ///
/obj/item/lock/random
	id = "null_blya"

/obj/item/lock/random/New()
	..()
	id = "[rand(1,10000)]"