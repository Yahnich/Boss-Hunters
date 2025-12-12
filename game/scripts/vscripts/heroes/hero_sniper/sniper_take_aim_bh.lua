sniper_take_aim_bh = class({})

function sniper_take_aim_bh:GetIntrinsicModifierName()
	return "modifier_sniper_take_aim_bh"
end

function sniper_take_aim_bh:OnSpellStart()	
	local caster = self:GetCaster()
	caster:AddNewModifier( caster, self, "modifier_sniper_take_aim_active_bh", {duration = self:GetSpecialValueFor("duration")} )
	
	EmitSoundOn( "Hero_Sniper.TakeAim.Cast", caster)
end

modifier_sniper_take_aim_bh = class({})
LinkLuaModifier( "modifier_sniper_take_aim_bh","heroes/hero_sniper/sniper_take_aim_bh.lua",LUA_MODIFIER_MOTION_NONE )
function modifier_sniper_take_aim_bh:OnCreated(table)
	self.range = self:GetSpecialValueFor("bonus_attack_range")
end

function modifier_sniper_take_aim_bh:OnRefresh(table)
	self:OnCreated()
end

function modifier_sniper_take_aim_bh:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS
	}
	return funcs
end

function modifier_sniper_take_aim_bh:GetModifierAttackRangeBonus()
	return self.range
end

function modifier_sniper_take_aim_bh:IsPurgeException()
	return false
end

function modifier_sniper_take_aim_bh:IsPurgable()
	return false
end

function modifier_sniper_take_aim_bh:IsHidden()
	return true
end

modifier_sniper_take_aim_active_bh = class({})
LinkLuaModifier( "modifier_sniper_take_aim_active_bh","heroes/hero_sniper/sniper_take_aim_bh.lua",LUA_MODIFIER_MOTION_NONE )

function modifier_sniper_take_aim_active_bh:OnCreated()
	self.chance = self:GetSpecialValueFor("bonus_headshot_chance")
	self.slow = self:GetSpecialValueFor("slow")
	
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_sniper_take_aim_1")
	self.talent1BonusRange = math.max( 0, self:GetSpecialValueFor("bonus_attack_range") * (self:GetCaster():FindTalentValue("special_bonus_unique_sniper_take_aim_1") - 1) )
	if self.talent1 and IsServer() then
		self:StartIntervalThink(0)
	end
	
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_sniper_take_aim_2")
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
	if self.talent2 then
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
	if self.talent2 then return 1 end
end