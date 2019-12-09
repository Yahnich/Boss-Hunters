boss_ammetot_gatekeeper = class({})

function boss_ammetot_gatekeeper:GetIntrinsicModifierName()
	return "modifier_boss_ammetot_gatekeeper"
end

modifier_boss_ammetot_gatekeeper = class({})
LinkLuaModifier( "modifier_boss_ammetot_gatekeeper", "bosses/boss_ammetot/boss_ammetot_gatekeeper", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_ammetot_gatekeeper:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_boss_ammetot_gatekeeper:OnRefresh()
	self:OnCreated()
end

function modifier_boss_ammetot_gatekeeper:IsAura()
	return true
end

function modifier_boss_ammetot_gatekeeper:GetAuraRadius()
	return self.radius
end

function modifier_boss_ammetot_gatekeeper:GetAuraDuration()
	return 0.5
end

function modifier_boss_ammetot_gatekeeper:GetModifierAura()
	return "modifier_boss_ammetot_gatekeeper_debuff"
end

function modifier_boss_ammetot_gatekeeper:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_boss_ammetot_gatekeeper:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_boss_ammetot_gatekeeper:IsHidden()
	return true
end

modifier_boss_ammetot_gatekeeper_debuff = class({})
LinkLuaModifier( "modifier_boss_ammetot_gatekeeper_debuff", "bosses/boss_ammetot/boss_ammetot_gatekeeper", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_ammetot_gatekeeper_debuff:OnCreated()
	self.amp = self:GetSpecialValueFor("amp_loss")
	self.dmg = self:GetSpecialValueFor("dmg_loss")
end

function modifier_boss_ammetot_gatekeeper_debuff:OnRefresh()
	self:OnCreated()
end

function modifier_boss_ammetot_gatekeeper_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function modifier_boss_ammetot_gatekeeper_debuff:GetModifierSpellAmplify_Percentage()
	return self.amp
end

function modifier_boss_ammetot_gatekeeper_debuff:GetModifierPreAttack_BonusDamage()
	return self.dmg
end