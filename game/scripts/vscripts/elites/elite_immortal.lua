elite_immortal = class({})

function elite_immortal:GetIntrinsicModifierName()
	return "modifier_elite_immortal"
end

modifier_elite_immortal = class({})
LinkLuaModifier("modifier_elite_immortal", "elites/elite_immortal", LUA_MODIFIER_MOTION_NONE)

function modifier_elite_immortal:OnCreated()
	self:OnRefresh()
	if IsServer() then
		self:AddEffect( ParticleManager:CreateParticle( "particles/units/elite_warning_defense_overhead.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() ) )
	end
end

function modifier_elite_immortal:OnRefresh()
	self.regen = self:GetSpecialValueFor("health_regen")
	self.hp = self:GetSpecialValueFor("health")
	self:GetParent():HookInModifier("GetModifierExtraHealthBonusPercentage", self)
end

function modifier_elite_immortal:OnDestroy()
	self:GetParent():HookOutModifier("GetModifierExtraHealthBonusPercentage", self)
end

function modifier_elite_immortal:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
			}
end

function modifier_elite_immortal:GetModifierHealthRegenPercentage()
	return self.regen
end

function modifier_elite_immortal:GetModifierExtraHealthBonusPercentage()
	return self.hp
end

function modifier_elite_immortal:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_elite_immortal:IsHidden()
	return true
end