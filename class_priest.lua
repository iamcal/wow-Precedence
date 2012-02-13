if select(2, UnitClass('player')) ~= "PRIEST" then return end

PREC.enable_for_class = true;

PREC.default_options.meters = {

	sw_pain = true,
	vampiric_touch = true,
	devouring_plague = true,
};

PREC.default_options.warnings = {

	fort = true,
	inner_fire = true,
	shadowform = true,
	vampiric_embrace = true;
};

PREC.rotations = {
	sp432 = {
		name = "Shadow Priest (4.3.2)",
		p1 = {
			which = "sw_pain",
			bind = "ALT-1",
			who = "any",
		},
		p2 = {},
		p3 = {
			which = "vampiric_touch",
			bind = "ALT-3",
			who = "any",
		},
		p4 = {
			which = "devouring_plague",
			bind = "ALT-4",
			who = "any",
		},
		p5 = {
			which = "mind_blast",
			bind = "ALT-2",
			who = "any",
		},
		p5 = {},
		p6 = {},
		p7 = {},
		p8 = {},
		p9 = {},
		p10 = {},
		p11 = {},
	},
};

PREC.default_options.priorities = PREC.rotations.sp432;

PREC.abilities = {
	sw_pain = {
		icon = "spell_shadow_shadowwordpain",
		spell = "Shadow Word: Pain",
		debuff = "Shadow Word: Pain",
	},
	mind_blast = {
		icon = "spell_shadow_unholyfrenzy",
		spell = "Mind Blast",
	},
	vampiric_touch = {
		icon = "spell_holy_stoicism",
		spell = "Vampiric Touch",
		debuff = "Vampiric Touch",
	},
	devouring_plague = {
		icon = "spell_shadow_devouringplague",
		spell = "Devouring Plague",
		debuff = "Devouring Plague",
	},
	sw_death = {
		icon = "spell_shadow_demonicfortitude",
		spell = "Shadow Word: Death",
		-- only above certain health?
	},
	archangel = {
		icon = "ability_priest_archangel",
		spell = "Archangel",
		-- only with stack of something
	},
	shadowfiend = {
		icon = "spell_shadow_shadowfiend",
		spell = "Shadowfiend",
		-- only at 80% mana
	},
	mind_flay = {
		icon = "spell_shadow_siphonmana",
		spell = "Mind Flay",
	},
};

PREC.meterinfo = {
	sw_pain = {
		icon = "spell_shadow_shadowwordpain",
		debuff = "Shadow Word: Pain",
		color = "green",
	},
	vampiric_touch = {
		icon = "spell_holy_stoicism",
		debuff = "Vampiric Touch",
		color = "green",
	},
	devouring_plague = {
		icon = "spell_shadow_devouringplague",
		debuff = "Devouring Plague",
		color = "green",
	},
}

PREC.warningdefs = {
	fort = {
		title = "Buffed: Fortitude",
		icon = "spell_holy_wordfortitude",
		has_buff = "Power Word: Fortitude",
	},
	inner_fire = {
		title = "Buffed: Inner Fire",
		icon = "spell_holy_innerfire",
		has_buff = "Inner Fire",
	},
	vampiric_embrace = {
		title = "Buffed: Vampiric Embrace",
		icon = "spell_shadow_unsummonbuilding",
		has_buff = "Vampiric Embrace",
	},
	shadowform = {
		title = "Shadowform",
		icon = "spell_shadow_shadowform",
		has_buff = "Shadowform",
	},
};

PREC.state.simulate_focus_loss_until = 0;
PREC.state.no_shots_until = 0;

function PREC.OnCombatLog(...)
end

function PREC.OnSpellCastSent(...)
end

function PREC.GetWarningLabel(ret)

	ret.show_warning = false;

	--
	-- range warning
	--

	local inShotRange = IsSpellInRange("Mind Blast");

	if ((ret.active_shots > 0) and ret.has_viable_target) then

		if (not (inShotRange == 1)) then

			ret.show_warning = true;
			ret.warning = 'Too Far';
			return;
		end
	end


	--
	-- mana warning
	--

	local cur_mana = UnitPower("player", 0);
	local max_mana = UnitPowerMax("player", 0);
	mana_percent = 100 * cur_mana / max_mana;

	if (mana_percent < 10) then

		ret.show_warning = true;
		ret.warning = string.format('Mana Low (%d%%)', mana_percent);
		return;
	end

end

--
-- ################################################## Warnings ##################################################
--

--function PREC.warningdefs.no_pet.func(info)
--end


--
-- ################################################## Meters ##################################################
--

--function PREC.meterinfo.trap_set.func(info)
--end
