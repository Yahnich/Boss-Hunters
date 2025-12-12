razor_storm_surge_bh = class({})

function razor_storm_surge_bh:GetIntrinsicModifierName()
	return "modifier_razor_storm_surge_bh_handle"
end

modifier_razor_storm_surge_bh_handle = class({})
LinkLuaModifier("modifier_razor_storm_surge_bh_handle", "heroes/hero_razor/razor_storm_surge_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_razor_storm_surge_bh_handle:OnCreated()
	self.duration = self:GetSpecialValueFor("duration")
end

function modifier_razor_storm_surge_bh_handle:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
	}
	return funcs
end

function modifier_razor_storm_surge_bh_handle:OnAbilityFullyCast(params)
	if IsServer() then
		if params.unit == self:GetParent() and not params.ability:IsItem() then
			local ability = self:GetAbility()
			local caster = self:GetCaster()
			local buff = params.unit:AddNewModifier(caster, ability, "modifier_razor_storm_surge_bh", {duration = self.duration})
			buff:AddIndependentStack()
		end
	end
end

function modifier_razor_storm_surge_bh_handle:IsHidden()
	return true
end

modifier_razor_storm_surge_bh = class({})
LinkLuaModifier("modifier_razor_storm_surge_bh", "heroes/hero_razor/razor_storm_surge_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_razor_storm_surge_bh:OnCreated()
	self.movespeed = self:GetSpecialValueFor("movespeed_bonus")
end

function modifier_razor_storm_surge_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_razor_storm_surge_bh:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed * self:GetStackCount()
end

function modifier_razor_storm_surge_bh:IsHidden()
	return false
end