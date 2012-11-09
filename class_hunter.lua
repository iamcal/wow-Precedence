if select(2, UnitClass('player')) ~= "HUNTER" then return end

PREC.enable_for_class = true;

PREC.default_options.chimera_refresh_window = 4;
PREC.default_options.viper_mana_bigger = 90;
PREC.default_options.mana_low_warning = 10;

PREC.default_options.meters = {
	md_applied = true,
	md_cooldown = true,
	hunters_mark = true,
	serpent_sting = false,
	mend_pet = true,
	trap_set = true,
	trap_triggered = true,
};

PREC.default_options.warnings = {
	no_pet = true,
	bad_aspect = true,
	no_hunters_mark = true,
	hunter_weapon = true,
	low_ammo = true,
	growl_solo = true,
	growl_party = true,
	kirin_tor_ring = false,
	guild_cloak = false,	
};

PREC.rotations = {
	sv406 = {
		name = "SV 4.0.6",
		p1  = { which="rapid",		bind="ALT-1",	who = "boss" },
		p2  = { which="kill",		bind="ALT-2",	who = "any" },
		p3  = { which="explosive",	bind="ALT-3",	who = "any" },
		p4  = { which="black",		bind="ALT-4",	who = "any" }, --label = "Chim",
		p5  = { which="serpent",	bind="ALT-5",	who = "any" },
		p6  = { which="arcane_es",	bind="ALT-7",	who = "any" },
		p7  = { which="cobra",		bind="ALT-6",	who = "any" }, --cmd = "MACRO Steady",
		p8  = {},
		p9  = {},
		p10 = {},
		p11 = {},
		p12 = {},
	},
	mm406 = {
		name = "MM 4.0.6",
		p1 = { which="serpent",		bind="ALT-1",	who="any" },
		p2 = { which="chimerarefresh",	bind="ALT-2",	who="any" },
		p3 = { which="aimedmmm",	bind="ALT-3",	who="any" },
		p4 = { which="steadynoiss",	bind="ALT-4",	who="any" },
		p5 = { which="aimed",		bind="ALT-3",	who="any" },
		p6 = { which="kill",		bind="ALT-5",	who="any" },
		p7 = { which="rapid",		bind="ALT-6",	who="boss" },
		p8 = { which="readiness",	bind="ALT-7",	who="boss" },
		p9 = { which="steady",		bind="ALT-4",	who="any" },
		p10 = {},
		p11 = {},
		p12 = {},
	},
	{
		name = "SV 5.0.5",
		p1  = { which="black",		bind="ALT-4",	who="any" },
		p2  = { which="crows",		bind="",	who="boss",	label="7" },
		p3  = { which="dire_beast",	bind="",	who="any",	label="8" },
		p4  = { which="stampede",	bind="ALT-8",	who="boss" },
		p5  = { which="rapid",		bind="ALT-1",	who="boss" },
		p6  = { which="glaive_toss",	bind="",	who="any",	label="2" },
		p7  = { which="kill",		bind="ALT-2",	who="any" },
		p8  = { which="explosive",	bind="ALT-3",	who="any" },
		p9  = { which="readiness",	bind="",	who="boss",	label="5" },
		p10 = { which="serpent",	bind="ALT-5",	who="any" },
		p11 = { which="arcane_sv",	bind="ALT-7",	who="any" },
		p12 = { which="cobra",		bind="ALT-6",	who="any" },
	},
};

PREC.default_options.priorities = PREC.rotations.sv406;

PREC.abilities = {
	rapid = {
		icon = [[ability_hunter_runningshot]],
		spell = "Rapid Fire",
		buff = "Rapid Fire",
	},
	kill = {
		icon = [[ability_hunter_assassinate2]],
		spell = "Kill Shot",
	},
	serpent = {
		icon = [[ability_hunter_quickshot]],
		spell = "Serpent Sting",
		debuff = "Serpent Sting",
	},
	chimera = {
		icon = [[ability_hunter_chimerashot2]],
		spell = "Chimera Shot",
	},
	chimerarefresh = {
		icon = [[ability_hunter_chimerashot2]],
		spell = "Chimera Shot",
		chimerarefresh = true,
	},
	aimedmmm = {
		icon = [[inv_spear_07]],
		spell = "Aimed Shot",
		havebuff = "Fire!",
		label = "Aimed Shot (MMM Proc)",
	},
	aimed = {
		icon = [[inv_spear_07]],
		spell = "Aimed Shot",
	},
	trapfrost = {
		icon = [[spell_frost_freezingbreath.jpg]],
		spell = "Frost Trap",
	},
	readiness = {
		icon = "ability_hunter_readiness",
		spell = "Readiness",
		buff = "Rapid Fire",
	},
	steady = {
		icon = "ability_hunter_steadyshot",
		spell = "Steady Shot",
	},
	steadynoiss = {
		icon = "ability_hunter_steadyshot",
		spell = "Steady Shot",
		gainiss = true,
		label = "Steady Shot (No ISS)",
	},
	explosive = {
		icon = "ability_hunter_explosiveshot",
		spell = "Explosive Shot",
		--debuff = "Explosive Shot",
	},
	black = {
		icon = "spell_shadow_painspike",
		spell = "Black Arrow",
		debuff = "Black Arrow",
	},
	killcmd = {
		icon = [[ability_hunter_killcommand]],
		spell = "Kill Command",
	},
	cobra = {
		icon = "ability_hunter_cobrashot",
		spell = "Cobra Shot",
	},
	arcane = {
		icon = "ability_impalingbolt",
		spell = "Arcane Shot",
	},
	arcane_es = {
		icon = "ability_impalingbolt",
		spell = "Arcane Shot",
		label = "Arcane Shot (reserve Explosive)",
		between_es = true,
	},
	arcane_sv = {
		icon = "ability_impalingbolt",
		spell = "Arcane Shot",
		label = "Arcane Shot (reserve SV)",
	},
	dire_beast = {
		icon = "ability_hunter_sickem",
		spell = "Dire Beast",
	},
	crows = {
		icon = "ability_hunter_murderofcrows",
		spell = "A Murder of Crows",
		debuff = "A Murder of Crows",
	},
	stampede = {
		icon = "ability_hunter_bestialdiscipline",
		spell = "Stampede",
	},
	glaive_toss = {
		icon = "ability_glaivetoss",
		spell = "Glaive Toss",
	},
	
};

PREC.meterinfo = {
	md_applied = {
		title = "Misdirect Active",
		icon = "ability_hunter_misdirection",
		buff = "Misdirection",
		color = "green",
		special_label = "md_target",
	},
	md_cooldown = {
		title = "Misdirect Cooldown",
		icon = "ability_hunter_misdirection",
		spell = "Misdirection",
		color = "red",
		label = "Cooldown",
	},
	hunters_mark = {
		icon = "ability_hunter_snipershot",
		debuff = "Hunter's Mark",
		color = "green",
	},
	serpent_sting = {
		icon = "ability_hunter_quickshot",
		debuff = "Serpent Sting",
		color = "green",
	},
	mend_pet = {
		icon = "ability_hunter_mendpet",
		petbuff = "Mend Pet",
		color = "green",
	},
	trap_set = {
		title = "Freeze Trap Set",
		color = "green",
	},
	trap_triggered = {
		title = "Freeze Trap Triggered",
		color = "green",
	},
}

PREC.warningdefs = {
	no_pet = {
		title = "Missing Pet",
		icon = [[Interface\Icons\inv_box_petcarrier_01]],
	},
	bad_aspect = {
		title = "Wrong Aspect",
		icon = [[Interface\Icons\spell_nature_ravenform]],
	},
	no_hunters_mark = {
		title = "Missing Hunter's Mark",
		icon = [[Interface\Icons\ability_hunter_snipershot]],
	},
	growl_solo = {
		title = "Growl Disabled When Solo",
		icon = [[Interface\Icons\ability_physical_taunt]],
	},
	growl_party = {
		title = "Growl Enabled In Party",
		icon = [[Interface\Icons\ability_physical_taunt]],
	},
	hunter_weapon = {
		title = "Non-Ranged Weapon Equipped",
		icon = [[Interface\Icons\inv_misc_ammo_arrow_04]],
	},
};

PREC.state = {
	md_target = "?",
	trap_set = false,
	trap_set_start = 0,
	trapped_mobs = {},
	no_shots_until = 0,
	no_explosive_until = 0,
	no_dire_beast_until = 0,
	simulate_focus_loss = 0,
	simulate_focus_loss_until = 0,
	steady_shots_accum = 0,
};

function PREC.OnCombatLog(...)

	local ts, event, hideCaster, sourceGuid, sourceName, sourceFlags, sourceFlags2, destGuid, destName, destFlags, destFlasg2, spellId, spellName, spellSchool = ...;

	local srcUs = false;
	local ourGuid = UnitGUID("player");
	if (sourceGuid == ourGuid) then srcUs = true; end

	if (srcUs and event == "SPELL_CAST_SUCCESS" and spellName == "Misdirection") then
		PREC.state.md_target = destName;
	end

	if ((event == "SPELL_CREATE") and (srcUs) and ((spellName == "Freezing Arrow") or (spellName == "Freezing Trap"))) then
		PREC.state.trap_set = true;
		PREC.state.trap_set_start = GetTime();
		if (spellName == "Freezing Trap") then PREC.meterinfo.trap_set.icon = "spell_frost_chainsofice"; end
		if (spellName == "Freezing Arrow") then PREC.meterinfo.trap_set.icon = "spell_frost_chillingbolt"; end
		return;
	end

	if ((event == "SPELL_MISSED") and srcUs and ((spellName == "Freezing Arrow Effect") or (spellName == "Freezing Trap Effect"))) then
		PREC.state.trap_set = false;
	end

	if ((event == "SPELL_AURA_APPLIED") and srcUs and ((spellName == "Freezing Arrow Effect") or (spellName == "Freezing Trap Effect"))) then

		PREC.state.trap_set = false;
		PREC.state.trapped_mobs[destGuid] = {
			start = GetTime(),
			aura = spellName,
			guid = destGuid,
			name = destName,
		};
		return;
	end

	if ((event == "SPELL_AURA_REMOVED") and srcUs and ((spellName == "Freezing Arrow Effect") or (spellName == "Freezing Trap Effect"))) then

		PREC.state.trapped_mobs[destGuid] = nil;
		return;
	end

	if (false) then
		local dest = destName;
		if (not dest) then dest = "?"; end
		local src = sourceName;
		if (not src) then src = "?"; end
		local spell = spellName;
		if (not spell) then spell = "?"; end

		print(string.format("%s (%s -> %s) %s", event, src, dest, spell));
	end
end

function PREC.OnSpellCastSent(...)

	local unit, spell, rank, target = ...;

	if (unit == "player") then
		if (spell == "Steady Shot") then
			PREC.state.steady_shots_accum = PREC.state.steady_shots_accum + 1;
		else
			PREC.state.steady_shots_accum = 0;
		end
	end

	if (unit == "player" and spell == "Cobra Shot") then
		local _, _, _, _, _, _, castTime = GetSpellInfo("Cobra Shot")
		PREC.state.no_shots_until = GetTime() + (castTime / 1000);
		return;
	end

	if (unit == "player" and spell == "Steady Shot") then
		local _, _, _, _, _, _, castTime = GetSpellInfo("Steady Shot")
		PREC.state.no_shots_until = GetTime() + (castTime / 1000);
		return;
	end

	if (unit == "player" and spell == "Aimed Shot") then
		local test = PREC.TimeToPlayerBuffExpires("Fire!", false);
		if (test == -1) then
			local _, _, _, cost, _, _, castTime = GetSpellInfo("Aimed Shot")

			local cast_ends = GetTime() + (castTime / 1000);

			PREC.state.no_shots_until = cast_ends;
			PREC.state.simulate_focus_loss_until = cast_ends;
			PREC.state.simulate_focus_loss = cost;
		end
		return;
	end

	if (unit == "player" and spell == "Explosive Shot") then
		--PREC.state.no_explosive_until = GetTime() + 2;
		return;
	end

	if (unit == "player" and spell == "Dire Beast") then
		PREC.state.no_dire_beast_until = GetTime() + 15;
		return;
	end
end

function PREC.GetWarningLabel(ret)

	ret.show_label = false;


	--
	-- range warning
	--

	local inShotRange = IsSpellInRange("Auto Shot");
	local inMeleeRange = IsSpellInRange("Wing Clip");

	if ((ret.active_shots > 0) and ret.has_viable_target) then

		if (not (inShotRange == 1)) then
			if (inMeleeRange == 1) then

				ret.show_label = true;
				ret.label = 'Too Close';
				ret.label_mode = 'warning';
				return;
			else
				ret.show_label = true;
				ret.label = 'Too Far';
				ret.label_mode = 'warning';
				return;
			end
		end
	end


	--
	-- focus warning
	--

	local cur_focus = UnitPower("player", 2);
	local max_focus = UnitPowerMax("player", 2);
	local focus_percent = 100 * cur_focus / max_focus;

	if (focus_percent < 10) then

		ret.show_label = true;
		ret.label = string.format('Low Focus (%d%%)', focus_percent);
		ret.label_mode = 'mana';
		return;
	end

	if (focus_percent > 80 and focus_percent < 100) then

		ret.show_label = true;
		ret.label = 'High Focus';
		ret.label_mode = 'mana';
		return;
	end
end

--
-- ################################################## Warnings ##################################################
--

function PREC.warningdefs.no_pet.func(info)

	if (IsMounted()) then return info; end
	if (UnitGUID("pet")) then
		if (UnitHealth("pet") == 0) then
			info.show = true;
			return info;
		end
		return info;
	end
	info.show = true;
	return info;
end

function PREC.warningdefs.bad_aspect.func(info)

	local bad_icon = nil;
	local found_hawk = false;

	local index = 1
	while UnitBuff("player", index) do
		local name, _, _, count, _, _, buffExpires, caster = UnitBuff("player", index)
		if (name == "Aspect of the Cheetah"	) then bad_icon = "ability_mount_jungletiger"; end
		if (name == "Aspect of the Fox"		) then bad_icon = "ability_hunter_aspectofthefox"; end
		if (name == "Aspect of the Pack"	) then bad_icon = "ability_mount_whitetiger"; end
		if (name == "Aspect of the Wild"	) then bad_icon = "spell_nature_protectionformnature"; end
		if (name == "Aspect of the Hawk"	) then found_hawk = true; end
		if (name == "Aspect of the Iron Hawk"	) then found_hawk = true; end
		index = index + 1
	end

	if (bad_icon) then
		info.show = true;
		info.icon = [[Interface\Icons\]] .. bad_icon;
		info.scale = 1;
	else
		if (not found_hawk) then
			info.show = true;
			info.icon = [[Interface\Icons\spell_nature_ravenform]];
		end
	end
	return info;
end

function PREC.warningdefs.no_hunters_mark.func(info)

	if (PREC.HasViableTarget()) then

		local temp = PREC.CheckBuff(UnitDebuff, "Hunter's Mark", "target", false);
		if (temp.t == 0) then
			info.show = true;
		end
	end
end

function PREC.warningdefs.growl_solo.func(info)

	if (IsMounted()) then return info; end
	if (not UnitGUID("pet")) then return info; end
	if (UnitHealth("pet") == 0) then return info; end

	local _, autostate = GetSpellAutocast("Growl", "pet");
	if (not autostate and not PREC.InGroup()) then
		info.show = true;
	end
end

function PREC.warningdefs.growl_party.func(info)

	if (IsMounted()) then return info; end
	if (not UnitGUID("pet")) then return info; end
	if (UnitHealth("pet") == 0) then return info; end

	local _, autostate = GetSpellAutocast("Growl", "pet");
	if (autostate and PREC.InGroup()) then
		info.show = true;
	end
end

function PREC.warningdefs.hunter_weapon.func(info)

	local itemId = GetInventoryItemID("player", 16);

	if (not itemId) then return info; end

	local _, _, _, level, _, type, subtype = GetItemInfo(itemId);

	if (level) then
		if (level < 200) then info.show = true; end
	end

	if (type == "Weapon" and subtype == "Bows"		) then return info; end
	if (type == "Weapon" and subtype == "Crossbows"		) then return info; end
	if (type == "Weapon" and subtype == "Guns"		) then return info; end

	info.show = true;
end

--
-- ################################################## Meters ##################################################
--

function PREC.meterinfo.trap_set.func(info)

	if (PREC.state.trap_set) then

		local duration = GetTime() - PREC.state.trap_set_start;
		local max = 30;

		if (duration > max) then
			PREC.state.trap_set = false;
		else
			info.max = max;
			info.t = max - duration;
		end
	end
end

function PREC.meterinfo.trap_triggered.func(info)

	info.multi = {};

	local guid, details;
	for guid, details in pairs(PREC.state.trapped_mobs) do

		local info2 = PREC.CopyTable(info);
		local duration = GetTime() - details.start;
		local max = 20;

		if (duration > max) then
			info2.t = 0.1;
			info2.max = max;
		else
			info2.max = max;
			info2.t = max - duration;
		end		

		info2.label = details.name;

		if (details.aura == "Freezing Trap Effect") then info2.icon = "spell_frost_chainsofice"; end
		if (details.aura == "Freezing Arrow Effect") then info2.icon = "spell_frost_chillingbolt"; end

		info.multi[guid] = info2;
	end
end

--
-- ################################################## Shots ##################################################
--

function PREC.abilities.explosive.func(t, now, waitmana)

	if (PREC.state.no_explosive_until > now) then
		local ex_min = PREC.state.no_explosive_until - now;
		if (t < ex_min) then
			t = ex_min;
		end		
	end

	return {
		t = t,
		waitmana = waitmana,
	};
end

function PREC.abilities.dire_beast.func(t, now, waitmana)

	if (PREC.state.no_dire_beast_until > now) then
		local db_min = PREC.state.no_dire_beast_until - now;
		if (t < db_min) then
			t = db_min;
		end		
	end

	return {
		t = t,
		waitmana = waitmana,
	};
end

function PREC.abilities.arcane_sv.func(t, now, waitmana)

	-- perform this check for every ability listed below that
	-- is coming up and is higher in the priority list than
	-- this ability (easy because PREC.current_shots is built
	-- from highest priority upwards)
	--
	-- queue up arcane shot only if:
	-- 	current focus
	-- 	+ cost of arcane shot
	-- 	+ regen until high-priority-shot cooldown
	-- is more than:
	-- 	high-priority-shot cost


	--
	-- calculate arcane shot cost/cooldown
	--

	local _, _, _, shot_cost = GetSpellInfo("Arcane Shot");
	local shot_start, shot_dur = GetSpellCooldown("Arcane Shot");
	local regen_base, regen_cast = GetPowerRegen();

	local now = GetTime();
	local cur_focus = UnitPower("player");

	local shot_cooldown = 0;
	if (shot_start > 0 and shot_dur > 0) then
		shot_cooldown = shot_start + shot_dur - now;
	end


	--
	-- create a map of shots ahead of this one in the rotation
	-- (if they are marked as .ok, which filters out boss shots, etc)
	--

	local higher_shots = {};
	local i;
	local v;

	for i,v in pairs(PREC.current_shots) do

		local ability = PREC.abilities[i];
		if (ability and v.ok) then
			higher_shots[ability.spell] = v;
		end
	end


	--
	-- perform wait/focus check for each high-priority shot
	--

	local reserve_shots = {
		"Explosive Shot",
		"Black Arrow",
		"A Murder of Crows",
		"Glaive Toss",
		"Serpent Sting"
	};

	local i;
	local v;
	for i,v in ipairs(reserve_shots) do

		if (higher_shots[v]) then

			local _, _, _, ss_cost = GetSpellInfo(v);
			local ss_cooldown = higher_shots[v].t;

			-- if shot is going to happen within the next GCD, 
			-- or within GCD after this shot, ignore this shot
			if (ss_cooldown - shot_cooldown <= 1.5) then

				--PREC.debug_data = v.." is soon";
				return {
					hide_now = true,
				};
			end

			local total_focus = cur_focus + (ss_cooldown * regen_cast) - shot_cost;

			--PREC.debug_data = string.format("%f, %f", regen_cast, total_focus);

			if (total_focus < ss_cost) then

				--PREC.debug_data = v.." needs focus";
				return {
					hide_now = true,
				};
			end
		end
	end

	return {
		t = t,
		waitmana = waitmana,
	};
end

