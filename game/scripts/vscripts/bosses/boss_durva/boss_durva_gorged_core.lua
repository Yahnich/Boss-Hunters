boss_durva_gorged_core = class({})

function boss_durva_gorged_core:GetIntrinsicModifierName()
	return "modifier_boss_durva_gorged_core"
end

modifier_boss_durva_gorged_core = class({})
LinkLuaModifier( "modifier_boss_durva_gorged_core", "bosses/boss_durva/boss_durva_gorged_core", LUA_MODIFIER_MOTION_NONE )

function boss_durva_gorged_core:OnCreated()
	self.dmg = self:GetSpecialValueFor("stack_dmg")
	self.as = self:GetSpecialValueFor("stack_as")
	self.ms = self:GetSpecialValueFor("stack_ms")
	self.heroStacks = self:GetSpecialValueFor("hero_stacks")
	self:SetStackCount( 0 )
end

function boss_durva_gorged_core:OnRefresh()
	self:OnCreated()
end

function boss_durva_gorged_core:DeclareFunctions()
	return { MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_EVENT_ON_DEATH }
end

function boss_durva_gorged_core:GetModifierBaseDamageOutgoing_Percentage()
	return self.dmg * self:GetStackCount()
end

function boss_durva_gorged_core:GetModifierAttackSpeedBonus()
	return self.as * self:GetStackCount()
end

function boss_durva_gorged_core:GetModifierMoveSpeedBonus_Percentage()
	return self.ms * self:GetStackCount()
end

function boss_durva_gorged_core:OnDeath(params)
	if params.attacker == self:GetParent() then
		local stacks = 1
		if params.unit:IsRealHero() then
			stacks = self.heroStacks
		end
		self:SetStackCount( self:GetStackCount() + stacks )
	end
end