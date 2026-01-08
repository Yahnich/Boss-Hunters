sniper_hunker_down = class({})

function sniper_hunker_down:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier( caster, self, "modifier_sniper_hunker_down", {duration = self:GetSpecialValueFor("duration")} )
	EmitSoundOn( "Hero_Sniper.TakeAim.Cast", caster)
end

modifier_sniper_hunker_down = class({})
LinkLuaModifier("modifier_sniper_hunker_down", "heroes/hero_sniper/sniper_hunker_down", LUA_MODIFIER_MOTION_NONE)

function modifier_sniper_hunker_down:IsPurgeable()
	return false
end

function modifier_sniper_hunker_down:OnCreated()
	self:OnRefresh()
end

function modifier_sniper_hunker_down:OnRefresh()
	self.bonus_attack_range = self:GetSpecialValueFor("bonus_attack_range")
	self.bonus_headshot_chance = self:GetSpecialValueFor("bonus_headshot_chance")
	self.chance = self:GetSpecialValueFor("bonus_headshot_chance")
	self.slow = self:GetSpecialValueFor("slow")
	self.ms_bonus = self:GetSpecialValueFor("ms_bonus")
	if self.ms_bonus ~= 0 then
		self.speed = self.ms_bonus
	else
		self.speed = self.slow
	end

	self.invisibility = self:GetSpecialValueFor("invisibility")
	self.true_strike = self:GetSpecialValueFor("true_strike")
	self.armor = self:GetSpecialValueFor("armor")

	self.crit_chance = self:GetSpecialValueFor("crit_chance")
	self.crit_damage = self:GetSpecialValueFor("crit_damage")
	self.hp_regen = self:GetSpecialValueFor("hp_regen") / 100
	self.heal_interval = self:GetSpecialValueFor("heal_interval")

	if IsServer() then
		local headshot = self:GetCaster():FindModifierByName("modifier_sniper_critical_aim_handler")
		if headshot then headshot:ForceRefresh() end
	end

	if self.hp_regen ~= 0 then
		self:StartIntervalThink(self.heal_interval)
	end
end

function modifier_sniper_hunker_down:OnIntervalThink()
	local parent = self:GetParent()
	local caster = self:GetCaster()

	local maxHP = parent:GetMaxHealth() * self.hp_regen
	parent:HealEvent(maxHP * self.heal_interval, self:GetAbility(), caster)
end


function modifier_sniper_hunker_down:CheckState()
	if self.invisibility ~= 0 then
		return
		{
			[MODIFIER_STATE_INVISIBLE] = true,
			[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true
		}
	end
	if self.true_strike ~= 0 then
		return {[MODIFIER_STATE_CANNOT_MISS] = true}
	end
end

function modifier_sniper_hunker_down:DeclareFunctions()
	return
	{
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE
	}
end

function modifier_sniper_hunker_down:GetModifierOverrideAbilitySpecial(params)
	if params.ability:GetName() == "sniper_critical_aim" then
		local caster = params.ability:GetCaster()
		local specialValue = params.ability_special_value
		if specialValue == "proc_chance" or (specialValue == "proc_chance_max_chance" and self.bonus_headshot_chance > 0) then
			return 1
		end
	end
end

function modifier_sniper_hunker_down:GetModifierOverrideAbilitySpecialValue(params)
	if params.ability:GetName() == "sniper_critical_aim" then
		local caster = params.ability:GetCaster()
		local specialValue = params.ability_special_value
		if specialValue == "proc_chance" then
			local flBaseValue = params.ability:GetLevelSpecialValueNoOverride( specialValue, params.ability_special_level )
			return flBaseValue + self.chance
		elseif specialValue == "proc_chance_max_chance" then
			local flBaseValue = params.ability:GetLevelSpecialValueNoOverride( specialValue, params.ability_special_level )
			if flBaseValue > 0 then
				return flBaseValue + self.chance + self.bonus_headshot_chance
			end
		end
	end
end

function modifier_sniper_hunker_down:GetModifierPreAttack_CriticalStrike(params)
	if self:RollPRNG(self.crit_chance) then
		self.record = params.record
		return self.crit_damage
	end
end

function modifier_sniper_hunker_down:GetCritDamage()
	return self.crit_damage / 100
end

function modifier_sniper_hunker_down:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_sniper_hunker_down:GetModifierAttackRangeBonus()
	return self.bonus_attack_range
end

function modifier_sniper_hunker_down:GetModifierMoveSpeedBonus_Percentage()
	return self.speed
end

function modifier_sniper_hunker_down:GetModifierInvisibilityLevel()
	if self.invisibility ~= 0 then
		return 1
	else
		return 0
	end
end