sylph_immaterialize = sylph_immaterialize or class({})

function sylph_immaterialize:OnSpellStart()
	EmitSoundOn("Ability.PowershotPull.Stinger", self:GetCaster())
	local windbuff = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_sylph_immaterialize_buff", {duration = self:GetSpecialValueFor("duration")})
end

LinkLuaModifier( "modifier_sylph_immaterialize_buff", "heroes/sylph/sylph_immaterialize.lua", LUA_MODIFIER_MOTION_HORIZONTAL )
modifier_sylph_immaterialize_buff = modifier_sylph_immaterialize_buff or class({})

function modifier_sylph_immaterialize_buff:OnCreated()
	self.movespeed = self:GetAbility():GetSpecialValueFor("movespeed_bonus")
	self.evasion = self:GetAbility():GetSpecialValueFor("evasion")
	if IsServer() then self:StartIntervalThink(0) end
end

function modifier_sylph_immaterialize_buff:OnIntervalThink()
	ProjectileManager:ProjectileDodge(self:GetCaster())
end

function modifier_sylph_immaterialize_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_EVASION_CONSTANT,
	}
	return funcs
end

function modifier_sylph_immaterialize_buff:GetModifierEvasion_Constant()
	return self.evasion
end

function modifier_sylph_immaterialize_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

function modifier_sylph_immaterialize_buff:GetEffectName()
	return "particles/heroes/sylph/sylph_immaterialize.vpcf"
end