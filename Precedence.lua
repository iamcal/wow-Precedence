PREC = {}

PREC.enable_for_class = false;
PREC.options = {};
PREC.default_options = {

	-- automatic options
	frameRef = "CENTER",
	frameX = 0,
	frameY = 0,

	-- core options
	locked = false,
	hide = false,
	demo_mode = false,

	-- appearance
	scale = 1,
	mtr_icon_size = 20,
	runway = 200,

	time_limit = 10,
	font_size = 8,
	font_size_short = 20,

	cooldown_size = 20,
	label_font_size = 10,
	warning_font_size = 20,
	max_prios = 12,
	max_mtrs = 10,
	max_warns = 10,

	priorities = {
		p1 = {},
		p2 = {},
		p3 = {},
		p4 = {},
		p5 = {},
		p6 = {},
		p7 = {},
		p8 = {},
		p9 = {},
		p10 = {},
		p11 = {},
		p12 = {},
	},
	meters = {},
	warnings = {},
};

PREC.rotations = {};
PREC.abilities = {};
PREC.meterinfo = {};
PREC.warningdefs = {};
PREC.state = {};
PREC.event_handlers = {};
PREC.spell_costs = {};

PREC.everything_ready = false;
PREC.waiting_for_bind = false;
PREC.last_check = 0;
PREC.time_between_checks = 5;
PREC.default_icon = "INV_Misc_QuestionMark";
PREC.default_icon_full = [[Interface\Icons\INV_Misc_QuestionMark]];
PREC.debug_data = false;
PREC.max_char_level = 90;
PREC.current_shots = {};


function PREC.OnLoad()

end

function PREC.OnReady()

	_G.PrecedenceDB = _G.PrecedenceDB or {};
	_G.PrecedenceDB.opts = _G.PrecedenceDB.opts or {};

	PREC.options = PREC.LoadOptions(PREC.default_options, _G.PrecedenceDB.opts);

	-- auto-hide if we're not a supported class
	if (not PREC.enable_for_class) then
		PREC.options.hide = true;
	end

	-- register extra events
	local k, v;
	for k, v in pairs(PREC.event_handlers) do
		PREC.Frame:RegisterEvent(k);
	end

	PREC.CreateOptionsFrame()

	PREC.fullW = 40 + 40 + PREC.options.runway;
	PREC.fullH = 40;

	PREC.StartFrame();
end

function PREC.ResetOptions()

	PREC.options = PREC.default_options;
	PREC.BindKeys();
end

function PREC.ShowOptions()

	InterfaceOptionsFrame_OpenToCategory(PREC.OptionsFrame.name);
end

function PREC.OptionClick(button, name)

	if (name == 'hide') then
		PREC.ToggleHide();
	end

	if (name == 'lock') then
		PREC.ToggleLock();
	end

end

function PREC.LoadOptions(defaults, current)

	local out = {};

	local k, v;
	for k, v in pairs(defaults) do
		if (current[k]) then
			out[k] = current[k];
		else
			out[k] = v;
		end
	end

	return out;
end

function PREC.OnSaving()

	local point, relativeTo, relativePoint, xOfs, yOfs = PREC.UIFrame:GetPoint()
	PREC.options.frameRef = relativePoint;
	PREC.options.frameX = xOfs;
	PREC.options.frameY = yOfs;

	_G.PrecedenceDB.opts = PREC.options;
end


function PREC.OnEvent(frame, event, ...)

	if (PREC.event_handlers[event]) then
		PREC.event_handlers[event](...);
		return;
	end

	if (event == 'COMBAT_LOG_EVENT_UNFILTERED') then

		if (PREC.OnCombatLog) then
			PREC.OnCombatLog(...);
		end
		return;
	end

	if (event == 'UNIT_SPELLCAST_SENT') then

		if (PREC.OnSpellCastSent) then
			PREC.OnSpellCastSent(...);
		end
		return;
	end

	if (event == 'ADDON_LOADED') then
		local name = ...;
		if name == 'Precedence' then
			PREC.OnReady();
		end
		return;
	end

	if (event == 'PLAYER_LOGIN') then

		PREC.BindKeys();
		PREC.everything_ready = true;
		return;
	end

	if (event == 'PLAYER_LOGOUT') then

		PREC.OnSaving();
		return;
	end

end

function PREC.OnDragStart(frame)
	if (PREC.options.locked) then
		return;
	end
	PREC.UIFrame:StartMoving();
	PREC.UIFrame.isMoving = true;
	GameTooltip:Hide()
end

function PREC.OnDragStop(frame)
	PREC.UIFrame:StopMovingOrSizing();
	PREC.UIFrame.isMoving = false;
end

function PREC.OnClick(self, aButton)
	if (aButton == "RightButton") then
		PREC.ShowMenu();
	end
end

function PREC.CreateOptionsFrame()

	PREC.OptionsFrame = PREC.CreateScrollTab("PRECOptionsFrame");
	PREC.OptionsFrame.name = 'Precedence';
	PREC.OptionsPane = PREC.OptionsFrame.child;

	PREC.PrioOptionsFrame = PREC.CreateScrollTab("PRECPrioOptionsFrame");
	PREC.PrioOptionsFrame.name = 'Priorities';
	PREC.PrioOptionsFrame.parent = PREC.OptionsFrame.name;
	PREC.PrioOptionsPane = PREC.PrioOptionsFrame.child;

	PREC.WarnOptionsFrame = PREC.CreateScrollTab("PRECWarnOptionsFrame");
	PREC.WarnOptionsFrame.name = 'Warnings';
	PREC.WarnOptionsFrame.parent = PREC.OptionsFrame.name;
	PREC.WarnOptionsPane = PREC.WarnOptionsFrame.child;

	PREC.TimerOptionsFrame = PREC.CreateScrollTab("PRECTimerOptionsFrame");
	PREC.TimerOptionsFrame.name = 'Timers';
	PREC.TimerOptionsFrame.parent = PREC.OptionsFrame.name;
	PREC.TimerOptionsPane = PREC.TimerOptionsFrame.child;



	--
	-- Main options pane
	--

	PREC.CreateHeading(PREC.OptionsPane, 6, 6, "Precedence Options", "GameFontNormalLarge");

	local c1 = PREC.CreateCheckBox(PREC.OptionsPane, "PRECCheck1", 16, 35, false, "Enable");
	c1:SetScript("OnClick", function(self)
		PREC.OptionClick(self, 'hide');
	end);

	local c2 = PREC.CreateCheckBox(PREC.OptionsPane, "PRECCheck2", 16, 55, false, "Lock Frame");
	c2:SetScript("OnClick", function(self)
		PREC.OptionClick(self, 'lock');
	end);

	local py = 100;


	PREC.CreateHeading(PREC.OptionsPane, 16, py, "Appearance");

	py = py + 40;


	PREC.CreateSlider('PRECSlider1', 20, py, 200, 20, "Scale", PREC.options.scale, 0.1, 2, 0.1, function(self)
		local value = self:GetValue();
		value = math.floor(value * 10) / 10;
		self.label:SetText(self.default_label.." : "..value);
		PREC.options.scale = value;
	end);

	py = py + 50;


	PREC.CreateSlider('PRECSlider2', 20, py, 200, 20, "Meter Size", PREC.options.mtr_icon_size, 5, 40, 1, function(self)
		local value = self:GetValue();
		self.label:SetText(self.default_label.." : "..value);
		PREC.options.mtr_icon_size = value;
	end);

	py = py + 50;

	PREC.CreateSlider('PRECSlider3', 20, py, 200, 20, "Runway Length", PREC.options.runway, 100, 300, 1, function(self)
		local value = self:GetValue();
		self.label:SetText(self.default_label.." : "..value);
		PREC.options.runway = value;
	end);





	--
	-- Timers pane
	--

	PREC.CreateHeading(PREC.TimerOptionsPane, 6, 6, "Precedence Options - Timers", "GameFontNormalLarge");

	py = 35;

	local key, info;
	for key, info in pairs(PREC.meterinfo) do

		local label = "?";
		if (info.spell) then label = info.spell; end
		if (info.debuff) then label = info.debuff; end
		if (info.buff) then label = info.buff; end
		if (info.petbuff) then label = info.petbuff; end
		if (info.title) then label = info.title; end

		local check = PREC.CreateCheckBox(PREC.TimerOptionsPane, "PRECCheckMeter-"..key, 16, py, PREC.options.meters[key], label);
		check.key = key;
		check:SetScript("OnClick", function(self)
			if (self:GetChecked()) then
				--print("option "..self.key.." is ON");
				PREC.options.meters[self.key] = true;
			else
				--print("option "..self.key.." is OFF");
				PREC.options.meters[self.key] = false;
			end
		end);

		py = py + 20;
	end


	--
	-- Warnings pane
	--

	PREC.CreateHeading(PREC.WarnOptionsPane, 6, 6, "Precedence Options - Warnings", "GameFontNormalLarge");

	py = 35;

	local key, info;
	for key, info in pairs(PREC.warningdefs) do

		local label = "?";
		if (info.title) then label = info.title; end

		local check = PREC.CreateCheckBox(PREC.WarnOptionsPane, "PRECCheckWarn-"..key, 16, py, PREC.options.warnings[key], label);
		check.key = key;
		check:SetScript("OnClick", function(self)
			if (self:GetChecked()) then
				--print("warning "..self.key.." is ON");
				PREC.options.warnings[self.key] = true;
			else
				--print("warning "..self.key.." is OFF");
				PREC.options.warnings[self.key] = false;
			end
		end);
		if (info.not_implemented) then
			check.label:SetTextColor(1,0,0);
		end

		py = py + 20;
	end


	--
	-- Prios pane
	--

	PREC.CreateHeading(PREC.PrioOptionsPane, 6, 6, "Precedence Options - Priorities", "GameFontNormalLarge");

	py = 35;


	local abil_opts = {none = "None"};
	local k, v;
	for k, v in pairs(PREC.abilities) do
		abil_opts[k] = v.label or v.spell;
	end;

	local who_opts = {
		any = "All targets",
		boss = "Bosses only",
		raidboss = "Raid bosses only"
	};

	local i;
	for i=1,PREC.options.max_prios do
		local key = 'p'..i;

		local data = {};
		if (PREC.options.priorities[key]) then
			data = PREC.options.priorities[key];
		end
		if (not data) then data = {}; end
		local ability = data.which or 'none';
		local who = data.who or 'any';
		local bind = data.bind or nil;

		PREC.CreateHeading(PREC.PrioOptionsPane, 6, py, "Priority "..i);

		local abilitydd = PREC.CreateDropDown(PREC.PrioOptionsPane, "PRECCheckPrio-"..key.."-which", 16, py+20, 150, abil_opts, ability);
		abilitydd.OnUpdate = function(value)
			PREC.options.priorities[key].which = value;
			PREC.RebuildFrame();
		end;

		local whodd = PREC.CreateDropDown(PREC.PrioOptionsPane, "PRECCheckPrio-"..key.."-who", 180, py+20, 120, who_opts, who);
		whodd.OnUpdate = function(value)
			PREC.options.priorities[key].who = value;
		end;

		--TODO: bind
		PREC.CreateBindButton(PREC.PrioOptionsPane, "PRECCheckPrio-"..key.."-bind", 16, py+50, 150, bind);

		--TODO: label
		--TODO: cmd


		py = py + 80;
	end


	InterfaceOptions_AddCategory(PREC.OptionsFrame);
	InterfaceOptions_AddCategory(PREC.PrioOptionsFrame);
	InterfaceOptions_AddCategory(PREC.WarnOptionsFrame);
	InterfaceOptions_AddCategory(PREC.TimerOptionsFrame);
end

function PREC.CreateScrollTab(id)

	local f = CreateFrame("Frame", id, UIParent);
	f:SetFrameStrata("DIALOG");
	f:Hide();

	f.scroller = CreateFrame("ScrollFrame", id..'Scroll', f, "UIPanelScrollFrameTemplate");
	f.scroller:SetPoint("TOPLEFT", 10, -10);
	f.scroller:SetPoint("BOTTOMRIGHT", -30, 10);
	f.scroller:SetHorizontalScroll(0);
	f.scroller:SetVerticalScroll(0);

	--PREC.ColorIn(f.scroller, 0.5, 0.5, 0, 0.5);

	f.child = CreateFrame("Frame", id..'Child', f.scroller);
	f.child:SetWidth(100);
	f.child:SetHeight(100);
	f.scroller:SetScrollChild(f.child)

	--PREC.ColorIn(f.child, 0, 0, 1, 0.5);

	return f;
end

function PREC.ColorIn(frame, r, g, b, a)

	frame.texture = frame:CreateTexture("ARTWORK");
	frame.texture:SetAllPoints();
	frame.texture:SetTexture(r, g, b);
	frame.texture:SetAlpha(a);
end

function PREC.StartFrame()

	PREC.UIFrame = CreateFrame("Frame",nil,UIParent);
	PREC.UIFrame:SetFrameStrata("BACKGROUND")
	PREC.UIFrame:SetWidth(PREC.fullW)
	PREC.UIFrame:SetHeight(PREC.fullH)

	PREC.UIFrame.texture = PREC.UIFrame:CreateTexture()
	PREC.UIFrame.texture:SetAllPoints(PREC.UIFrame)
	PREC.UIFrame.texture:SetTexture(0, 0, 0)

	-- position the parent frame
	local frameRef = "CENTER";
	local frameX = 0;
	local frameY = 0;
	if (PREC.options.frameRef) then
		frameRef = PREC.options.frameRef;
		frameX = PREC.options.frameX;
		frameY = PREC.options.frameY;
	end
	PREC.UIFrame:SetPoint(frameRef, frameX, frameY);

	-- make it draggable
	PREC.UIFrame:SetMovable(true);
	PREC.UIFrame:EnableMouse(true);


	-- buttons!
	PREC.rot_btns = {};
	local i;
	for i=1,PREC.options.max_prios do
		local key = 'p'..i;
		PREC.rot_btns[key] = PREC.CreateButton(PREC.UIFrame, 0, 0, 40, 40, [[Interface\Icons\ability_hunter_pet_dragonhawk]]);
		PREC.rot_btns[key]:SetFrameLevel(100 + PREC.options.max_prios - i);
	end

	-- progress meters
	PREC.mtrs = {};
	local i;
	for i=1,PREC.options.max_mtrs do
		local key = 'm'..i;
		PREC.mtrs[key] = {
			btn = PREC.CreateButton(PREC.UIFrame, 0, 40 + ((i-1) * PREC.options.mtr_icon_size), PREC.options.mtr_icon_size, PREC.options.mtr_icon_size, [[Interface\Icons\ability_hunter_pet_dragonhawk]]),
			bar = PREC.CreateBar(PREC.options.mtr_icon_size, 40 + ((i-1) * PREC.options.mtr_icon_size), PREC.fullW-PREC.options.mtr_icon_size, PREC.options.mtr_icon_size),
		};
	end

	-- warnings
	PREC.warn_btns = {};
	local i;
	for i=1,PREC.options.max_warns do
		local key = 'w'..i;
		PREC.warn_btns[key] = PREC.CreateTextureFrame(PREC.UIFrame, PREC.fullW-(i * 20), 0-20, 20, 20, [[Interface\Icons\ability_hunter_pet_dragonhawk]]);
		PREC.warn_btns[key].key = key;

		PREC.warn_btns[key]:EnableMouse(true); 
		PREC.warn_btns[key]:SetHitRectInsets(0, 0, 0, 0)
		PREC.warn_btns[key]:SetScript("OnEnter", function(self) PREC.ShowWarningTooltip(self.key); end);
		PREC.warn_btns[key]:SetScript("OnLeave", function() GameTooltip:Hide(); end);
	end


	-- create a button that covers the entire addon
	PREC.Cover = CreateFrame("Button", nil, PREC.UIFrame);
	PREC.Cover:SetFrameLevel(128)
	PREC.Cover:SetPoint("TOPLEFT", 0, 0)
	PREC.Cover:SetWidth(PREC.fullW)
	PREC.Cover:SetHeight(PREC.fullH)
	PREC.Cover:EnableMouse(true);
	PREC.Cover:RegisterForClicks("AnyUp");
	PREC.Cover:RegisterForDrag("LeftButton");
	PREC.Cover:SetScript("OnDragStart", PREC.OnDragStart);
	PREC.Cover:SetScript("OnDragStop", PREC.OnDragStop);
	PREC.Cover:SetScript("OnClick", PREC.OnClick);
	--PREC.ColorIn(PREC.Cover, 1, 0.5, 0, 0.5);

	-- main label - shows help & warnings
	PREC.Label = PREC.Cover:CreateFontString(nil, "OVERLAY")
	PREC.Label:SetPoint("CENTER", PREC.UIFrame, "CENTER", 2, 0)
	PREC.Label:SetJustifyH("LEFT")
	PREC.Label:SetFont([[Fonts\FRIZQT__.TTF]], 12, "OUTLINE");
	PREC.Label:SetText(" ");
	PREC.Label:SetTextColor(1,1,1,1)
	PREC.SetFontSize(PREC.Label, 10)

	PREC.SetLocked(PREC.options.locked);
	PREC.SetHide(PREC.options.hide);
end

function PREC.ShowWarningTooltip(key)

	GameTooltip:SetOwner(PREC.warn_btns[key], "ANCHOR_TOP", 0, 10);

	GameTooltip:AddLine(PREC.warn_btns[key].title);

	GameTooltip:ClearAllPoints();
	GameTooltip:Show();
end

function PREC.CreateSlider(id, x, y, w, h, text, value, lo, hi, step, f)

	local slider = CreateFrame("Slider", id, PREC.OptionsPane, "OptionsSliderTemplate");
	slider.label = _G[slider:GetName().."Text"];
	slider.high = _G[slider:GetName().."High"];
	slider.low = _G[slider:GetName().."Low"];

	slider.high:SetText(hi);
	slider.low:SetText(lo);
	slider.default_label = text;
	slider.label:SetText(text.." : "..value);

	slider:SetMinMaxValues(lo, hi);
	slider:SetValueStep(step);
	slider:SetValue(value);


	slider:SetPoint("TOPLEFT", x, 0-y);
	slider:SetWidth(w);
	slider:SetHeight(h);
	slider:SetScript("OnValueChanged", f);

	return slider;
end

function PREC.ShowMenu()

	local menu_frame = CreateFrame("Frame", "menuFrame", UIParent, "UIDropDownMenuTemplate")

	local menuList = {};
	local first = true;

	table.insert(menuList, {
		text = "Options",
		func = function() PREC.ShowOptions() end,
		isTitle = false,
		checked = false,
		disabled = false,
	});

	local locked = false;
	if (PREC.options.locked) then locked = true; end

	table.insert(menuList, {
		text = "Demo Mode",
		func = function() PREC.options.demo_mode = not PREC.options.demo_mode end,
		isTitle = false,
		checked = PREC.options.demo_mode,
		disabled = false,
	});

	-- TODO - use config for this

	local key, info;
	for key, info in pairs(PREC.rotations) do

		local l_info = info;

		table.insert(menuList, {
			text = "Preset: "..l_info.name,
			func = function()
				PREC.options.priorities = l_info;
				PREC.RebuildFrame();
			end,
			isTitle = false,
			checked = false,
			disabled = false,
		});
	end

	table.insert(menuList, {
		text = "Lock Frame",
		func = function() PREC.ToggleLock() end,
		isTitle = false,
		checked = locked,
		disabled = false,
	});

	table.insert(menuList, {
		text = "Hide Window",
		func = function() PREC.SetHide(true) end,
		isTitle = false,
		checked = false,
		disabled = false,
	});

	EasyMenu(menuList, menu_frame, "cursor", 0 , 0, "MENU")

end

function PREC.CreateHeading(parent, x, y, text, font)

	font = font or "GameFontNormalLarge";

	local h = parent:CreateFontString(nil, "OVERLAY", font);
	h:SetPoint("TOPLEFT", x, 0-y);
	h:SetText(text);
	h:Show();
	--PREC.Label:SetTextColor(1,1,1,1)
	--PREC.SetFontSize(PREC.Label, 10)

	return h;
end

function PREC.CreateButton(parent, x, y, w, h, texture)

	local b = CreateFrame("Button", nil, parent);
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

function PREC.CreateTextureFrame(parent, x, y, w, h, texture)

	local b = CreateFrame("Frame", nil, parent);
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

function PREC.CreateBar(x, y, w, h)

	local b = CreateFrame("StatusBar", nil, PREC.UIFrame)
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

function PREC.CreateCheckBox(parent, id, x, y, checked, text)

	local check = CreateFrame("CheckButton", id, parent, "InterfaceOptionsCheckButtonTemplate");
	check:SetChecked(checked);
	check.label = _G[check:GetName().."Text"];
	check.label:SetText(text);
	check:SetHitRectInsets(0, -300, 0, 0);
	check:SetPoint("TOPLEFT", x, 0-y);

	return check;
end

function PREC.CreateDropDown(parent, id, x, y, w, options, selected)

	-- disabled because it causes terrible taint issues.
	-- UIDropDownMenu_* is full of bad code :(

	return {};
end

function PREC.CreateDropDown_OLD(parent, id, x, y, w, options, selected)

	local menu = CreateFrame("Frame", id, parent, "UIDropDownMenuTemplate");
	menu.type = CONTROLTYPE_DROPDOWN;

	menu.OnUpdate = function(value)
		-- callers will override this
	end;
	menu.OnChange = function(value)
		menu.OnUpdate(value);
		UIDropDownMenu_SetSelectedValue(menu, value);
	end;

	UIDropDownMenu_SetWidth(menu, w-17, 0); -- the frame will be ~17 wider for the button on the right
	UIDropDownMenu_SetButtonWidth(menu, w); -- the width of the clickable region on the right
	UIDropDownMenu_Initialize(menu, function()
		local k, v;
		for k, v in pairs(options) do
			UIDropDownMenu_AddButton({
				text = v,
				value = k,
				func = function()
					menu.OnChange(k);
				end,
			});
		end
	end);
	UIDropDownMenu_SetSelectedValue(menu, selected);
	UIDropDownMenu_JustifyText(menu, "LEFT");
	UIDropDownMenu_EnableDropDown(menu);

	menu:SetPoint("TOPLEFT", x-17, 0-y); -- there's 17 padding on the left of the dropdown
	menu:Show();

	return menu;
end


function PREC.BindButtonClick(self, button)

	if button == "LeftButton" or button == "RightButton" then
		if (self.waitingForKey) then
			self:EnableKeyboard(false);
			self:UnlockHighlight();
			self.waitingForKey = nil;
			print("2nd click - stop waiting");
		else
			self:EnableKeyboard(true);
			self:LockHighlight();
			self.waitingForKey = true;
			print("waiting...");
		end
	end
end

function PREC.BindButtonKeyDown(self, key)

	if (not self.waitingForKey) then print("key down while not waiting"); return; end

	if (key == "BUTTON1") then return; end
	if (key == "BUTTON2") then return; end
	if (key == "UNKNOWN") then return; end
	if (key == "LSHIFT") then return; end
	if (key == "RSHIFT") then return; end
	if (key == "LCTRL") then return; end
	if (key == "RCTRL") then return; end
	if (key == "LALT") then return; end
	if (key == "RALT") then return; end

	local keyPressed = key;
	if (keyPressed == "ESCAPE") then
		keyPressed = ""
	else
		if IsShiftKeyDown() then
			keyPressed = "SHIFT-"..keyPressed
		end
		if IsControlKeyDown() then
			keyPressed = "CTRL-"..keyPressed
		end
		if IsAltKeyDown() then
			keyPressed = "ALT-"..keyPressed
		end
	end
	
	self:EnableKeyboard(false);
	self:UnlockHighlight();
	self.waitingForKey = nil;

	print("no more waiting");

	self:SetKey(keyPressed);
	--self:Fire("OnKeyChanged",keyPressed)
end


function PREC.CreateBindButton(parent, id, x, y, w, value)

	-- see Watcher\Libs\AceGUI-3.0\widgets\AceGUIWidget-Keybinding.lua

	local b = CreateFrame("Button", id, parent, "UIPanelButtonTemplate");
	b:SetPoint("TOPLEFT", x, 0-y)
	b:SetWidth(w)
	b:SetHeight(24)
	b:SetNormalTexture(texture);

	b.text = b:GetFontString();
	b.text:SetPoint("LEFT", b, "LEFT", 7, 0);
	b.text:SetPoint("RIGHT", b, "RIGHT", -7, 0);

	b.waitingForKey = false;

	b:SetScript("OnClick", PREC.BindButtonClick);
	b:SetScript("OnKeyDown", PREC.BindButtonKeyDown);
	--b:SetScript("OnMouseDown",Keybinding_OnMouseDown)
	b:RegisterForClicks("AnyDown");

	b.SetKey = function(self, value)
		if (value or "") == "" then
			self:SetText("Not Bound")
			self:SetNormalFontObject("GameFontNormal")
		else
			self:SetText(value)
			self:SetNormalFontObject("GameFontHighlight")
		end
	end

	b:SetKey(value);
	b:EnableMouse();
end


function PREC.RebuildFrame()

	local i;
	for i=1,PREC.options.max_prios do
		local key = 'p'..i;
		local prio = PREC.options.priorities[key];
		if (not prio) then prio = {}; end
		local ability = {};
		if (prio.which) then ability = PREC.abilities[prio.which]; end
		if (not ability) then ability = {}; end
		if (ability.icon) then
			PREC.rot_btns[key]:SetNormalTexture([[Interface\Icons\]] .. ability.icon);
		else
			PREC.rot_btns[key]:SetNormalTexture([[Interface\Icons\ability_hunter_pet_dragonhawk]]);
		end
	end
end

function PREC.GetBinds()

	local map = {};

	local i;
	for i=1,PREC.options.max_prios do
		local key = 'p'..i;
		local prio = PREC.options.priorities[key];
		prio = prio or {};
		local ability = PREC.abilities[prio.which];
		ability = ability or {};

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

function PREC.CheckBinds()

	if (PREC.waiting_for_bind) then
		-- we mind now be out of combat...
		PREC.BindKeys();
		return;
	end

	local binds = PREC.GetBinds();
	local dirty = false;

	local bind, cmd;
	for bind, cmd in pairs(binds) do

		if (bind and not bind == "") then

			local test = GetBindingAction(bind, true);
			if (not (test == cmd)) then
				--print(string.format("bad binding on %s (expecting %s, got %s)", bind,cmd,test));
				dirty = true;
			end
		end
	end

	if (dirty) then
		print("Precednece: Something is messing with our bindings. Check other addons.");
		PREC.BindKeys();
	end
end

function PREC.BindKeys()

	if (InCombatLockdown()) then
		if (not PREC.waiting_for_bind) then
			print("Waiting until combat ends to bind keys");
		end
		return ;
	end

	PREC.waiting_for_bind = false;

	local binds = PREC.GetBinds();
	local set = GetCurrentBindingSet();

	local bind, cmd;
	for bind, cmd in pairs(binds) do

		local ok = SetOverrideBinding(PREC.UIFrame, true, bind, cmd);
		-- TODO: report error if we can't bind...
	end
end

function PREC.HasViableTarget()
	local can_attack = UnitCanAttack("player", "target");
	if (can_attack and UnitIsDeadOrGhost("target")) then
		can_attack = false;
	end
	return can_attack;
end

function PREC.UpdateFrame()

	--
	-- are we showing the frame?
	--

	if (PREC.options.hide) then 
		return;
	end


	--
	-- on taxi?
	--

	if (UnitOnTaxi("player")) then
		PREC.UIFrame:Hide();
		return;
	end

	if (C_PetBattles.IsInBattle()) then
		PREC.UIFrame:Hide();
		return;
	end

	PREC.UIFrame:Show();


	--
	-- gather the data
	--

	local status = nil;

	if (PREC.options.demo_mode) then
		status = PREC.GatherDemoStatus();
	else
		status = PREC.GatherStatus();
	end


	--
	-- global sizing
	--

	PREC.fullW = 40 + 40 + PREC.options.runway;
	PREC.UIFrame:SetWidth(PREC.fullW)
	PREC.Cover:SetWidth(PREC.fullW)

	PREC.UIFrame:SetScale(PREC.options.scale);


	--
	-- display priorities
	--

	local done_at_limit = 0;
	local done_at_rdy = 0;
	local btns_at_limit = {};

	local info;
	for _, info in pairs(status.priorities) do

		local key = info.key;

		if (info.ok) then

			if (info.t > PREC.options.time_limit) then
				done_at_limit = done_at_limit + 1;
				PREC.rot_btns[key].label:SetText(string.format("%d", info.t));
				table.insert(btns_at_limit, PREC.rot_btns[key]);
			else
				local x = PREC.options.runway * info.t / PREC.options.time_limit;
				local y = 0;

				if (x < 40) then
					y = done_at_rdy * 10;
					done_at_rdy = done_at_rdy + 1;
				end

				PREC.rot_btns[key]:SetWidth(40);
				PREC.rot_btns[key]:SetHeight(40);
				PREC.rot_btns[key]:SetPoint("TOPLEFT", x, y);

				if (string.len(info.label) < 3) then
					PREC.SetFontSize(PREC.rot_btns[key].label, PREC.options.font_size_short);
				else
					PREC.SetFontSize(PREC.rot_btns[key].label, PREC.options.font_size);
				end

				PREC.rot_btns[key].label:SetText(info.label);
			end
		
			PREC.rot_btns[key]:Show();
		else
			PREC.rot_btns[key]:Hide();
		end

		if (status.has_viable_target) then

			PREC.rot_btns[key]:SetAlpha(1);
		else
			PREC.rot_btns[key]:SetAlpha(0.5);
		end
	end

	if (done_at_limit > 0) then

		local limit_size = 1;

		if (done_at_limit > 1) then limit_size = 2; end
		if (done_at_limit > 4) then limit_size = 3; end
		if (done_at_limit > 9) then limit_size = 4; end

		local icon_size = 40 / limit_size;
		local font_size = PREC.options.cooldown_size / limit_size;
		local x = 0;
		local y = 0;

		local btn;
		for _, btn in pairs(btns_at_limit) do

			local x_pos = x * icon_size;
			local y_pos = y * icon_size;

			btn:SetPoint("TOPLEFT", PREC.options.runway+40+x_pos, 0-y_pos);
			btn:SetWidth(icon_size)
			btn:SetHeight(icon_size)
			PREC.SetFontSize(btn.label, font_size);

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
	local label_mode = 'normal';

	if (status.show_label) then

		label = status.label;
		label_mode = status.label_mode;
	end

	if (status.active_shots == 0) then

		local inVehicle = UnitInVehicle("player");
		if (inVehicle) then
			PREC.UIFrame:Hide();
			return;
		end

		label_mode = 'normal';
		label = "No abilities configured - Right click to hide";
	end

	if (PREC.options.demo_mode) then
		label_mode = 'warning';
		label = "Demo Mode Active";
	end

	if (PREC.debug_data) then
		label_mode = 'warning';
		label = PREC.debug_data;
	end


	if (label_mode == 'warning') then
		PREC.Label:SetTextColor(1,0,0,1)
		PREC.SetFontSize(PREC.Label, PREC.options.warning_font_size);
	elseif (label_mode == 'mana') then
		PREC.Label:SetTextColor(0,0,1,1)
		PREC.SetFontSize(PREC.Label, PREC.options.warning_font_size);
	else
		PREC.Label:SetTextColor(1,1,1,1)
		PREC.SetFontSize(PREC.Label, PREC.options.label_font_size);
	end
	PREC.Label:SetText(label);


	--
	-- whole frame
	--

	if (status.has_viable_target) then
		--PREC.UIFrame:SetAlpha(1);
	else
		--PREC.UIFrame:SetAlpha(0.5);
	end


	--
	-- meters
	--

	local use_idx = 1;

	local mtr;
	for _, mtr in pairs(status.meters) do

		local key = 'm'..use_idx;
		use_idx = use_idx + 1;

		local label = PREC.FormatTime(mtr.t);
		if (mtr.label) then
			label = label .. " - " .. mtr.label;
		end
		if (mtr.special_label) then
			label = label .. " - " .. PREC.state[mtr.special_label];
		end

		local icon = mtr.icon;
		if (not icon) then icon = PREC.default_icon; end

		PREC.mtrs[key].btn:SetNormalTexture([[Interface\Icons\]] .. icon);
		PREC.mtrs[key].btn:SetPoint("TOPLEFT", 0, 0 - (40 + ((use_idx-2) * PREC.options.mtr_icon_size)));
		PREC.mtrs[key].btn:SetWidth(PREC.options.mtr_icon_size);
		PREC.mtrs[key].btn:SetHeight(PREC.options.mtr_icon_size);

		PREC.mtrs[key].bar.label:SetText(label);
		PREC.mtrs[key].bar:SetMinMaxValues(0, mtr.max);
		PREC.mtrs[key].bar:SetValue(mtr.t);
		PREC.mtrs[key].bar:SetPoint("TOPLEFT", PREC.options.mtr_icon_size, 0 - (40 + ((use_idx-2) * PREC.options.mtr_icon_size)));
		PREC.mtrs[key].bar:SetWidth(PREC.fullW - PREC.options.mtr_icon_size);
		PREC.mtrs[key].bar:SetHeight(PREC.options.mtr_icon_size);

		PREC.mtrs[key].bar:SetStatusBarColor(1, 1, 1);
		if (mtr.color == "green") then 	PREC.mtrs[key].bar:SetStatusBarColor(0, 1, 0); end
		if (mtr.color == "red") then 	PREC.mtrs[key].bar:SetStatusBarColor(1, 0, 0); end

		PREC.mtrs[key].bar:Show();
		PREC.mtrs[key].btn:Show();
	end

	local i;
	for i=use_idx,PREC.options.max_mtrs do
		local key = 'm'..i;
		PREC.mtrs[key].bar:Hide();
		PREC.mtrs[key].btn:Hide();
	end


	--
	-- warnings
	--

	local use_idx = 1;
	local px = 0;

	local warn;
	for _, warn in pairs(status.warnings) do

		local key = 'w'..use_idx;
		use_idx = use_idx + 1;

		local icon = warn.icon;
		if (not icon) then icon = PREC.default_icon_full; end;

		PREC.warn_btns[key].texture:SetTexture(icon);
		PREC.warn_btns[key].title = warn.title;

		if (warn.tex_coords) then
			PREC.warn_btns[key].texture:SetTexCoord(warn.tex_coords[1], warn.tex_coords[2], warn.tex_coords[3], warn.tex_coords[4]);
		else
			PREC.warn_btns[key].texture:SetTexCoord(0, 1, 0, 1);
		end


		local size = 20;
		if (warn.scale) then
			size = size * warn.scale;
		end

		PREC.PositionWarning(PREC.warn_btns[key], size, px);
		PREC.warn_btns[key]:Show();

		px = px + size;
	end

	local i;
	for i=use_idx,PREC.options.max_warns do
		local key = 'w'..i;
		PREC.warn_btns[key]:Hide();
	end

end

function PREC.PositionWarning(btn, size, x)

	btn:ClearAllPoints();
	btn:SetPoint("TOPRIGHT", 0-x, size);

	btn:SetWidth(size);
	btn:SetHeight(size);

	btn.border:SetWidth(math.floor(size * 62/36));
	btn.border:SetHeight(math.floor(size * 62/36));
end

function PREC.GatherStatus()

	local ret = {};

	ret.has_viable_target = UnitCanAttack("player", "target");
	if (ret.has_viable_target and UnitIsDeadOrGhost("target")) then
		ret.has_viable_target = false;
	end

	ret.active_shots = 0;
	ret.priorities = {};

	PREC.current_shots = {};

	local i;
	for i=1,PREC.options.max_prios do
		local key = 'p'..i;
		local prio = PREC.options.priorities[key];
		prio = prio or {};
		local ability = PREC.abilities[prio.which];
		ability = ability or {};

		local ok = false;
		local t = 0;
		local waitmana = false;

		if (ability) then
			ok, t, waitmana = PREC.GetStatus(ability, prio);
		end
		if ((ok) and (not (prio.who == "any"))) then
			ok = PREC.CheckWho(prio.who);
		end

		if (ok) then
			ret.active_shots = ret.active_shots + 1;
		end

		local label = " ";
		if (prio.bind) then label = prio.bind; end
		if (prio.label) then label = prio.label; end

		local info = {
			key = key,
			ok = ok,
			waitmana = waitmana,
			t = t,
			label = label,
		};

		if (prio.which) then
			PREC.current_shots[prio.which] = info;
		end

		table.insert(ret.priorities, info);
	end


	--
	-- misc warning text
	--

	PREC.GetWarningLabel(ret);


	--
	-- meters
	--

	ret.meters = {};

	local key, info;
	for key, info in pairs(PREC.meterinfo) do

		if (PREC.options.meters[key] and info) then

			info.key = key;

			local temp = PREC.GetMeter(info);
			if (temp.multi) then
				local temp2;
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

	local key, info;
	for key, info in pairs(PREC.warningdefs) do

		if (PREC.options.warnings[key] and info) then

			local warn = PREC.GetWarning(key, info);
			if (warn.show) then
				table.insert(ret.warnings, warn);
			end
		end
	end

	--table.sort(ret.warnings, function(a,b) return a.max<b.max end);

	return ret;
end

function PREC.GatherDemoStatus()

	local ret = {};

	ret.has_viable_target = true;
	ret.show_warning = false;

	ret.active_shots = 0;
	ret.priorities = {};

	local i;
	for i=1,PREC.options.max_prios do
		local key = 'p'..i;
		local prio = PREC.options.priorities[key];
		local ability = PREC.abilities[prio.which];

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
				t = PREC.options.time_limit + 1;
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

	local key, info;
	for key, info in pairs(PREC.meterinfo) do

		if (PREC.options.meters[key] and info) then

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

	local key, info;
	for key, info in pairs(PREC.warningdefs) do

		if (PREC.options.warnings[key] and info) then

			info.key = key;
			info.show = true;
			info.scale = 1;

			table.insert(ret.warnings, info);
		end
	end

	--table.sort(ret.warnings, function(a,b) return a.max<b.max end);

	return ret;
end

function PREC.GetWarning(key, info)

	info.key = key;
	info.show = false;
	local def = PREC.warningdefs[key];

	if (def.scale) then
		info.scale = def.scale;
	end


	--
	-- check for a buff
	--

	if (def.has_buff) then

		local found_buff = false;

		local index = 1;
		while UnitBuff("player", index) do
			local name, _, _, count, _, _, buffExpires, caster = UnitBuff("player", index)
			if (name == def.has_buff) then
				found_buff = true;
			end
			index = index + 1
		end
		if (not found_buff) then
			info.show = true;
		end
		return info;
	end


	--
	-- custom warning functions
	--

	if (def.func) then
		def.func(info);
	end

	return info;
end

function PREC.InGroup()

	local np = GetNumSubgroupMembers();
	if (np > 0) then return true; end

	local nr = GetNumGroupMembers();
	if (nr > 0) then return true; end

	return false;
end

function PREC.HasPet()

	if (IsMounted()) then return false; end
	if (not UnitGUID("pet")) then return false; end
	if (UnitHealth("pet") == 0) then return false; end

	return true;
end

function PREC.GetStatus(ability, prio)

	local t = 0;
	local waitmana = false;
	local now = GetTime();

	if (ability.spell) then

		-- for some reason kill command will be enabled even 
		-- when you have no pet out. yeah, dumb
		if (ability.spell == "Kill Command") then
			if (not PREC.HasPet()) then
				return false, 0, false;
			end
		end

		local usable, nomana = IsUsableSpell(ability.spell);
		if (not usable) then
			if (nomana) then
				t = PREC.GetFocusTimeout(ability.spell);
				waitmana = true;
			else
				return false, 0, false;
			end			
		end

		local start, duration = GetSpellCooldown(ability.spell);
		if duration > 0 then
			local t2 = start + duration - now;
			if (t2 > t) then
				t = t2;
			end
		end


		-- check we'll have enough focus once we're done with the cast that's
		-- currently happening

		if (PREC.state.simulate_focus_loss_until > now) then

			local focus_test = PREC.GetFocusTimeout(ability.spell);

			if (focus_test > t) then
				t = focus_test;
			end
		end
	end

	if (ability.debuff) then

		local index = 1
		while UnitDebuff("target", index) do
			local name, _, _, count, _, _, debuffExpires, caster = UnitDebuff("target", index)
			if ((name == ability.debuff) and (caster == "player")) then

				-- if the debuff has no duration (like crows) then just 
				-- disable the ability completely until it clears.
				if (debuffExpires == 0) then
					return false, 0, false;
				end

				local t2 = debuffExpires - GetTime()
				if (t2 > t) then
					t = t2;
				end
			end
			index = index + 1
		end
	end

	-- wait until a buff falls off?
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

	-- wait until we have a buff?
	if (ability.havebuff) then

		local found_buff = false;

		local index = 1;
		while UnitBuff("player", index) do
			local name, _, _, count, _, _, buffExpires, caster = UnitBuff("player", index)
			if (name == ability.havebuff) then
				if (ability.buff_stacks) then
					if (ability.buff_stacks <= count) then
						found_buff = true;
					end
				else
					found_buff = true;
				end
			end
			index = index + 1
		end
		if (not found_buff) then
			return false, 0, false;
		end
	end

	-- not currently used...
	if (prio.waitbuff and false) then

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


	--
	-- delay spell until
	--

	if (ability.delay_recast_for) then

		-- if we're within cast time + X seconds of casting, just hide this.
		-- we'll assume it will apply to target and so does not
		-- need casting for a while.

		local delay_until = PREC.state.delay_spell_until[ability.spell];
		if (delay_until and delay_until + ability.delay_recast_for > now) then
			return false, 0, false;
		end
	end


	--
	-- custom handlers
	--

	if (ability.func) then

		local ret = ability.func(t, now, waitmana);

		if (ret.hide_now) then
			return false, 0, false;
		end

		if (ret.show_now) then
			return true, ret.t, ret.waitmana;
		end

		t = ret.t;
		waitmana = ret.waitmana;
	end


	if (ability.gainiss) then

		local temp = PREC.TimeToPlayerBuffExpires("Improved Steady Shot", false);

		if (temp >= 0) then
			if (temp > t) then
				t = temp;
			end
		else

			if (PREC.state.steady_shots_accum >= 2) then

				-- about to go into ISS, so take this out of rotation. once the
				-- ISS buff actually appears, it'll come back in at the point the
				-- buff will fall off
				return false, 0, false;
			end
		end
	end

	if (ability.chimerarefresh) then

		local serpent_off = PREC.TimeToTargetBuffExpires("Serpent Sting", false);
		local hunters_mark_off = PREC.TimeToTargetBuffExpires("Hunter's Mark", false);
		local marked_death_off = PREC.TimeToTargetBuffExpires("Marked for Death", false);

		if (serpent_off >= 0) then
			serpent_off = serpent_off - PREC.options.chimera_refresh_window;
			if (serpent_off < 0) then
				serpent_off = 0;
			end
		end

		local lowest_need = 1000;
		if (serpent_off >= 0 and serpent_off < lowest_need) then
			lowest_need = serpent_off;
		end
		if (hunters_mark_off >= 0 and hunters_mark_off < lowest_need) then
			lowest_need = hunters_mark_off;
		end
		if (marked_death_off >= 0 and marked_death_off < lowest_need) then
			lowest_need = marked_death_off;
		end
		if ((hunters_mark_off == -1) and (marked_death_off == -1)) then
			lowest_need = 0;
		end

		if (lowest_need == 1000) then
			return false, 0, false;
		end


		--
		-- we need it, in {lowest_need} seconds. wait that long if we're off cooldown
		--

		if (lowest_need > t) then
			t = lowest_need;
		end
	end

	-- delay everything during a channeled cast
	if (PREC.state.no_shots_until > now) then
		local no_min = PREC.state.no_shots_until - now;

		--PREC.debug_data = string.format("delaying %f", no_min);

		if (t < no_min) then
			t = no_min;
		end
	end

	return true, t, waitmana;
end

function PREC.TimeToPlayerBuffExpires(match_buff, player_cast)

	--
	-- returns the time until the specified buff falls off
	-- the player, or -1 if we don't have it
	--

	local index = 1
	while UnitBuff("player", index) do
		local name, _, _, count, _, _, buffExpires, caster = UnitBuff("player", index)
		if (name == match_buff) then
			if ((not player_cast) or (caster == "player")) then
				local t2 = buffExpires - GetTime()
				return t2;
			end
		end
		index = index + 1
	end

	return -1;
end

function PREC.TimeToTargetBuffExpires(match_buff, player_cast)

	local index = 1
	while UnitDebuff("target", index) do
		local name, _, _, count, _, _, debuffExpires, caster = UnitDebuff("target", index)
		if (name == match_buff) then
			if ((not player_cast) or (caster == "player")) then
				local t2 = debuffExpires - GetTime()
				return t2;
			end
		end
		index = index + 1
	end

	return -1;
end


function PREC.GetFocusTimeout(spell)

	local cost = PREC.SpellCost(spell);
	local current = UnitPower("player", SPELL_POWER_FOCUS);

	if (PREC.state.simulate_focus_loss_until > GetTime()) then

		current = current - PREC.state.simulate_focus_loss;
	end

	if (current >= cost) then
		return 0;
	end

	local needed = cost - current;

	local regen = 4 * ((100 + GetCombatRatingBonus(CR_HASTE_RANGED))/100);

	local guess = (needed / regen);

	-- why does this happen? 
	if (guess < 0) then return 0.5; end

	return guess;
end

function PREC.GetMeter(info)

	info.t = 0;
	info.max = 0;

	if (not info) then
		return info;
	end

	-- custom handlers
	if (PREC.meterinfo[info.key].func) then
		PREC.meterinfo[info.key].func(info);
		return info;
	end

	if (info.buff) then
		local temp = PREC.CheckBuff(UnitBuff, info.buff, "player", false);
		if (temp.t > 0) then
			info.t = temp.t;
			info.max = temp.max;
		end
	end

	if (info.debuff) then
		local temp = PREC.CheckBuff(UnitDebuff, info.debuff, "target", true);
		if (temp.t > 0) then
			info.t = temp.t;
			info.max = temp.max;
		end
	end

	if (info.spell) then
		local temp = PREC.CheckCooldown(info.spell);
		if (temp.usable and temp.t > 0) then
			info.t = temp.t;
			info.max = temp.max;
		end
	end

	if (info.petbuff) then
		local temp = PREC.CheckBuff(UnitBuff, info.petbuff, "pet", false);
		if (temp.t > 0) then
			info.t = temp.t;
			info.max = temp.max;
		end
	end

	return info;
end

function PREC.CopyTable(a)
	local b = {};
	local k, v;
	for k, v in pairs(a) do b[k] = v end
	return b;
end

function PREC.CheckCooldown(spell)

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

function PREC.CheckBuff(qfunc, buff, target, must_be_ours)

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


function PREC.CheckWho(who)
	local lvl = UnitLevel("target");
	local isIn, type = IsInInstance();

	if (who == 'boss') then
		if ((lvl == -1) or (lvl == PREC.max_char_level + 2)) then
			return true;
		end
	end
	if (who == 'raidboss') then
		if (((lvl == -1) or (lvl == PREC.max_char_level + 3)) and ((type == 'raid') or (type == 'none'))) then
			return true;
		end
	end

	return false;
end

function PREC.FormatTime(s)

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

function PREC.PeriodicCheck()
	--print('check!');
	PREC.CheckBinds();
end

function PREC.OnUpdate()
	if (not PREC.everything_ready) then
		return;
	end

	if (PREC.last_check +PREC.time_between_checks < GetTime()) then
		PREC.last_check = GetTime();
		PREC.PeriodicCheck();
	end

	if (PREC.options.hide) then 
		return;
	end

	PREC.UpdateFrame();
end


function PREC.SetFontSize(string, size)

	local Font, Height, Flags = string:GetFont()
	if (not (Height == size)) then
		string:SetFont(Font, size, Flags)
	end
end

function PREC.SetHide(a)
	PREC.options.hide = a;
	if (a) then
		PREC.UIFrame:Hide();
		PRECCheck1:SetChecked(false);
	else
		PREC.UIFrame:Show();
		PRECCheck1:SetChecked(true);
	end
	PREC.RebuildFrame();
	PREC.UpdateFrame();
end

function PREC.SetLocked(a)
	PREC.options.locked = a;
	PRECCheck2:SetChecked(a);
end

function PREC.ResetPos()
	PREC.Show();
	PREC.UIFrame:SetWidth(150);
	PREC.UIFrame:ClearAllPoints();
	PREC.UIFrame:SetPoint("CENTER", 0, 0);
end

function PREC.ToggleLock()
	if (PREC.options.locked) then
		PREC.SetLocked(false);
	else
		PREC.SetLocked(true);
	end
end

function PREC.ToggleHide()
	if (PREC.options.hide) then
		PREC.SetHide(false);
	else
		PREC.SetHide(true);
	end
end

function PREC.SimpleGCD()

	local start, duration = GetSpellCooldown(1462);
	if duration > 0 then
		return start + duration - GetTime()
	end

	return 0
end

function PREC.SpellCooldown(id)

	if (not IsUsableSpell(id)) then
		return 0;
	end

	local start, duration = GetSpellCooldown(id);
	if duration > 0 then
		return start + duration - GetTime()
	end

	return 0
end

function PREC.DebuffElseGCD(aName)
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

function PREC.SpellCastTime(spellName)
	local _, _, _, castTime = GetSpellInfo(spellName);
	return castTime;
end

function PREC.SpellCost(spellName)
	if (PREC.spell_costs[spellName]) then
		return PREC.spell_costs[spellName];
	end
	return 0;
end

function PREC.SlashCommand(msg, editbox)
	if (msg == 'show') then
		PREC.SetHide(false);
	elseif (msg == 'hide') then
		PREC.SetHide(true);
	elseif (msg == 'toggle') then
		PREC.ToggleHide();
	elseif (msg == 'reset') then
		PREC.ResetPos();
	elseif (msg == 'test') then
		-- put stuff here
	elseif (msg == 'reset-opts') then
		PREC.options = PREC.default_options;
	else
		print(L.CMD_HELP);
		print("   /prec show - "..L.CMD_HELP_SHOW);
		print("   /prec hide - "..L.CMD_HELP_HIDE);
		print("   /prec toggle - "..L.CMD_HELP_TOGGLE);
		print("   /prec reset - "..L.CMD_HELP_RESET);
	end
end


SLASH_PRECEDENCE1 = '/precedence';
SLASH_PRECEDENCE2 = '/prec';

SlashCmdList["PRECEDENCE"] = PREC.SlashCommand;


PREC.Frame = CreateFrame("Frame")
PREC.Frame:Show()
PREC.Frame:SetScript("OnEvent", PREC.OnEvent)
PREC.Frame:SetScript("OnUpdate", PREC.OnUpdate)
PREC.Frame:RegisterEvent("ADDON_LOADED")
PREC.Frame:RegisterEvent("PLAYER_LOGOUT")
PREC.Frame:RegisterEvent("PLAYER_LOGIN")
PREC.Frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
PREC.Frame:RegisterEvent("UNIT_SPELLCAST_SENT")

PREC.OnLoad()
