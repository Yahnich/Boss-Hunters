item_illusionists_charm = class({})

function item_illusionists_charm:OnSpellStart()
	local caster = self:GetCaster()
	local targetPos = self:GetCursorPosition()
	local ogPos = caster:GetAbsOrigin()
	
	local maxIllus = self:GetSpecialValueFor("illusion_count")
	for i = 1, maxIllus do
		local illusion = caster:ConjureImage( ogPos + RandomVector(150), self:GetSpecialValueFor("duration"), -(100 - self:GetSpecialValueFor("illu_outgoing_damage")), self:GetSpecialValueFor("illu_incoming_damage") - 100 )
		illusion:SetThreat( caster:GetThreat() )
	end
end

function item_illusionists_charm:GetIntrinsicModifierName()
	return "modifier_item_illusionists_charm"
end

modifier_item_illusionists_charm = class({})
LinkLuaModifier("modifier_item_illusionists_charm", "items/item_illusionists_charm", LUA_MODIFIER_MOTION_NONE)

function modifier_item_illusionists_charm:OnCreated()
	self.agility = self:GetSpecialValueFor("bonus_agility")
	self.attackSpeed = self:GetSpecialValueFor("bonus_attackspeed")
	self.regen = self:GetSpecialValueFor("bonus_hp_regen")
	self.bonusHP = self:GetSpecialValueFor("hp_per_str")
	self.stat = self:GetSpecialValueFor("bonus_strength")
end

function modifier_item_illusionists_charm:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_HEALTH_BONUS,
			MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,	
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			}
end

function modifier_item_illusionists_charm:GetModifierAttackSpeedBonus_Constant()
	return self.attackSpeed
end

function modifier_item_illusionists_charm:GetModifierBonusStats_Agility()
	return self.agility
end

function modifier_item_illusionists_charm:GetModifierBonusStats_Strength()
	return self.stat
end

function modifier_item_illusionists_charm:GetModifierHealthBonus()
	return self:GetParent():GetStrength() * self.bonusHP
end

function modifier_item_illusionists_charm:GetModifierHealthRegenPercentage()
	return self.regen
end

function modifier_item_illusionists_charm:IsHidden()
	return true
end