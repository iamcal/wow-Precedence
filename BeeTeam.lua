BT = {}

BT.fullW = 160;
BT.fullH = 100;


function BT.OnLoad()

end

function BT.OnReady()

	_G.BeeTeamDB = _G.BeeTeamDB or {};
	_G.BeeTeamDB.opts = _G.BeeTeamDB.opts or {};

	BTOptionsFrame.name = 'Bee Team';
	InterfaceOptions_AddCategory(BTOptionsFrame);

	BT.StartFrame();
end

function BT.ShowOptions()

	InterfaceOptionsFrame_OpenToCategory(BTOptionsFrame.name);
end

function BT.OptionClick(button, name)

	if (name == 'hide') then
		if (_G.BeeTeamDB.opts.hide) then
			BT.Show();
		else
			BT.Hide();
		end
	end

	if (name == 'lock') then
		BT.ToggleLock();
	end

end


function BT.OnSaving()

end


function BT.OnEvent(frame, event, ...)

	if (event == 'ADDON_LOADED') then
		local name = ...;
		if name == 'BeeTeam' then
			BT.OnReady();
		end
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

		BT.UIFrame:SetWidth(_G.BeeTeamDB.opts.frameW);
	end
	BT.UIFrame:SetPoint(frameRef, frameX, frameY);

	-- make it draggable
	BT.UIFrame:SetMovable(true);
	BT.UIFrame:EnableMouse(true);

	-- create the button
	--local d2 = BT.ItemData(_G.BeeTeamDB.opts.curItem);
	BT.Button = CreateFrame("Button", nil, BT.UIFrame)
	BT.Button:SetPoint("TOPLEFT", 1, -1)
	BT.Button:SetWidth(30)
	BT.Button:SetHeight(30)
	--BT.Button:SetNormalTexture(d2.itemTexture);
	BT.Button:SetScript("OnClick", BT.ShowMenu)


	-- some text to go over it
	BT.Label = BT.UIFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	BT.Label:SetPoint("CENTER", BT.UIFrame, "CENTER", 2, 0)
	BT.Label:SetJustifyH("LEFT")
	BT.Label:SetText("Test Text")
	BT.Label:SetTextColor(1,1,1,1)
	BT.SetFontSize(BT.Label, 10)


	-- aspect button
	BT.BtnRot1 = BT.CreateButton(0, 0, 40, 40, [[Interface\Icons\ability_hunter_pet_dragonhawk]]);
	BT.BtnRot2 = BT.CreateButton(40, 0, 40, 40, [[Interface\Icons\ability_hunter_pet_dragonhawk]]);
	BT.BtnRot3 = BT.CreateButton(80, 0, 40, 40, [[Interface\Icons\ability_hunter_pet_dragonhawk]]);
	BT.BtnRot4 = BT.CreateButton(120, 0, 40, 40, [[Interface\Icons\ability_hunter_pet_dragonhawk]]);

	BT.BtnAspect = BT.CreateButton(0, 40, 20, 20, [[Interface\Icons\ability_hunter_pet_dragonhawk]]);


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




	BT.UpdateFrame();

	if (_G.BeeTeamDB.opts.hide) then
		BT.UIFrame:Hide();
	else
		BT.UIFrame:Show();
	end
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
		func = function() BT.Hide() end,
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

	return b;
end

function BT.UpdateFrame()

end

function BT.SetFontSize(string, size)

	local Font, Height, Flags = string:GetFont()
	string:SetFont(Font, size, Flags)
end

function BT.Show()
	_G.BeeTeamDB.opts.hide = false;
	BT.UIFrame:Show();
	BTOptionsFrameCheck1:SetChecked(true);
end

function BT.Hide()
	_G.BeeTeamDB.opts.hide = true;
	BT.UIFrame:Hide();
	BTOptionsFrameCheck1:SetChecked(false);
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
		BT.Show();
	else
		BT.Hide();
	end
end

function BT.OnUpdate()

	if (BT.inSession and GetTime() > BT.sessionEnds) then

		BT.EndSession();
	end
end

function BT.SlashCommand(msg, editbox)
	if (msg == 'show') then
		BT.Show();
	elseif (msg == 'hide') then
		BT.Hide();
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

function BT.GetMode()

	local diff = GetInstanceDifficulty();
	local isIn, type = IsInInstance();

	if (not isIn) then
		return "-";
	end

	if (type == 'party' and diff == 1) then return "5N"; end
	if (type == 'party' and diff == 2) then return "5H"; end
	if (type == 'raid' and diff == 1) then return "10N"; end
	if (type == 'raid' and diff == 2) then return "25N"; end
	if (type == 'raid' and diff == 3) then return "10H"; end
	if (type == 'raid' and diff == 4) then return "25H"; end

	return "-";
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

BT.OnLoad()
