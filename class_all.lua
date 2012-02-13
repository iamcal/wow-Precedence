PREC.default_options.warnings.bad_weapon = true; -- fishing pole, lance
PREC.default_options.warnings.kirin_tor_ring = false;
PREC.default_options.warnings.guild_cloak = false;

PREC.warningdefs.bad_weapon = {
	title = "Bad Weapon Equipped",
	icon = [[Interface\Icons\inv_weapon_shortblade_05]],
	--not_implemented = true,
};

PREC.warningdefs.kirin_tor_ring = {
	title = "Kirin Tor Ring Equipped",
	icon = [[Interface\Icons\inv_jewelry_ring_74]],
};

PREC.warningdefs.guild_cloak = {
	title = "Guild Cloak Equipped",
	icon = [[Interface\Icons\inv_guild_cloak_alliance_a]],
};

function PREC.warningdefs.bad_weapon.func(info)

	local itemId = GetInventoryItemID("player", 16);

	if (not itemId) then return info; end

	local _, _, _, level, _, type, subtype = GetItemInfo(itemId);

	if (level) then
		if (level < 200) then info.show = true; end
	end

	if (type == "Weapon" and subtype == "Daggers"		) then return info; end
	if (type == "Weapon" and subtype == "Fist Weapons"	) then return info; end
	if (type == "Weapon" and subtype == "One-Handed Axes"	) then return info; end
	if (type == "Weapon" and subtype == "One-Handed Swords"	) then return info; end
	if (type == "Weapon" and subtype == "Polearms"		) then return info; end
	if (type == "Weapon" and subtype == "Staves"		) then return info; end
	if (type == "Weapon" and subtype == "Two-Handed Axes"	) then return info; end
	if (type == "Weapon" and subtype == "Two-Handed Swords"	) then return info; end

	info.show = true;
end

function PREC.warningdefs.kirin_tor_ring.func(info)

	local itemId1 = GetInventoryItemID("player", 11);
	local itemId2 = GetInventoryItemID("player", 12);

	if (itemId1 == 51560 or itemId2 == 51560) then info.show = true; end
	if (itemId1 == 48954 or itemId2 == 48954) then info.show = true; end
	if (itemId1 == 45688 or itemId2 == 45688) then info.show = true; end
	if (itemId1 == 40586 or itemId2 == 40586) then info.show = true; end
end

function PREC.warningdefs.guild_cloak.func(info)

	local itemId = GetInventoryItemID("player", 15);

	if (itemId == 63352) then info.show = true; end -- alliance 8hr
	if (itemId == 63353) then info.show = true; end -- horde 8hr
	if (itemId == 63206) then info.show = true; end -- alliance 4hr
	if (itemId == 63207) then info.show = true; end -- horde 4hr
	if (itemId == 65360) then info.show = true; end -- alliance 2hr
	if (itemId == 65274) then info.show = true; end -- horde 2hr
end
