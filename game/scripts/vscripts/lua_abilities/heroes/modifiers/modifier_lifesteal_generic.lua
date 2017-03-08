modifier_lifesteal_generic = class({})

function modifier_lifesteal_generic:OnCreated()
	self.lifesteal = self.lifesteal or self:GetStackCount()
end

function modifier_lifesteal_generic:IsHidden()
	return true
end

function modifier_lifesteal_generic:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_ATTACK_LANDED
			}
	return funcs
end

function modifier_lifesteal_generic:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			local flHeal = params.original_damage * (1 - params.target:GetPhysicalArmorReduction() / 100 ) * self.lifesteal / 100
			params.attacker:Heal(flHeal, params.attacker)
			local lifesteal = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.attacker)
				ParticleManager:SetParticleControlEnt(lifesteal, 0, params.attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", params.attacker:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(lifesteal, 1, params.attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", params.attacker:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(lifesteal)
		end
	end
end