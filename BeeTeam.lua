BT = {}

BT.options = {};
BT.default_options = {

	frameRef = "CENTER",
	frameX = 0,
	frameY = 0,

	locked = false,
	hide = false,

	runway = 200,
	time_limit = 10,
	font_size = 8,
	cooldown_size = 20,
	label_font_size = 10,
	warning_font_size = 20,
	max_prios = 10,
	max_mtrs = 10,
	max_warns = 10,
	mtr_icon_size = 20,
	demo_mode = false,
	priorities = {
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
	},
	meters = {
		md_applied = true,
		md_cooldown = true,
		hunters_mark = true,
		serpent_sting = false,
		mend_pet = true,
		trap_set = true,
		trap_triggered = true,
	},
	warnings = {
		no_pet = true,
		sad_pet = true,
		bad_aspect = true,
		no_hunters_mark = true,
		bad_weapon = true, -- fishing pole, lance
	},
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

BT.warningdefs = {
	no_pet = {
		title = "Missing Pet",
		icon = [[Interface\Icons\inv_box_petcarrier_01]],
	},
	sad_pet = {
		title = "Sad Pet",
		icon = [[Interface\PetPaperDollFrame\UI-PetHappiness]],
		tex_coords = {0.375, 0.5625, 0, 0.359375},
	},
	bad_aspect = {
		title = "Wrong Aspect",
		icon = [[Interface\Icons\ability_hunter_pet_dragonhawk]],
	},
	no_hunters_mark = {
		title = "Missing Hunter's Mark",
		icon = [[Interface\Icons\ability_hunter_snipershot]],
	},
	bad_weapon = {
		title = "Bad Weapon Equipped",
		not_implemented = true,
	},
};

BT.state = {
	md_target = "?",
	trap_set = false,
	trap_set_start = 0,
	trapped_mobs = {},
};

BT.everything_ready = false;
BT.waiting_for_bind = false;
BT.last_check = 0;
BT.time_between_checks = 5;
BT.default_icon = "INV_Misc_QuestionMark";
BT.default_icon_full = [[Interface\Icons\INV_Misc_QuestionMark]];


function BT.OnLoad()

end

function BT.OnReady()

	_G.BeeTeamDB = _G.BeeTeamDB or {};
	_G.BeeTeamDB.opts = _G.BeeTeamDB.opts or {};

	BT.options = BT.LoadOptions(BT.default_options, _G.BeeTeamDB.opts);

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

function BT.LoadOptions(defaults, current)

	local out = {};

	for k,v in pairs(defaults) do
		if (current[k]) then
			out[k] = current[k];
		else
			out[k] = v;
		end
	end

	return out;
end

function BT.OnSaving()

	local point, relativeTo, relativePoint, xOfs, yOfs = BT.UIFrame:GetPoint()
	BT.options.frameRef = relativePoint;
	BT.options.frameX = xOfs;
	BT.options.frameY = yOfs;

	_G.BeeTeamDB.opts = BT.options;
end


function BT.OnEvent(frame, event, ...)

	if (event == 'COMBAT_LOG_EVENT_UNFILTERED') then

		local srcUs = false;
		if (arg3 == UnitGUID("player")) then srcUs = true; end

		if (srcUs and arg2 == "SPELL_CAST_SUCCESS" and arg10 == "Misdirection") then
			BT.state.md_target = arg7;
		end

		if ((arg2 == "SPELL_CREATE") and (srcUs) and ((arg10 == "Freezing Arrow") or (arg10 == "Freezing Trap"))) then
			BT.state.trap_set = true;
			BT.state.trap_set_start = GetTime();
			if (arg10 == "Freezing Trap") then BT.meterinfo.trap_set.icon = "spell_frost_chainsofice"; end
			if (arg10 == "Freezing Arrow") then BT.meterinfo.trap_set.icon = "spell_frost_chillingbolt"; end
			return;
		end

		if ((arg2 == "SPELL_MISSED") and srcUs and ((arg10 == "Freezing Arrow Effect") or (arg10 == "Freezing Trap Effect"))) then
			BT.state.trap_set = false;
		end

		if ((arg2 == "SPELL_AURA_APPLIED") and srcUs and ((arg10 == "Freezing Arrow Effect") or (arg10 == "Freezing Trap Effect"))) then

			BT.state.trap_set = false;
			BT.state.trapped_mobs[arg6] = {
				start = GetTime(),
				aura = arg10,
				guid = arg6,
				name = arg7,
			};
			return;
		end

		if ((arg2 == "SPELL_AURA_REMOVED") and srcUs and ((arg10 == "Freezing Arrow Effect") or (arg10 == "Freezing Trap Effect"))) then

			BT.state.trapped_mobs[arg6] = nil;
			return;
		end


		if (false) then
			local dest = arg7;
			if (not dest) then dest = "?"; end
			local src = arg4;
			if (not src) then src = "?"; end
			local spell = arg10;
			if (not spell) then spell = "?"; end

			print(string.format("%s (%s -> %s) %s", arg2, src, dest, spell));
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
		BT.everything_ready = true;
	end

	if (event == 'PLAYER_LOGOUT') then

		BT.OnSaving();
	end
end

function BT.OnDragStart(frame)
	if (BT.options.locked) then
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
	if (BT.options.frameRef) then
		frameRef = BT.options.frameRef;
		frameX = BT.options.frameX;
		frameY = BT.options.frameY;
	end
	BT.UIFrame:SetPoint(frameRef, frameX, frameY);

	-- make it draggable
	BT.UIFrame:SetMovable(true);
	BT.UIFrame:EnableMouse(true);


	-- buttons!
	BT.rot_btns = {};
	for i=1,BT.options.max_prios do
		local key = 'p'..i;
		BT.rot_btns[key] = BT.CreateButton(0, 0, 40, 40, [[Interface\Icons\ability_hunter_pet_dragonhawk]]);
		BT.rot_btns[key]:SetFrameLevel(100 + BT.options.max_prios - i);
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

	-- warnings
	BT.warn_btns = {};
	for i=1,BT.options.max_warns do
		local key = 'w'..i;
		BT.warn_btns[key] = BT.CreateTextureFrame(BT.fullW-(i * 20), 0-20, 20, 20, [[Interface\Icons\ability_hunter_pet_dragonhawk]]);
	end
	


	-- create a button that covers the entire addon
	BT.Cover = CreateFrame("Button", "foo", BT.UIFrame);
	BT.Cover:SetFrameLevel(128)
	BT.Cover:SetPoint("TOPLEFT", 0, 0)
	BT.Cover:SetWidth(BT.fullW)
	BT.Cover:SetHeight(BT.fullH)
	BT.Cover:EnableMouse(true);
	BT.Cover:RegisterForClicks("AnyUp");
	BT.Cover:RegisterForDrag("LeftButton");
	BT.Cover:SetScript("OnDragStart", BT.OnDragStart);
	BT.Cover:SetScript("OnDragStop", BT.OnDragStop);
	BT.Cover:SetScript("OnClick", BT.OnClick);

	-- main label - shows help & warnings
	BT.Label = BT.Cover:CreateFontString(nil, "OVERLAY")
	BT.Label:SetPoint("CENTER", BT.UIFrame, "CENTER", 2, 0)
	BT.Label:SetJustifyH("LEFT")
	BT.Label:SetFont([[Fonts\FRIZQT__.TTF]], 12, "OUTLINE");
	BT.Label:SetText(" ");
	BT.Label:SetTextColor(1,1,1,1)
	BT.SetFontSize(BT.Label, 10)


	--BT.Cover.texture = BT.Cover:CreateTexture("ARTWORK")
	--BT.Cover.texture:SetAllPoints()
	--BT.Cover.texture:SetTexture(1, 0.5, 0)
	--BT.Cover.texture:SetAlpha(0.5);

	-- Add options to the dialog
	local py = 100;

	BT.CreateHeading(16, py, "Timers");
	py = py + 20;

	for key, info in pairs(BT.meterinfo) do

		local label = "?";
		if (info.spell) then label = info.spell; end
		if (info.debuff) then label = info.debuff; end
		if (info.buff) then label = info.buff; end
		if (info.petbuff) then label = info.petbuff; end
		if (info.title) then label = info.title; end

		local check = BT.CreateCheckBox("BTCheckMeter-"..key, 16, py, BT.options.meters[key], label);
		check.key = key;
		check:SetScript("OnClick", function(self)
			if (self:GetChecked()) then
				--print("option "..self.key.." is ON");
				BT.options.meters[self.key] = true;
			else
				--print("option "..self.key.." is OFF");
				BT.options.meters[self.key] = false;
			end
		end);

		py = py + 20;
	end

	py = py + 20;
	BT.CreateHeading(16, py, "Warnings");
	py = py + 20;

	for key, info in pairs(BT.warningdefs) do

		local label = "?";
		if (info.title) then label = info.title; end

		local check = BT.CreateCheckBox("BTCheckWarn-"..key, 16, py, BT.options.warnings[key], label);
		check.key = key;
		check:SetScript("OnClick", function(self)
			if (self:GetChecked()) then
				--print("warning "..self.key.." is ON");
				BT.options.warnings[self.key] = true;
			else
				--print("warning "..self.key.." is OFF");
				BT.options.warnings[self.key] = false;
			end
		end);
		if (info.not_implemented) then
			check.label:SetTextColor(1,0,0);
		end

		py = py + 20;
	end


	BT.SetLocked(BT.options.locked);
	BT.SetHide(BT.options.hide);
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
	if (BT.options.locked) then locked = true; end

	table.insert(menuList, {
		text = "Demo Mode",
		func = function() BT.options.demo_mode = not BT.options.demo_mode end,
		isTitle = false,
		checked = BT.options.demo_mode,
		disabled = false,
	});

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

function BT.CreateHeading(x, y, text)

	local h = BTOptionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
	h:SetPoint("TOPLEFT", x, 0-y);
	h:SetText(text);
	h:Show();
	--BT.Label:SetTextColor(1,1,1,1)
	--BT.SetFontSize(BT.Label, 10)

	return h;
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

function BT.CreateTextureFrame(x, y, w, h, texture)

	local b = CreateFrame("Frame", nil, BT.UIFrame);
	b:SetPoint("TOPLEFT", x, 0-y)
	b:SetWidth(w)
	b:SetHeight(h)

	b.texture = b:CreateTexture(nil, "ARTWORK");
	b.texture:SetAllPoints(b)
	b.texture:SetTexture(texture)

	b.border = b:CreateTexture(nil, "OVERLAY");
	b.border:SetPoint("CENTER", 0, 0);
	b.border:SetWidth(math.floor(w * 62/36));
	b.border:SetHeight(math.floor(h * 62/36));
	b.border:SetTexture([[Interface\Buttons\UI-ActionButton-Border]]);
	b.border:SetBlendMode("ADD");
	b.border:SetVertexColor(1, 0, 0);

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

function BT.CreateCheckBox(id, x, y, checked, text)

	local check = CreateFrame("CheckButton", id, BTOptionsFrame, "InterfaceOptionsCheckButtonTemplate");
	check:SetChecked(checked);
	check.label = _G[check:GetName().."Text"];
	check.label:SetText(text);
	check:SetHitRectInsets(0, -300, 0, 0);
	check:SetPoint("TOPLEFT", x, 0-y);

	return check;
end

function BT.RebuildFrame()

	for i=1,BT.options.max_prios do
		local key = 'p'..i;
		local ability = BT.abilities[BT.options.priorities[key].which];
		if (ability) then
			BT.rot_btns[key]:SetNormalTexture([[Interface\Icons\]] .. ability.icon);
		else
			BT.rot_btns[key]:SetNormalTexture([[Interface\Icons\ability_hunter_pet_dragonhawk]]);
		end
	end
end

function BT.GetBinds()

	local map = {};

	for i=1,BT.options.max_prios do
		local key = 'p'..i;
		local prio = BT.options.priorities[key];
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

			map[prio.bind] = cmd;
		end
	end

	return map;
end

function BT.CheckBinds()

	if (BT.waiting_for_bind) then
		-- we mind now be out of combat...
		BT.BindKeys();
		return;
	end

	local binds = BT.GetBinds();
	local dirty = false;

	for bind, cmd in pairs(binds) do

		local test = GetBindingAction(bind, true);
		if (not (test == cmd)) then
			--print(string.format("bad binding on %s (expecting %s, got %s)", bind,cmd,test));
			dirty = true;
		end
	end

	if (dirty) then
		print("BeeTeam: Something is messing with our bindings. Check other addons.");
		BT.BindKeys();
	end
end

function BT.BindKeys()

	if (InCombatLockdown()) then
		if (not BT.waiting_for_bind) then
			print("Waiting until combat ends to bind keys");
		end
		return ;
	end

	BT.waiting_for_bind = false;

	local binds = BT.GetBinds();

	local set = GetCurrentBindingSet();

	for bind, cmd in pairs(binds) do

		local ok = SetOverrideBinding(BT.UIFrame, true, bind, cmd);
		-- TODO: report error if we can't bind...
	end
end

function BT.HasViableTarget()
	local can_attack = UnitCanAttack("player", "target");
	if (can_attack and UnitIsDeadOrGhost("target")) then
		can_attack = false;
	end
	return can_attack;
end

function BT.UpdateFrame()

	--
	-- are we showing the frame?
	--

	if (BT.options.hide) then 
		return;
	end

	local inVehicle = UnitInVehicle("player");
	if (inVehicle) then
		BT.UIFrame:Hide();
		return;
	else
		BT.UIFrame:Show();
	end


	--
	-- gather the data
	--

	local status = nil;

	if (BT.options.demo_mode) then
		status = BT.GatherDemoStatus();
	else
		status = BT.GatherStatus();
	end


	--
	-- display priorities
	--

	local done_at_limit = 0;
	local done_at_rdy = 0;
	local btns_at_limit = {};

	for _,info in pairs(status.priorities) do

		local key = info.key;

		if (info.ok) then

			if (info.t > BT.options.time_limit) then
				done_at_limit = done_at_limit + 1;
				BT.rot_btns[key].label:SetText(string.format("%d", info.t));
				table.insert(btns_at_limit, BT.rot_btns[key]);
			else
				local x = BT.options.runway * info.t / BT.options.time_limit;
				local y = 0;

				if (x < 40) then
					y = done_at_rdy * 10;
					done_at_rdy = done_at_rdy + 1;
				end

				BT.rot_btns[key]:SetWidth(40);
				BT.rot_btns[key]:SetHeight(40);
				BT.rot_btns[key]:SetPoint("TOPLEFT", x, y);

				BT.SetFontSize(BT.rot_btns[key].label, BT.options.font_size);
				BT.rot_btns[key].label:SetText(info.label);
			end
		
			BT.rot_btns[key]:Show();
		else
			BT.rot_btns[key]:Hide();
		end

		if (status.has_viable_target) then

			BT.rot_btns[key]:SetAlpha(1);
		else
			BT.rot_btns[key]:SetAlpha(0.5);
		end
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


	--
	-- center label
	--

	local label = " ";
	local warning = false;

	if (status.low_on_mana) then

		warning = true;
		label = string.format("Mana Low (%d%%)", status.mana_percent);
	end

	if (status.too_close) then
		label = "Too Close";
		warning = true;
	end

	if (status.too_far) then
		label = "Too Far";
		warning = true;
	end

	if (status.active_shots == 0) then
		warning = false;
		label = "No abilities configured - Right click to hide";
	end

	if (BT.options.demo_mode) then
		warning = true;
		label = "Demo Mode Active";
	end

	if (warning) then
		BT.Label:SetTextColor(1,0,0,1)
		BT.SetFontSize(BT.Label, BT.options.warning_font_size);
	else
		BT.Label:SetTextColor(1,1,1,1)
		BT.SetFontSize(BT.Label, BT.options.label_font_size);
	end
	BT.Label:SetText(label);


	--
	-- whole frame
	--

	if (status.has_viable_target) then
		--BT.UIFrame:SetAlpha(1);
	else
		--BT.UIFrame:SetAlpha(0.5);
	end


	--
	-- meters
	--

	local use_idx = 1;

	for _,mtr in pairs(status.meters) do

		local key = 'm'..use_idx;
		use_idx = use_idx + 1;

		local label = BT.FormatTime(mtr.t);
		if (mtr.label) then
			label = label .. " - " .. mtr.label;
		end
		if (mtr.special_label) then
			label = label .. " - " .. BT.state[mtr.special_label];
		end

		local icon = mtr.icon;
		if (not icon) then icon = BT.default_icon; end

		BT.mtrs[key].btn:SetNormalTexture([[Interface\Icons\]] .. icon);
		BT.mtrs[key].bar.label:SetText(label);
		BT.mtrs[key].bar:SetMinMaxValues(0, mtr.max);
		BT.mtrs[key].bar:SetValue(mtr.t);

		BT.mtrs[key].bar:SetStatusBarColor(1, 1, 1);
		if (mtr.color == "green") then 	BT.mtrs[key].bar:SetStatusBarColor(0, 1, 0); end
		if (mtr.color == "red") then 	BT.mtrs[key].bar:SetStatusBarColor(1, 0, 0); end

		BT.mtrs[key].bar:Show();
		BT.mtrs[key].btn:Show();
	end

	for i=use_idx,BT.options.max_mtrs do
		local key = 'm'..i;
		BT.mtrs[key].bar:Hide();
		BT.mtrs[key].btn:Hide();
	end


	--
	-- warnings
	--

	local use_idx = 1;

	for _,warn in pairs(status.warnings) do

		local key = 'w'..use_idx;
		use_idx = use_idx + 1;

		local icon = warn.icon;
		if (not icon) then icon = BT.default_icon_full; end;

		BT.warn_btns[key].texture:SetTexture(icon);

		if (warn.tex_coords) then
			BT.warn_btns[key].texture:SetTexCoord(warn.tex_coords[1], warn.tex_coords[2], warn.tex_coords[3], warn.tex_coords[4]);
		else
			BT.warn_btns[key].texture:SetTexCoord(0, 1, 0, 1);
		end

		BT.warn_btns[key]:Show();
	end

	for i=use_idx,BT.options.max_warns do
		local key = 'w'..i;
		BT.warn_btns[key]:Hide();		
	end

end

function BT.GatherStatus()

	local ret = {};

	ret.has_viable_target = UnitCanAttack("player", "target");
	if (ret.has_viable_target and UnitIsDeadOrGhost("target")) then
		ret.has_viable_target = false;
	end

	ret.active_shots = 0;
	ret.priorities = {};

	for i=1,BT.options.max_prios do
		local key = 'p'..i;
		local prio = BT.options.priorities[key];
		local ability = BT.abilities[prio.which];
		local ok, t = false, 0;
		if (ability) then
			ok, t = BT.GetStatus(ability, prio);
		end
		if (not (prio.who == "any")) then
			ok = BT.CheckWho(prio.who);
		end

		if (ok) then
			ret.active_shots = ret.active_shots + 1;
		end

		local label = " ";
		if (prio.bind) then label = prio.bind; end
		if (prio.label) then label = prio.label; end

		table.insert(ret.priorities, {
			key = key,
			ok = ok,
			t = t,
			label = label,
		});
	end


	--
	-- mana level
	--

	ret.low_on_mana = false;

	local cur_mana = UnitPower("player", 0);
	local max_mana = UnitPowerMax("player", 0);
	local mana_per = cur_mana / max_mana;

	if (mana_per < 0.1) then

		ret.low_on_mana = true;
		ret.mana_percent = 100*mana_per;
	end


	--
	-- range
	--

	ret.too_close = false;
	ret.too_far = false;

	local inShotRange = IsSpellInRange("Auto Shot");
	local inMeleeRange = IsSpellInRange("Wing Clip");

	if ((ret.active_shots > 0) and ret.has_viable_target) then

		if (not (inShotRange == 1)) then
			if (inMeleeRange == 1) then
				ret.too_close = true;
			else
				ret.too_far = true;
			end
		end
	end


	--
	-- meters
	--

	ret.meters = {};

	for key, info in pairs(BT.meterinfo) do

		if (BT.options.meters[key] and info) then

			info.key = key;

			local temp = BT.GetMeter(info);
			if (temp.multi) then
				for _,temp2 in pairs(temp.multi) do
					if (temp2.max > 2) then
						table.insert(ret.meters, temp2);
					end
				end
			else
				if (temp.max > 2) then
					table.insert(ret.meters, temp);
				end
			end
		end
	end

	table.sort(ret.meters, function(a,b) return a.max<b.max end);


	--
	-- warnings
	--

	ret.warnings = {};

	for key, info in pairs(BT.warningdefs) do

		if (BT.options.warnings[key] and info) then

			local warn = BT.GetWarning(key, info);
			if (warn.show) then
				table.insert(ret.warnings, warn);
			end
		end
	end

	--table.sort(ret.warnings, function(a,b) return a.max<b.max end);

	return ret;
end

function BT.GatherDemoStatus()

	local ret = {};

	ret.has_viable_target = true;
	ret.low_on_mana = false;
	ret.too_close = false;
	ret.too_far = false;

	ret.active_shots = 0;
	ret.priorities = {};

	for i=1,BT.options.max_prios do
		local key = 'p'..i;
		local prio = BT.options.priorities[key];
		local ability = BT.abilities[prio.which];

		local ok = false;
		local t = 0;
		local label = " ";
		if (prio.bind) then label = prio.bind; end
		if (prio.label) then label = prio.label; end

		if (ability) then
			ret.active_shots = ret.active_shots + 1;
			ok = true;
			if (ret.active_shots < 3) then
				ok = true;
				t = 0;
			elseif (ret.active_shots == 3) then
				ok = true;
				t = 0.5;
			elseif (ret.active_shots == 4) then
				ok = true;
				t = BT.options.time_limit + 1;
			elseif (ret.active_shots == 5) then
				ok = true;
				t = 99;
			else
				ok = true;
				t = ret.active_shots - 2;
			end
		end

		table.insert(ret.priorities, {
			key = key,
			ok = ok,
			t = t,
			label = label,
		});
	end


	--
	-- meters
	--

	ret.meters = {};
	local v = 10;

	for key, info in pairs(BT.meterinfo) do

		if (BT.options.meters[key] and info) then

			info.t = v;
			info.max = 10;

			table.insert(ret.meters, info);
		end

		v = v - 1;
	end

	table.sort(ret.meters, function(a,b)
		if (a.max == b.max) then
			return a.t < b.t
		end
		return a.max < b.max
	end);


	--
	-- warnings
	--

	ret.warnings = {};

	for key, info in pairs(BT.warningdefs) do

		if (BT.options.warnings[key] and info) then

			info.key = key;
			info.show = true;

			table.insert(ret.warnings, info);
		end
	end

	--table.sort(ret.warnings, function(a,b) return a.max<b.max end);

	return ret;
end

function BT.GetWarning(key, info)

	info.key = key;
	info.show = false;

	if (key == "no_pet") then
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

	if (key == "sad_pet") then
		local happiness, damagePercentage, loyaltyRate = GetPetHappiness()
		if (not happiness) then return info; end -- no pet
		if (happiness == 3) then return info; end -- happy

		info.icon = [[Interface\PetPaperDollFrame\UI-PetHappiness]];
		info.show = true;

		if (happiness == 1) then info.tex_coords = {0.375, 0.5625, 0, 0.359375}; end
		if (happiness == 2) then info.tex_coords = {0.1875, 0.375, 0, 0.359375}; end

		return info;
	end

	if (key == "bad_aspect") then

		local bad_icon = nil;
		local found_dh = false;
		local index = 1

		while UnitBuff("player", index) do
			local name, _, _, count, _, _, buffExpires, caster = UnitBuff("player", index)
			if (name == "Aspect of the Beast"	) then bad_icon = "ability_mount_pinktiger"; end
			if (name == "Aspect of the Cheetah"	) then bad_icon = "ability_mount_jungletiger"; end
			if (name == "Aspect of the Hawk"	) then bad_icon = "spell_nature_ravenform"; end
			if (name == "Aspect of the Monkey"	) then bad_icon = "ability_hunter_aspectofthemonkey"; end
			if (name == "Aspect of the Pack"	) then bad_icon = "ability_mount_whitetiger"; end
			if (name == "Aspect of the Viper"	) then bad_icon = "ability_hunter_aspectoftheviper"; end
			if (name == "Aspect of the Wild"	) then bad_icon = "spell_nature_protectionformnature"; end
			if (name == "Aspect of the Dragonhawk"	) then found_dh = true; end
			index = index + 1
		end

		if (bad_icon) then
			info.show = true;
			info.icon = [[Interface\Icons\]] .. bad_icon;
		else
			if (not found_dh) then
				info.show = true;
				info.icon = [[Interface\Icons\ability_hunter_pet_dragonhawk]];
			end
		end
		return info;
	end


	if (key == "no_hunters_mark") then

		if (BT.HasViableTarget()) then

			local temp = BT.CheckBuff(UnitDebuff, "Hunter's Mark", "target", false);
			if (temp.t == 0) then
				info.show = true;
			end
		end
	end

	return info;
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

	info.t = 0;
	info.max = 0;

	if (not info) then
		return info;
	end

	if (info.key == "trap_set") then

		if (BT.state.trap_set) then

			local duration = GetTime() - BT.state.trap_set_start;
			local max = 30;

			if (duration > max) then
				BT.state.trap_set = false;
			else
				info.max = max;
				info.t = max - duration;
			end
		end
		return info;
	end

	if (info.key == "trap_triggered") then

		info.multi = {};

		for guid, details in pairs(BT.state.trapped_mobs) do

			local info2 = BT.CopyTable(info);
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

		return info;
	end

	if (info.buff) then
		local temp = BT.CheckBuff(UnitBuff, info.buff, "player", false);
		if (temp.t > 0) then
			info.t = temp.t;
			info.max = temp.max;
		end
	end

	if (info.debuff) then
		local temp = BT.CheckBuff(UnitDebuff, info.debuff, "target", true);
		if (temp.t > 0) then
			info.t = temp.t;
			info.max = temp.max;
		end
	end

	if (info.spell) then
		local temp = BT.CheckCooldown(info.spell);
		if (temp.usable and temp.t > 0) then
			info.t = temp.t;
			info.max = temp.max;
		end
	end

	if (info.petbuff) then
		local temp = BT.CheckBuff(UnitBuff, info.petbuff, "pet", false);
		if (temp.t > 0) then
			info.t = temp.t;
			info.max = temp.max;
		end
	end

	return info;
end

function BT.CopyTable(a)
	local b = {};
	for k, v in pairs(a) do b[k] = v end
	return b;
end

function BT.CheckCooldown(spell)

	local usable = IsUsableSpell(spell);
	local t = 0;
	local max = 0;

	if (usable) then
		local start, duration = GetSpellCooldown(spell);
		if duration > 0 then
			t = start + duration - GetTime();
			max = duration;
		end
	end

	return {
		usable = usable,
		t = t,
		max = max,
	};
end

function BT.CheckBuff(qfunc, buff, target, must_be_ours)

	local index = 1
	while qfunc(target, index) do
		local name, _, _, count, _, duration, buffExpires, caster = qfunc(target, index)

		if ((name == buff) and ((not must_be_ours) or (caster == "player"))) then
			return {
				t = buffExpires - GetTime(),
				max = duration,
			};
		end
		index = index + 1
	end

	return {
		t = 0,
		max = 0,
	};
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

function BT.PeriodicCheck()
	--print('check!');
	BT.CheckBinds();
end

function BT.OnUpdate()
	if (not BT.everything_ready) then
		return;
	end

	if (BT.last_check +BT.time_between_checks < GetTime()) then
		BT.last_check = GetTime();
		BT.PeriodicCheck();
	end

	if (BT.options.hide) then 
		return;
	end

	BT.UpdateFrame();
end


function BT.SetFontSize(string, size)

	local Font, Height, Flags = string:GetFont()
	if (not (Height == size)) then
		string:SetFont(Font, size, Flags)
	end
end

function BT.SetHide(a)
	BT.options.hide = a;
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
	BT.options.locked = a;
	BTOptionsFrameCheck2:SetChecked(a);
end

function BT.ResetPos()
	BT.Show();
	BT.UIFrame:SetWidth(150);
	BT.UIFrame:ClearAllPoints();
	BT.UIFrame:SetPoint("CENTER", 0, 0);
end

function BT.ToggleLock()
	if (BT.options.locked) then
		BT.SetLocked(false);
	else
		BT.SetLocked(true);
	end
end

function BT.ToggleHide()
	if (BT.options.hide) then
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
