/mob/living/carbon/examine(mob/user)
	var/t_He = p_they(TRUE)
	var/t_His = p_their(TRUE)
	var/t_his = p_their()
//	var/t_him = p_them()
	var/t_has = p_have()
	var/t_is = p_are()

	var/msg = ""

	if (handcuffed)
		msg += "<span class='warning'>[t_He] [bicon(src.handcuffed)] в наручниках!</span>\n"
	if (head)
		msg += "[t_He] носит [bicon(src.head)]  [src.head] на [t_his] голове. \n"
	if (wear_mask)
		msg += "[t_He] носит [bicon(src.wear_mask)]  [src.wear_mask] на [t_his] лице.\n"
	if (wear_neck)
		msg += "[t_He] носит [bicon(src.wear_neck)]  [src.wear_neck] вокруг [t_his] шеи.\n"

	for(var/obj/item/I in held_items)
		if(!(I.flags & ABSTRACT))
			if(I.blood_DNA)
				msg += "<span class='warning'>[t_He] [t_is] держит [bicon(I)] [I.gender==PLURAL?"some":"a"] покрытый кровью [I.name] в [t_his] [get_held_index_name(get_held_index_of_item(I))]!</span>\n"
			else
				msg += "[t_He] [t_is] holding [bicon(I)] \a [I] in [t_his] [get_held_index_name(get_held_index_of_item(I))].\n"

	if (back)
		msg += "[t_He] [t_has] [bicon(src.back)] [src.back] на [t_his] спине.\n"
	var/appears_dead = 0
	if (stat == DEAD)
		appears_dead = 1
		if(getorgan(/obj/item/organ/brain))
			msg += "<span class='deadsay'>[t_He] [t_is] limp and unresponsive, with no signs of life.</span>\n"
		else if(get_bodypart("head"))
			msg += "<span class='deadsay'>[t_He] appears that [t_his] brain is missing...</span>\n"

	var/list/missing = get_missing_limbs()
	for(var/t in missing)
		if(t=="head")
			msg += "<span class='deadsay'><B>[t_His] [parse_zone(t)] отсутствует!</B></span>\n"
			continue
		msg += "<span class='warning'><B>[t_His] [parse_zone(t)] отсутствует!</B></span>\n"

	msg += "<span class='warning'>"
	var/temp = getBruteLoss()
	if(temp)
		if (temp < 30)
			msg += "[t_He] имеет небольшие раны.\n"
		else
			msg += "<B>[t_He] имеет огромные раны!</B>\n"

	temp = getFireLoss()
	if(temp)
		if (temp < 30)
			msg += "[t_He] имеет небольшие ожоги.\n"
		else
			msg += "<B>[t_He] имеет обширные ожоги!</B>\n"

	temp = getCloneLoss()
	if(temp)
		if(getCloneLoss() < 30)
			msg += "[t_He] [t_is] slightly deformed.\n"
		else
			msg += "<b>[t_He] [t_is] severely deformed.</b>\n"

	if(getBrainLoss() > 60)
		msg += "[t_He] seems to be clumsy and unable to think.\n"

	if(fire_stacks > 0)
		msg += "[t_He] [t_is] покрыт чем-то горючим.\n"
	if(fire_stacks < 0)
		msg += "[t_He] [t_is] выглядит немного мокро.\n"

	if(pulledby && pulledby.grab_state)
		msg += "[t_He] [t_is] restrained by [pulledby]'s grip.\n"

	msg += "</span>"

	if(!appears_dead)
		if(stat == UNCONSCIOUS)
			msg += "[t_He] похоже, не реагирует на что-либо, похоже, спит.\n"

		if(digitalcamo)
			msg += "[t_He] [t_is] moving [t_his] body in an unnatural and blatantly unsimian manner.\n"



	msg += "*---------*</span>"

	to_chat(user, msg)
