import <zlib.ash>;

setvar("acquireBuff_last_update", "");
setvar("acquireBuff_max_price", "1000");
setvar("acquireBuff_wait_time", "30");
setvar("acquireBuff_ignore_philanthropic", "false");

boolean [effect, int, int, string] buffs;

boolean[string] online;

string data_filename()
{
	return "acquireBuff_data_" + my_name() + ".txt";
}

int[effect] all_songs()
{
	int[effect] songs;
	int total = 0;
	for skill_num from 6001 to 6040
	{
		if(skill_num.to_skill() != $skill[none] && skill_num != 6025)
		{
			songs[skill_num.to_skill().to_string().replace_string("The ", "").to_effect()] = total;
			total = total + 1;
		}
	}
	return songs;
}

int[effect] current_songs()
{
	int[effect] all_songs = all_songs();
	int[effect] songs;
	int total = 0;
	foreach e in all_songs
	{
		if(e.have_effect() > 0)
		{
			songs[e] = total;
			total = total + 1;
		}
	}
	return songs;
}

void gather_data()
{
	record buffbot {
		int id;
		string xml;
	};
	buffbot [string] buffbots;
	file_to_map("data/buffbots.txt", buffbots);
	foreach i in buffbots
	{
		online[i] = is_online(i);
	}

	if (getvar("acquireBuff_last_update") == today_to_string())
	{
		file_to_map(data_filename(), buffs);
		return;
	}
	
	vprint("Refreshing buffbot data...", 2);
	foreach i in buffbots
	{
		vprint(i + ": loading " + buffbots[i].xml + "...", 4);
		string page = visit_url(buffbots[i].xml).to_lower_case();
		
		if (length(page) != 0 && page.contains_text("<botdata>"))
		{
			page = replace_string(page, "\t", "");
			page = replace_string(page, "\n", "");
			page = replace_string(page, ",", "");
			
			page = replace_string(page, "", "");
			page = replace_string(page, ">the ", ">");
			page = replace_string(page, "empathy of the newt", "empathy");
			page = replace_string(page, excise(page, "jalape", "o"), "&ntilde;");
			page = replace_string(page, excise(page, "jaba", "ero"), "&ntilde;");
			page = replace_string(page, "jingle bells", "jingle jangle jingle");
			
			while(true)
			{
				string buffdata = excise(page, "<buffdata>", "</buffdata>");
				if (length(buffdata) == 0)
				{
					break;
				}

				effect name = excise(buffdata, "<name>", "</name>").to_effect();

				int price = excise(buffdata, "<price>", "</price>").to_int();
				int turns = excise(buffdata, "<turns>", "</turns>").to_int();
				
				buffs[name, price, turns, i] = false;

				// Ignore philanthropic buffs
				boolean philanthropic = excise(buffdata, "<philanthropic>", "</philanthropic>").to_boolean();
				if (getvar("acquireBuff_ignore_philanthropic").to_boolean() == true && philanthropic == true)
				{
					buffs[name, price, turns, i] = true;
				}
				
				
				page = replace_string(page, "<buffdata>" + buffdata + "</buffdata>", "");
			}
		}
		else
		{
			vprint(buffbots[i].xml + " is not a valid bot data file", "red", 4);
		}
	}
	vprint("Buffbot data refreshed.", 2);
	
	map_to_file(buffs, data_filename());
	vars["acquireBuff_last_update"] = today_to_string();
	updatevars();

	if (getvar("verbosity").to_int() >= 8)
	{
		foreach e, p, t, n in buffs
		{
			vprint(n + " - " + e.to_string() + " - " + p.to_string() + " - " + t.to_string(), 8);
		}
	}
}

boolean try_acquire_buff(effect ef)
{
	if (!can_interact())
	{
		return false;
	}

	int max_songs = 3 + boolean_modifier("additional song").to_int() + boolean_modifier("four songs").to_int();

	if (all_songs() contains ef)
	{
		if (current_songs().count() >= max_songs && !(current_songs() contains ef))
		{
			vprint("Selected target has the maximum number of AT buffs already.", "red", 2);
			return false;
		}
	}

	if (buffs contains ef)
	{
		foreach e, p, t, n in buffs
		{
			if (e == ef && buffs[e, p, t, n] == false && p <= getvar("acquireBuff_max_price").to_int() && online[n])
			{
				buffs[e, p, t, n] = true;
				map_to_file(buffs, data_filename());
				online[n] = false;
				vprint("Sending kmail to " + n + " for " + p + "meat", "blue", 2);
				kmail(n, "", p);
				return true;
			}
		}
	}
	else
	{
		vprint("No known buffbot is able to provide " + ef.to_string(), "red", 2);
	}
	
	return false;
}

boolean acquireBuff(effect e)
{
	gather_data();

	int turns_remaining = have_effect(e);
	while(have_effect(e) == turns_remaining)
	{
		if (!try_acquire_buff(e))
		{
			vprint("Unable to acquire " + e.to_string(), "red", 2);
			return false;
		}
		
		wait(getvar("acquireBuff_wait_time").to_int());
		cli_execute("refresh effects");
	}
	
	vprint(e.to_string() + " acquired!", "green", 2);
	return true;
}

void main(effect e)
{
	acquireBuff(e);
}
