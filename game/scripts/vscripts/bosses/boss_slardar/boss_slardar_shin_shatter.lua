boss_slardar_shin_shatter = class({})

function boss_slardar_shin_shatter:IsStealable()
	return false
end

function boss_slardar_shin_shatter:GetIntrinsicModifierName()
	return "modifier_boss_slardar_shin_shatter"
end

modifier_boss_slardar_shin_shatter = class({})
LinkLuaModifier( "modifier_boss_slardar_shin_shatter", "bosses/boss_slardar/boss_slardar_shin_shatter", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_slardar_shin_shatter:OnCreated()
	self.chance = self:GetSpecialValueFor("chance")
	self.duration = self:GetSpecialValueFor("duration")
end

function modifier_boss_slardar_shin_shatter:OnRefresh()
	self.chance = self:GetSpecialValueFor("chance")
	self.duration = self:GetSpecialValueFor("duration")
end

function modifier_boss_slardar_shin_shatter:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_boss_slardar_shin_shatter:OnAttackLanded(params)
	if params.attacker == self:GetParent() and self:RollPRNG(self.chance) then
		local ability = self:GetAbility()
		params.target:AddNewModifier( params.attacker, ability, "modifier_boss_slardar_shin_shatter_slow", {duration = self.duration} )
		params.target:EmitSound("Hero_Slardar.Bash")
	end
end

function modifier_boss_slardar_shin_shatter:IsHidden()
	return true
end

function modifier_boss_slardar_shin_shatter:IsPurgable()
	return false
end

modifier_boss_slardar_shin_shatter_slow = class({})
LinkLuaModifier( "modifier_boss_slardar_shin_shatter_slow", "bosses/boss_slardar/boss_slardar_shin_shatter", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_slardar_shin_shatter_slow:OnCreated()
	self.slow = self:GetSpecialValueFor("slow")
end

function modifier_boss_slardar_shin_shatter_slow:OnRefresh()
	self:OnCreated()
end

function modifier_boss_slardar_shin_shatter_slow:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_boss_slardar_shin_shatter_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_boss_slardar_shin_shatter_slow:GetModifierAttackSpeedBonusPercentage()
	return self.slow
end

function modifier_boss_slardar_shin_shatter_slow:GetEffectName()
	return "particles/items2_fx/sange_maim.vpcf"
end
