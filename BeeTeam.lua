BT = {}

BT.options = {
	runway = 200,
	time_limit = 10,
	font_size = 10,
	cooldown_size = 20,
	max_prios = 10,
	max_mtrs = 10,
	mtr_icon_size = 20,
};

BT.priorities = {
	p1 = {
		which = "rapid",
		bind = "ALT-1",
		who = "boss",
	},
	p2 = {
		which = "readiness",
		bind = "ALT-7",
		waitbuff = "Rapid Fire",
		who = "boss",
	},
	p3 = {
		which = "kill",
		bind = "ALT-2",
		who = "any",
	},
	p4 = {
		which = "serpent",
		bind = "ALT-3",
		who = "any",
	},
	p5 = {
		which = "chimera",
		bind = "ALT-4",
		--label = "Chim",
		who = "any",
	},
	p6 = {
		which = "aimed",
		bind = "ALT-5",
		who = "any",
	},
	p7 = {
		which = "steady",
		bind = "ALT-6",
		who = "any",
		cmd = "MACRO Steady",
	},
	p8 = {
		which = "trap_frost",
		bind = "ALT-8",
		who = "any",
	},
	p9 = "-",
	p10 = "-",
};

BT.meters = {
	m1 = "misdirect",
	m2 = "hunters_mark",
	m3 = "serpent_sting",
	m4 = "mend_pet",
	m5 = "-",
	m6 = "-",
	m7 = "-",
	m8 = "-",
	m9 = "-",
	m10 = "-",
};

BT.abilities = {
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
	aimed = {
		icon = [[inv_spear_07]],
		spell = "Aimed Shot",
	},
	trap_frost = {
		icon = [[spell_frost_freezingbreath.jpg]],
		spell = "Frost Trap",
	},
	readiness = {
		icon = "ability_hunter_readiness",
		spell = "Readiness",
	},
	steady = {
		icon = "ability_hunter_steadyshot",
		spell = "Steady Shot",
	},
}

BT.meterinfo = {
	misdirect = {
		icon = "ability_hunter_misdirection",
		phase1 = {
			buff = "Misdirection",
			color = "green",
			special_label = "md_target",
		},
		phase2 = {
			spell = "Misdirection",
			color = "red",
			label = "Cooldown",
		},
	},
	hunters_mark = {
		icon = "ability_hunter_snipershot",
		phase1 = {
			debuff = "Hunter's Mark",
			color = "green",
		},
	},
	serpent_sting = {
		icon = "ability_hunter_quickshot",
		phase1 = {
			debuff = "Serpent Sting",
			color = "green",
		},
	},
	mend_pet = {
		icon = "ability_hunter_mendpet",
		phase1 = {
			petbuff = "Mend Pet",
			color = "green",
		},
	},
}

BT.specials = {
	md_target = "?",
};


function BT.OnLoad()

end

function BT.OnReady()

	_G.BeeTeamDB = _G.BeeTeamDB or {};
	_G.BeeTeamDB.opts = _G.BeeTeamDB.opts or {};

	BTOptionsFrame.name = 'Bee Team';
	InterfaceOptions_AddCategory(BTOptionsFrame);

	BT.fullW = 40 + 40 + BT.options.runway;
	BT.fullH = 40;

	BT.StartFrame();
end

function BT.ShowOptions()

	InterfaceOptionsFrame_OpenToCategory(BTOptionsFrame.name);
end

function BT.OptionClick(button, name)

	if (name == 'hide') then
		BT.ToggleHide();
	end

	if (name == 'lock') then
		BT.ToggleLock();
	end

end


function BT.OnSaving()

	local point, relativeTo, relativePoint, xOfs, yOfs = BT.UIFrame:GetPoint()
	_G.BeeTeamDB.opts.frameRef = relativePoint;
	_G.BeeTeamDB.opts.frameX = xOfs;
	_G.BeeTeamDB.opts.frameY = yOfs;
end


function BT.OnEvent(frame, event, ...)

	if (event == 'COMBAT_LOG_EVENT_UNFILTERED') then
		local timestamp, type, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags = select(1, ...)
		if (type == "SPELL_CAST_SUCCESS") then
			local spellId, spellName, spellSchool = select(9, ...);
			if (spellName == "Misdirection") then
				BT.specials.md_target = destName;
			end
		end
		return;
	end


	if (event == 'ADDON_LOADED') then
		local name = ...;
		if name == 'BeeTeam' then
			BT.OnReady();
		end
	end

	if (event == 'PLAYER_LOGIN') then

		BT.BindKeys();
	end

	if (event == 'PLAYER_LOGOUT') then

		BT.OnSaving();
	end

end

function BT.OnDragStart(frame)
	if (_G.BeeTeamDB.opts.locked) then
		return;
	end
	BT.UIFrame:StartMoving();
	BT.UIFrame.isMoving = true;
	GameTooltip:Hide()
end

function BT.OnDragStop(frame)
	BT.UIFrame:StopMovingOrSizing();
	BT.UIFrame.isMoving = false;
end

function BT.OnClick(self, aButton)
	if (aButton == "RightButton") then
		BT.ShowMenu();
	end
end

function BT.StartFrame()

	BT.UIFrame = CreateFrame("Frame",nil,UIParent);
	BT.UIFrame:SetFrameStrata("BACKGROUND")
	BT.UIFrame:SetWidth(BT.fullW)
	BT.UIFrame:SetHeight(BT.fullH)

	BT.UIFrame.texture = BT.UIFrame:CreateTexture()
	BT.UIFrame.texture:SetAllPoints(BT.UIFrame)
	BT.UIFrame.texture:SetTexture(0, 0, 0)

	-- position the parent frame
	local frameRef = "CENTER";
	local frameX = 0;
	local frameY = 0;
	if (_G.BeeTeamDB.opts.frameRef) then
		frameRef = _G.BeeTeamDB.opts.frameRef;
		frameX = _G.BeeTeamDB.opts.frameX;
		frameY = _G.BeeTeamDB.opts.frameY;
	end
	BT.UIFrame:SetPoint(frameRef, frameX, frameY);

	-- make it draggable
	BT.UIFrame:SetMovable(true);
	BT.UIFrame:EnableMouse(true);

	-- some text
	BT.Label = BT.UIFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	BT.Label:SetPoint("CENTER", BT.UIFrame, "CENTER", 2, 0)
	BT.Label:SetJustifyH("LEFT")
	BT.Label:SetText(" "); -- Good place to put debug text
	BT.Label:SetTextColor(1,1,1,1)
	BT.SetFontSize(BT.Label, 10)

	-- buttons!
	BT.rot_btns = {};
	for i=1,BT.options.max_prios do
		local key = 'p'..i;
		BT.rot_btns[key] = BT.CreateButton(0, 0, 40, 40, [[Interface\Icons\ability_hunter_pet_dragonhawk]]);
		BT.rot_btns[key]:SetFrameLevel(1 + BT.options.max_prios - i);
	end

	-- progress meters
	BT.mtrs = {};
	for i=1,BT.options.max_mtrs do
		local key = 'm'..i;
		BT.mtrs[key] = {
			btn = BT.CreateButton(0, 40 + ((i-1) * BT.options.mtr_icon_size), BT.options.mtr_icon_size, BT.options.mtr_icon_size, [[Interface\Icons\ability_hunter_pet_dragonhawk]]),
			bar = BT.CreateBar(BT.options.mtr_icon_size, 40 + ((i-1) * BT.options.mtr_icon_size), BT.fullW-BT.options.mtr_icon_size, BT.options.mtr_icon_size),
		};
	end


	-- create a button that covers the entire addon
	BT.Cover = CreateFrame("Button", "foo", BT.UIFrame);
	BT.Cover:SetFrameStrata("HIGH")
	BT.Cover:SetPoint("TOPLEFT", 0, 0)
	BT.Cover:SetWidth(BT.fullW)
	BT.Cover:SetHeight(BT.fullH)
	BT.Cover:EnableMouse(true);
	BT.Cover:RegisterForClicks("AnyUp");
	BT.Cover:RegisterForDrag("LeftButton");
	BT.Cover:SetScript("OnDragStart", BT.OnDragStart);
	BT.Cover:SetScript("OnDragStop", BT.OnDragStop);
	BT.Cover:SetScript("OnClick", BT.OnClick);

	--BT.Cover.texture = BT.Cover:CreateTexture("ARTWORK")
	--BT.Cover.texture:SetAllPoints()
	--BT.Cover.texture:SetTexture(1, 0.5, 0)
	--BT.Cover.texture:SetAlpha(0.5);



	BT.SetLocked(_G.BeeTeamDB.opts.locked);
	BT.SetHide(_G.BeeTeamDB.opts.hide);
end

function BT.ShowMenu()

	local menu_frame = CreateFrame("Frame", "menuFrame", UIParent, "UIDropDownMenuTemplate")

	local menuList = {};
	local first = true;

	table.insert(menuList, {
		text = "Options",
		func = function() BT.ShowOptions() end,
		isTitle = false,
		checked = false,
		disabled = false,
	});

	local locked = false;
	if (_G.BeeTeamDB.opts.locked) then locked = true; end

	table.insert(menuList, {
		text = "Lock Frame",
		func = function() BT.ToggleLock() end,
		isTitle = false,
		checked = locked,
		disabled = false,
	});

	table.insert(menuList, {
		text = "Hide Window",
		func = function() BT.SetHide(true) end,
		isTitle = false,
		checked = false,
		disabled = false,
	});

	EasyMenu(menuList, menu_frame, "cursor", 0 , 0, "MENU")

end

function BT.CreateButton(x, y, w, h, texture)

	local b = CreateFrame("Button", nil, BT.UIFrame);
	b:SetPoint("TOPLEFT", x, 0-y)
	b:SetWidth(w)
	b:SetHeight(h)
	b:SetNormalTexture(texture);

	b.label = b:CreateFontString(nil, "OVERLAY");
	b.label:Show()
	b.label:ClearAllPoints()
	b.label:SetTextColor(1, 1, 1, 1);
	b.label:SetFont([[Fonts\FRIZQT__.TTF]], 12, "OUTLINE");
	b.label:SetPoint("CENTER", b, "CENTER", 0, 0);
	b.label:SetText(" ");

	return b;
end

function BT.CreateBar(x, y, w, h)

	local b = CreateFrame("StatusBar", nil, BT.UIFrame)
	b:SetPoint("TOPLEFT", x, 0-y);
	b:SetWidth(w);
	b:SetHeight(h);
	b:SetMinMaxValues(0, 100);
	b:SetValue(100);
	b:SetOrientation("HORIZONTAL");
	b:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]], "ARTWORK");
	b:SetStatusBarColor(0, 1, 0);

	b.label = b:CreateFontString(nil, "OVERLAY");
	b.label:Show()
	b.label:ClearAllPoints()
	b.label:SetTextColor(1, 1, 1, 1);
	b.label:SetFont([[Fonts\FRIZQT__.TTF]], 12, "OUTLINE");
	b.label:SetPoint("LEFT", b, "LEFT", 0, 0);
	b.label:SetText(" ");

	return b;
end

function BT.RebuildFrame()

	for i=1,BT.options.max_prios do
		local key = 'p'..i;
		local ability = BT.abilities[BT.priorities[key].which];
		if (ability) then
			BT.rot_btns[key]:SetNormalTexture([[Interface\Icons\]] .. ability.icon);
		else
			BT.rot_btns[key]:SetNormalTexture([[Interface\Icons\ability_hunter_pet_dragonhawk]]);
		end
	end
end

function BT.BindKeys()

	local set = GetCurrentBindingSet();

	for i=1,BT.options.max_prios do
		local key = 'p'..i;
		local prio = BT.priorities[key];
		local ability = BT.abilities[prio.which];

		if (ability and prio and prio.bind) then

			local cmd = nil;

			if (ability.spell) then
				cmd = "SPELL "..ability.spell;
			end
			if (ability.cmd) then
				cmd = ability.cmd;
			end
			if (prio.cmd) then
				cmd = prio.cmd;
			end

			local ok = SetBinding(prio.bind, cmd, set);
			-- TODO: report error if we can't bind...
		end
	end
end

function BT.UpdateFrame()

	local count_past_limit = 0;
	local done_at_limit = 0;
	local done_at_rdy = 0;
	local btns_at_limit = {};

	local can_attack = UnitCanAttack("player", "target");
	if (can_attack and UnitIsDeadOrGhost("target")) then
		can_attack = false;
	end

	for i=1,BT.options.max_prios do
		local key = 'p'..i;
		local prio = BT.priorities[key];
		local ability = BT.abilities[prio.which];
		local ok, t = false, 0;
		if (ability) then
			ok, t = BT.GetStatus(ability, prio);
		end
		if (not (prio.who == "any")) then
			ok = BT.CheckWho(prio.who);
		end

		if (ok) then

			if (t > BT.options.time_limit) then
				done_at_limit = done_at_limit + 1;
				BT.rot_btns[key].label:SetText(string.format("%d", t));
				table.insert(btns_at_limit, BT.rot_btns[key]);
			else
				local x = BT.options.runway * t / BT.options.time_limit;
				local y = 0;

				if (x < 40) then
					y = done_at_rdy * 10;
					done_at_rdy = done_at_rdy + 1;
				end

				local label = " ";
				if (prio.bind) then label = prio.bind; end
				if (prio.label) then label = prio.label; end

				BT.rot_btns[key]:SetWidth(40);
				BT.rot_btns[key]:SetHeight(40);
				BT.rot_btns[key]:SetPoint("TOPLEFT", x, y);

				BT.SetFontSize(BT.rot_btns[key].label, BT.options.font_size);
				BT.rot_btns[key].label:SetText(label);
			end
		
			BT.rot_btns[key]:Show();
		else
			BT.rot_btns[key]:Hide();
		end

		if (can_attack) then

			BT.rot_btns[key]:SetAlpha(1);
		else
			BT.rot_btns[key]:SetAlpha(0.5);
		end
	end


	if (can_attack) then
		--BT.UIFrame:SetAlpha(1);
	else
		--BT.UIFrame:SetAlpha(0.5);
	end
	

	if (done_at_limit > 0) then

		local limit_size = 1;

		if (done_at_limit > 1) then limit_size = 2; end
		if (done_at_limit > 4) then limit_size = 3; end
		if (done_at_limit > 9) then limit_size = 4; end

		local icon_size = 40 / limit_size;
		local font_size = BT.options.cooldown_size / limit_size;
		local x = 0;
		local y = 0;

		for _, btn in pairs(btns_at_limit) do

			local x_pos = x * icon_size;
			local y_pos = y * icon_size;

			btn:SetPoint("TOPLEFT", BT.options.runway+40+x_pos, 0-y_pos);
			btn:SetWidth(icon_size)
			btn:SetHeight(icon_size)
			BT.SetFontSize(btn.label, font_size);

			x = x + 1;
			if (x == limit_size) then
				y = y + 1;
				x = 0;
			end
		end
	end

	--BT.Label:SetText(string.format("%0.2f, %0.2f", t1, t2))

	--
	-- start of meters
	--

	local show_mtrs = {};

	for i=1,BT.options.max_mtrs do
		local key = 'm'..i;

		local info = BT.meterinfo[BT.meters[key]];
		if (info) then
			local t, max, phase = BT.GetMeter(info.phase1);
			if (t == 0) then
				t, max, phase = BT.GetMeter(info.phase2);
			end
			if (max > 2) then
				table.insert(show_mtrs, {
					t = t,
					max = max,
					phase = phase,
					info = info,
				});
			end
		end
	end

	table.sort(show_mtrs, function(a,b) return a.max<b.max end);

	local use_idx = 1;

	for _,mtr in pairs(show_mtrs) do

		local key = 'm'..use_idx;
		use_idx = use_idx + 1;

		local label = BT.FormatTime(mtr.t);
		if (mtr.phase.label) then
			label = label .. " - " .. mtr.phase.label;
		end
		if (mtr.phase.special_label) then
			label = label .. " - " .. BT.specials[mtr.phase.special_label];
		end

		BT.mtrs[key].btn:SetNormalTexture([[Interface\Icons\]] .. mtr.info.icon);
		BT.mtrs[key].bar.label:SetText(label);
		BT.mtrs[key].bar:SetMinMaxValues(0, mtr.max);
		BT.mtrs[key].bar:SetValue(mtr.t);

		BT.mtrs[key].bar:SetStatusBarColor(1, 1, 1);
		if (mtr.phase.color == "green") then 	BT.mtrs[key].bar:SetStatusBarColor(0, 1, 0); end
		if (mtr.phase.color == "red") then 	BT.mtrs[key].bar:SetStatusBarColor(1, 0, 0); end

		BT.mtrs[key].bar:Show();
		BT.mtrs[key].btn:Show();
	end

	for i=use_idx,BT.options.max_mtrs do
		local key = 'm'..i;
		BT.mtrs[key].bar:Hide();
		BT.mtrs[key].btn:Hide();		
	end

	

end

function BT.GetStatus(ability, prio)

	local t = 0;

	if (ability.spell) then

		local usable = IsUsableSpell(ability.spell);
		if (not usable) then
			return false, 0;
		end

		local start, duration = GetSpellCooldown(ability.spell);
		if duration > 0 then
			t = start + duration - GetTime()
		end
	end

	if (ability.debuff) then

		local index = 1
		while UnitDebuff("target", index) do
			local name, _, _, count, _, _, debuffExpires, caster = UnitDebuff("target", index)
			if ((name == ability.debuff) and (caster == "player")) then
				local t2 = debuffExpires - GetTime()
				if (t2 > t) then
					t = t2;
				end
			end
			index = index + 1
		end
	end

	if (ability.buff) then

		local index = 1
		while UnitBuff("player", index) do
			local name, _, _, count, _, _, buffExpires, caster = UnitBuff("player", index)
			if (name == ability.buff) then
				local t2 = buffExpires - GetTime()
				if (t2 > t) then
					t = t2;
				end
			end
			index = index + 1
		end
	end

	if (prio.waitbuff) then

		local index = 1
		while UnitBuff("player", index) do
			local name, _, _, count, _, _, buffExpires, caster = UnitBuff("player", index)
			if (name == prio.waitbuff) then
				local t2 = buffExpires - GetTime()
				if (t2 > t) then
					t = t2;
				end
			end
			index = index + 1
		end

	end

	return true, t;
end

function BT.GetMeter(info)

	if (not info) then
		return 0, 0, info;
	end

	local t = 0;
	local max = 0;

	if (info.buff) then

		local index = 1
		while UnitBuff("player", index) do
			local name, _, _, count, _, duration, buffExpires, caster = UnitBuff("player", index)
			if (name == info.buff) then
				t = buffExpires - GetTime()
				max = duration;
			end
			index = index + 1
		end
	end

	if (info.debuff) then

		local index = 1
		while UnitDebuff("target", index) do
			local name, _, _, count, _, duration, debuffExpires, caster = UnitDebuff("target", index)
			if ((name == info.debuff) and (caster == "player")) then
				t = debuffExpires - GetTime();
				max = duration;
			end
			index = index + 1
		end
	end

	if (info.spell) then

		local usable = IsUsableSpell(info.spell);
		if (usable) then
			local start, duration = GetSpellCooldown(info.spell);
			if duration > 0 then
				t = start + duration - GetTime()
				max = duration;
			end
		end
	end

	if (info.petbuff) then

		local index = 1
		while UnitBuff("player", index) do
			local name, _, _, count, _, duration, buffExpires, caster = UnitBuff("pet", index)
			if (name == info.petbuff) then
				t = buffExpires - GetTime()
				max = duration;
			end
			index = index + 1
		end
	end

	return t, max, info;
end

function BT.CheckWho(who)
	local lvl = UnitLevel("target");
	local isIn, type = IsInInstance();

	if (who == 'boss') then
		if (lvl == -1) then
			return true;
		end
	end
	if (who == 'raidboss') then
		if ((lvl == -1) and ((type == 'raid') or (type == 'none'))) then
			return true;
		end
	end

	return false;
end

function BT.FormatTime(s)

	if (s > 59) then
		local m = math.floor(s / 60)
		s = s - (m * 60);
		if (s > 0) then
			return string.format("%dm %ds", m, s);
		end
		return string.format("%dm", m);
	end
	return string.format("%ds", s);
end

function BT.OnUpdate()
	if (_G.BeeTeamDB.opts.hide) then 
		return;
	end

	BT.UpdateFrame();
end


function BT.SetFontSize(string, size)

	local Font, Height, Flags = string:GetFont()
	string:SetFont(Font, size, Flags)
end

function BT.SetHide(a)
	_G.BeeTeamDB.opts.hide = a;
	if (a) then
		BT.UIFrame:Hide();
		BTOptionsFrameCheck1:SetChecked(false);
	else
		BT.UIFrame:Show();
		BTOptionsFrameCheck1:SetChecked(true);
	end
	BT.RebuildFrame();
	BT.UpdateFrame();
end

function BT.SetLocked(a)
	_G.BeeTeamDB.opts.locked = a;
	BTOptionsFrameCheck2:SetChecked(a);
end

function BT.ResetPos()
	BT.Show();
	BT.UIFrame:SetWidth(150);
	BT.UIFrame:ClearAllPoints();
	BT.UIFrame:SetPoint("CENTER", 0, 0);
end

function BT.ToggleLock()
	if (_G.BeeTeamDB.opts.locked) then
		BT.SetLocked(false);
	else
		BT.SetLocked(true);
	end
end

function BT.ToggleHide()
	if (_G.BeeTeamDB.opts.hide) then
		BT.SetHide(false);
	else
		BT.SetHide(true);
	end
end

function BT.SimpleGCD()

	local start, duration = GetSpellCooldown(1462);
	if duration > 0 then
		return start + duration - GetTime()
	end

	return 0
end

function BT.SpellCooldown(id)

	if (not IsUsableSpell(id)) then
		return 0;
	end

	local start, duration = GetSpellCooldown(id);
	if duration > 0 then
		return start + duration - GetTime()
	end

	return 0
end

function BT.DebuffElseGCD(aName)
	local index = 1
	while UnitDebuff("target", index) do
		local name, _, _, count, _, _, debuffExpires, caster = UnitDebuff("target", index)
		if ((name == aName) and (caster == "player")) then
			return debuffExpires - GetTime()
		end
		index = index + 1
	end

	local start, duration = GetSpellCooldown(1462);
	if duration > 0 then
		return start + duration - GetTime()
	end

	return 0
end

function BT.SlashCommand(msg, editbox)
	if (msg == 'show') then
		BT.SetHide(false);
	elseif (msg == 'hide') then
		BT.SetHide(true);
	elseif (msg == 'toggle') then
		BT.ToggleHide();
	elseif (msg == 'reset') then
		BT.ResetPos();
	else
		print(L.CMD_HELP);
		print("   /bt show - "..L.CMD_HELP_SHOW);
		print("   /bt hide - "..L.CMD_HELP_HIDE);
		print("   /bt toggle - "..L.CMD_HELP_TOGGLE);
		print("   /bt reset - "..L.CMD_HELP_RESET);
	end
end


SLASH_BEETEAM1 = '/beeteam';
SLASH_BEETEAM2 = '/bt';

SlashCmdList["BEETEAM"] = BT.SlashCommand;


BT.Frame = CreateFrame("Frame")
BT.Frame:Show()
BT.Frame:SetScript("OnEvent", BT.OnEvent)
BT.Frame:SetScript("OnUpdate", BT.OnUpdate)
BT.Frame:RegisterEvent("ADDON_LOADED")
BT.Frame:RegisterEvent("PLAYER_LOGOUT")
BT.Frame:RegisterEvent("PLAYER_LOGIN")
BT.Frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

BT.OnLoad()
