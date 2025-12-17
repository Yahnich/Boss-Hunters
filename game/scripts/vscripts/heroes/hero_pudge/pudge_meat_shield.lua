pudge_meat_shield = class({})

function pudge_meat_shield:OnSpellStart()
	local caster = self:GetCaster()
	
	local duration = self:GetSpecialValueFor("duration")
	caster:AddNewModifier( caster, self, "modifier_pudge_meat_shield_buff", {duration = duration} )
end

LinkLuaModifier("modifier_pudge_meat_shield_buff", "heroes/hero_pudge/pudge_meat_shield.lua", LUA_MODIFIER_MOTION_NONE)
modifier_pudge_meat_shield_buff = class({})

function modifier_pudge_meat_shield_buff:OnCreated()
	self:OnRefresh()
end

function modifier_pudge_meat_shield_buff:OnRefresh()
	self.block = self:GetSpecialValueFor("damage_block")
	self.status_resistance = self.block * self:GetSpecialValueFor("status_resistance") / 100
	self.strength_pct = self:GetParent():GetStrength() * self:GetSpecialValueFor("meat_shield_bonus") / 100
	self.size_pct = self:GetSpecialValueFor("meat_shield_bonus")
end

function modifier_pudge_meat_shield_buff:CheckState()
	if self.phased_movement then
		return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
	end
end

function modifier_pudge_meat_shield_buff:DeclareFunctions()
	return { MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK
			 MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
			 MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_MODEL_SCALE }
end

function modifier_pudge_meat_shield_buff:GetModifierTotal_ConstantBlock()
	return self.block
end

function modifier_pudge_meat_shield_buff:GetModifierStatusResistanceStacking()
	return self.status_resistance
end

function modifier_pudge_meat_shield_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.bonus_ms
end

function modifier_pudge_meat_shield_buff:GetModifierBonusStats_Strength()
	return self.strength_pct
end

function modifier_pudge_meat_shield_buff:GetModifierModelScale()
	return self.size_pct
end

function modifier_pudge_meat_shield_buff:GetEffectName()
	return "particles/units/heroes/hero_pudge/pudge_fleshheap_block_activation.vpcf"
end