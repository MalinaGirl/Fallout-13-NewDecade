/client/verb/ooc(msg as text)
	set name = "OOC" //Gave this shit a shorter name so you only have to time out "ooc" rather than "ooc message" to use it --NeoFite
	set category = "OOC"

	if(say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'>Speech is currently admin-disabled.</span>")
		return

	if(!mob)
		return

	if(IsGuestKey(key))
		to_chat(src, "Guests may not use OOC.")
		return

	msg = copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN)
	var/raw_msg = msg

	if(!msg)
		return

	msg = emoji_parse(msg)

	if((copytext_char(msg, 1, 2) in list(".",";",":","#")) || (findtext_char(lowertext(copytext_char(msg, 1, 5)), "say")))
		if(alert("Your message \"[raw_msg]\" looks like it was meant for in game communication, say it in OOC?", "Meant for OOC?", "No", "Yes") != "Yes")
			return

	if(!(prefs.chat_toggles & CHAT_OOC))
		to_chat(src, "<span class='danger'>У вас мут на ООС.</span>")
		return

	if(!holder)
		if(!ooc_allowed)
			to_chat(src, "<span class='danger'>OOC замучен.</span>")
			return
		if(!dooc_allowed && (mob.stat == DEAD))
			to_chat(usr, "<span class='danger'>OOC for dead mobs has been turned off.</span>")
			return
		if(prefs.muted & MUTE_OOC)
			to_chat(src, "<span class='danger'>Вы не можете пользоваться OOC (мут).</span>")
			return
		if(src.mob)
			if(jobban_isbanned(src.mob, "OOC"))
				to_chat(src, "<span class='danger'>You have been banned from OOC.</span>")
				return
		if(handle_spam_prevention(msg,MUTE_OOC))
			return
		if(findtext_char(msg, "byond://"))
			to_chat(src, "<B>Advertising other servers is not allowed.</B>")
			log_admin("[key_name(src)] has attempted to advertise in OOC: [msg]")
			message_admins("[key_name_admin(src)] has attempted to advertise in OOC: [msg]")
			return

	log_ooc("[mob.name]/[key] : [raw_msg]")

	var/keyname = key
	if(prefs.unlock_content)
		if(prefs.toggles & MEMBER_PUBLIC)
			keyname = "<font color='[prefs.ooccolor ? prefs.ooccolor : normal_ooc_colour]'><img style='width:9px;height:9px;' class=icon src=\ref['icons/vault.dmi'] iconstate=boy[rand(1,8)]>[keyname]</font>"

	for(var/client/C in clients)
		if(C.prefs.chat_toggles & CHAT_OOC)
			if(holder)
				if(!holder.fakekey || C.holder)
					if(check_rights_for(src, R_ADMIN))
						to_chat(C, "<span class='adminooc'>[config.allow_admin_ooccolor && prefs.ooccolor ? "<font color=[prefs.ooccolor]>" :"" ]<span class='prefix'>Admin:</span> <EM>[keyname][holder.fakekey ? "/([holder.fakekey])" : ""]:</EM> <span class='message'>[msg]</span></span></font>")
					else
						to_chat(C, "<span class='adminobserverooc'><span class='prefix'>OOC:</span> <EM>[keyname][holder.fakekey ? "/([holder.fakekey])" : ""]:</EM> <span class='message'>[msg]</span></span>")
				else
					to_chat(C, "<font color='[normal_ooc_colour]'><span class='ooc'><span class='prefix'>OOC:</span> <EM>[holder.fakekey ? holder.fakekey : key]:</EM> <span class='message'>[msg]</span></span></font>")
			else if(!(key in C.prefs.ignoring))
				to_chat(C, "<font color='[normal_ooc_colour]'><span class='ooc'><span class='prefix'>OOC:</span> <EM>[keyname]:</EM> <span class='message'>[msg]</span></span></font>")

/client/verb/looc(msg as text)
	set name = "LOOC"
	set desc = "Local OOC, seen only by those in view."
	set category = "OOC"

	if(say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'>Speech is currently admin-disabled.</span>")
		return

	if(!mob)
		return

	if(IsGuestKey(key))
		to_chat(src, "Guests may not use OOC.")
		return

	msg = copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN)
	if(!msg)	return

	if(!holder)
		if(mob.stat == DEAD)
			to_chat(src, "<span class='danger'>You are not alive enough to use LOOC.</span>")
			return
		if(prefs.muted & MUTE_OOC)
			to_chat(src, "<span class='danger'>You cannot use OOC (muted).</span>")
			return
		if(jobban_isbanned(src, "OOC"))
			to_chat(src, "<span class='danger'>You have been banned from OOC.</span>")
			return
		if(handle_spam_prevention(msg,MUTE_OOC))
			return
		if(findtext_char(msg, "byond://"))
			to_chat(src, "<B>Advertising other servers is not allowed.</B>")
			log_admin("[key_name(src)] has attempted to advertise in OOC: [msg]")
			message_admins("[key_name_admin(src)] has attempted to advertise in OOC: [msg]")
			return

	log_ooc("(LOCAL) [mob.name]/[key] : [msg]")

	var/mob/source = mob.get_looc_source()

	var/display_name = key
	if(holder && holder.fakekey)
		display_name = holder.fakekey
	if(mob.stat != DEAD)
		display_name = mob.name

	var/turf/T = get_turf(source)
	var/list/listening = list()
	listening |= src	// We can always hear ourselves.
	var/list/listening_obj = list()
	var/list/eye_heard = list()

		// This is essentially a copy/paste from living/say() the purpose is to get mobs inside of objects without recursing through
		// the contents of every mob and object in get_mobs_or_objects_in_view() looking for PAI's inside of the contents of a bag inside the
		// contents of a mob inside the contents of a welded shut locker we essentially get a list of turfs and see if the mob is on one of them.

	if(T)
		var/list/hear = get_hearers_in_view(7,T)
		var/list/hearturfs = list()

		for(var/I in hear)
			if(ismob(I))
				var/mob/M = I
				listening |= M.client
				hearturfs += M.locs[1]
			else if(isobj(I))
				var/obj/O = I
				hearturfs |= O.locs[1]
				listening_obj |= O

		for(var/mob/M in player_list)
			if(isAI(M))
				var/mob/living/silicon/ai/A = M
				if(A.eyeobj && (A.eyeobj.locs[1] in hearturfs))
					eye_heard |= M.client
					listening |= M.client
					continue

			if(M.loc && M.locs[1] in hearturfs)
				listening |= M.client


	for(var/client/C in listening)
		if(C.prefs.toggles & CHAT_OOC)
			display_name = src.key
			if(holder)
				if(holder.fakekey)
					if(C.holder)
						display_name = "[holder.fakekey]/([src.key])"
					else
						display_name = holder.fakekey
			to_chat(C, "<font color='[normal_ooc_colour]'><span class='ooc'><span class='prefix'>LOOC:</span> <EM>[display_name]:</EM> <span class='message'>[msg]</span></span></font>")

/mob/proc/get_looc_source()
	return src


/proc/toggle_ooc(toggle = null)
	if(toggle != null) //if we're specifically en/disabling ooc
		if(toggle != ooc_allowed)
			ooc_allowed = toggle
		else
			return
	else //otherwise just toggle it
		ooc_allowed = !ooc_allowed
	to_chat(world, "<B>Отправлять сообщения в ООС [ooc_allowed ? "разрешено" : "запрещено"].</B>")

var/global/normal_ooc_colour = OOC_COLOR

/client/proc/set_ooc(newColor as color)
	set name = "Set Player OOC Color"
	set desc = "Modifies player OOC Color"
	set category = "Fun"
	normal_ooc_colour = sanitize_ooccolor(newColor)

/client/proc/reset_ooc()
	set name = "Reset Player OOC Color"
	set desc = "Returns player OOC Color to default"
	set category = "Fun"
	normal_ooc_colour = OOC_COLOR

/client/verb/colorooc()
	set name = "Set Your OOC Color"
	set category = "Preferences"

	if(!check_rights_for(src, R_ADMIN))
		return

	var/new_ooccolor = input(src, "Please select your OOC color.", "OOC color", prefs.ooccolor) as color|null
	if(new_ooccolor)
		prefs.ooccolor = sanitize_ooccolor(new_ooccolor)
		prefs.save_preferences()
	feedback_add_details("admin_verb","OC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/verb/resetcolorooc()
	set name = "Reset Your OOC Color"
	set desc = "Returns your OOC Color to default"
	set category = "Preferences"

	if(!check_rights_for(src, R_ADMIN))
		return

	prefs.ooccolor = initial(prefs.ooccolor)
	prefs.save_preferences()

//Checks admin notice
/client/verb/admin_notice()
	set name = "Adminnotice"
	set category = "Admin"
	set desc ="Check the admin notice if it has been set"

	if(admin_notice)
		to_chat(src, "<span class='boldnotice'>Admin Notice:</span>\n \t [admin_notice]")
	else
		to_chat(src, "<span class='notice'>There are no admin notices at the moment.</span>")

/client/verb/motd()
	set name = "MOTD"
	set category = "OOC"
	set desc ="Check the Message of the Day"

	if(join_motd)
		to_chat(src, "<div class=\"motd\">[join_motd]</div>")
	else
		to_chat(src, "<span class='notice'>The Message of the Day has not been set.</span>")

/client/proc/self_notes()
	set name = "View Admin Remarks"
	set category = "OOC"
	set desc = "View the notes that admins have written about you"

	if(!config.see_own_notes)
		to_chat(usr, "<span class='notice'>Sorry, that function is not enabled on this server.</span>")
		return

	show_note(usr.ckey, null, 1)