boss33a_protective_ward = class({})

function boss33a_protective_ward:GetIntrinsicModifierName()
	return "modifier_boss33a_protective_ward"
end

modifier_boss33a_protective_ward = class({})
LinkLuaModifier("modifier_boss33a_protective_ward", "bosses/boss33/boss33a_protective_ward.lua", 0)

function modifier_boss33a_protective_ward:OnCreated()
	self.sfDeathDamageReduction = self:GetSpecialValueFor("sf_death_reduction")
end

function modifier_boss33a_protective_ward:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_boss33a_protective_ward:GetModifierIncomingDamage_Percentage(params)
	local sfAlive = self:GetParent():IsTwinAlive()
	if sfAlive and (params.damage_type == DAMAGE_TYPE_PHYSICAL or params.damage_type == DAMAGE_TYPE_PURE) then
		ParticleManager:FireParticle("particles/bosses/boss33/boss33a_protection_poof.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		return -9999
	elseif not sfAlive then
		return self.sdDeathDamageReduction
	end
end

function modifier_boss33a_protective_ward:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		self:GetAbility():DealDamage(params.attacker, params.target, self:GetParent():GetAverageBaseDamage(), {damage_type = DAMAGE_TYPE_MAGICAL})
	end
end

