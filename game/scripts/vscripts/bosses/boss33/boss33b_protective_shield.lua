boss33b_protective_shield = class({})

function boss33b_protective_shield:GetIntrinsicModifierName()
	return "modifier_boss33b_protective_shield"
end

modifier_boss33b_protective_shield = class({})
LinkLuaModifier("modifier_boss33b_protective_shield", "bosses/boss33/boss33b_protective_shield.lua", 0)

function modifier_boss33b_protective_shield:OnCreated()
	self.sdDeathDamageReduction = self:GetSpecialValueFor("sd_death_reduction")
end

function modifier_boss33b_protective_shield:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_boss33b_protective_shield:GetModifierIncomingDamage_Percentage(params)
	local sdAlive = self:GetParent():IsTwinAlive()
	if sdAlive and params.damage_type == DAMAGE_TYPE_MAGICAL then
		ParticleManager:FireParticle("particles/bosses/boss33/boss33b_protection_poof.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		return -9999
	elseif not sdAlive then
		return self.sdDeathDamageReduction
	end
end