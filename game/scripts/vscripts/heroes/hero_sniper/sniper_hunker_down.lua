sniper_hunker_down = class({})

function sniper_hunker_down:GetIntrinsicModifierName()
	return "modifier_sniper_hunker_down"
end

function sniper_hunker_down:OnSpellStart()	
	local caster = self:GetCaster()
	caster:AddNewModifier( caster, self, "modifier_sniper_take_aim_active_bh", {duration = self:GetSpecialValueFor("duration")} )
	
	EmitSoundOn( "Hero_Sniper.TakeAim.Cast", caster)
end

modifier_sniper_hunker_down = class({})
LinkLuaModifier( "modifier_sniper_hunker_down","heroes/hero_sniper/sniper_hunker_down.lua",LUA_MODIFIER_MOTION_NONE )
function modifier_sniper_hunker_down:OnCreated(table)
	self.range = self:GetSpecialValueFor("bonus_attack_range")
end

function modifier_sniper_hunker_down:OnRefresh(table)
	self:OnCreated()
end

function modifier_sniper_hunker_down:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS
	}
	return funcs
end

function modifier_sniper_hunker_down:GetModifierAttackRangeBonus()
	return self.range
end

function modifier_sniper_hunker_down:IsPurgeException()
	return false
end

function modifier_sniper_hunker_down:IsPurgable()
	return false
end

function modifier_sniper_hunker_down:IsHidden()
	return true
end

modifier_sniper_take_aim_active_bh = class({})
LinkLuaModifier( "modifier_sniper_take_aim_active_bh","heroes/hero_sniper/sniper_hunker_down.lua",LUA_MODIFIER_MOTION_NONE )

function modifier_sniper_take_aim_active_bh:OnCreated()
	self.chance = self:GetSpecialValueFor("bonus_headshot_chance")
	self.slow = self:GetSpecialValueFor("slow")
	
	self.talent1BonusRange = math.max( 0, self:GetSpecialValueFor("bonus_attack_range") * self:GetSpecialValueFor("passive_multiplier") - 1 )
	
	self.global_vision = self:GetSpecialValueFor("global_vision") == 1
	self.invisibility = self:GetSpecialValueFor("invisibility") == 1
	if self.global_vision and IsServer() then
		self:StartIntervalThink(0)
	end
end

function modifier_sniper_take_aim_active_bh:OnRefresh()
	self:OnCreated()
end

function modifier_sniper_take_aim_active_bh:OnIntervalThink()
	local caster = self:GetCaster()
	AddFOWViewer(caster:GetTeamNumber(), caster:GetAbsOrigin(), 3000, 0.05, false)
end

function modifier_sniper_take_aim_active_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL, MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_INVISIBILITY_LEVEL }
end

function modifier_sniper_take_aim_active_bh:CheckState()
	if self.invisibility  then
		return {[MODIFIER_STATE_INVISIBLE] = true}
	end
end

function modifier_sniper_take_aim_active_bh:GetModifierOverrideAbilitySpecial(params)
	if params.ability:GetName() == "sniper_headshot_bh" then
		local caster = params.ability:GetCaster()
		local specialValue = params.ability_special_value
		if specialValue == "chance" then
			return 1
		end
	end
end

function modifier_sniper_take_aim_active_bh:GetModifierOverrideAbilitySpecialValue(params)
	if params.ability:GetName() == "sniper_headshot_bh" then
		local caster = params.ability:GetCaster()
		local specialValue = params.ability_special_value
		if specialValue == "chance" then
			local flBaseValue = params.ability:GetLevelSpecialValueNoOverride( specialValue, params.ability_special_level )
			return flBaseValue + self.chance
		end
	end
end

function modifier_sniper_take_aim_active_bh:GetModifierAttackRangeBonus()
	return self.talent1BonusRange
end

function modifier_sniper_take_aim_active_bh:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_sniper_take_aim_active_bh:GetModifierInvisibilityLevel()
	if self.invisibility then return 1 end
end