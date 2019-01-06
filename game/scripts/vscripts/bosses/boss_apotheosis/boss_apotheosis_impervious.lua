boss_apotheosis_impervious = class({})

function boss_apotheosis_impervious:GetIntrinsicModifierName()
	return "modifier_boss_apotheosis_impervious"
end

modifier_boss_apotheosis_impervious = class({})
LinkLuaModifier( "modifier_boss_apotheosis_impervious", "bosses/boss_apotheosis/boss_apotheosis_impervious", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_apotheosis_impervious:OnCreated()
	self.limit = self:GetSpecialValueFor("max_hp_dmg") / 100
	self.breakLim = self:GetSpecialValueFor("break_hp_dmg") / 100
	self.minBlock = self:GetSpecialValueFor("min_block")
end

function modifier_boss_apotheosis_impervious:OnRefresh()
	self.limit = self:GetSpecialValueFor("max_hp_dmg") / 100
	self.breakLim = self:GetSpecialValueFor("break_hp_dmg") / 100
	self.minBlock = self:GetSpecialValueFor("min_block")
end

function modifier_boss_apotheosis_impervious:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK, MODIFIER_EVENT_ON_DEATH}
end

function modifier_boss_apotheosis_impervious:GetModifierTotal_ConstantBlock(params)
	local limit = TernaryOperator( self.breakLim, self:GetParent():PassivesDisabled(), self.limit )
	local maxHPBlock = self:GetParent():GetMaxHealth() * limit * ( GameRules.BasePlayers - HeroList:GetActiveHeroCount() )
	if params.damage > maxHPBlock then
		return params.damage - maxHPBlock
	elseif not self:GetParent():PassivesDisabled()
		return self.minBlock
	end
end

function modifier_boss_apotheosis_impervious:OnDeath(params)
	if params.unit == self:GetParent() then
		params.unit:EmitSound("Hero_ObsidianDestroyer.SanityEclipse.Cast")
		ParticleManager:FireParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_sanity_eclipse_area.vpcf", PATTACH_ABSORIGIN, params.unit, {[1] = Vector(500,1,1)})
	end
end

function modifier_boss_apotheosis_impervious:IsHidden()
	return true
end

function modifier_boss_apotheosis_impervious:IsPurgable()
	return false
end