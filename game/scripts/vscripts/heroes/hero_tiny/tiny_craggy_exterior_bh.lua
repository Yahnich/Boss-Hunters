tiny_craggy_exterior_bh = class({})
LinkLuaModifier("modifier_tiny_craggy_exterior_bh", "heroes/hero_tiny/tiny_craggy_exterior_bh", LUA_MODIFIER_MOTION_NONE)

function tiny_craggy_exterior_bh:GetIntrinsicModifierName()
	return "modifier_tiny_craggy_exterior_bh"
end

modifier_tiny_craggy_exterior_bh = class({})
function modifier_tiny_craggy_exterior_bh:OnCreated(table)
	self.armor = self:GetParent():GetPhysicalArmorValue(false) * self:GetSpecialValueFor("bonus_armor")/100
end

function modifier_tiny_craggy_exterior_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_tiny_craggy_exterior_bh:OnAttackLanded(params)
	if IsServer() then 
		if params.attacker ~= self:GetParent() and not self:GetParent():IsSameTeam(params.attacker) and self:RollPRNG(self:GetSpecialValueFor("chance")) then
			local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_tiny/tiny_craggy_hit.vpcf", PATTACH_POINT, self:GetParent())
						ParticleManager:SetParticleControlEnt(nfx, 0, self:GetParent(), PATTACH_POINT, "attch_hitloc", self:GetParent():GetAbsOrigin(), true)
						ParticleManager:SetParticleControlForward(nfx, 1, CalculateDirection(params.attacker, self:GetParent()))
						ParticleManager:ReleaseParticleIndex(nfx)

			local damage = self:GetParent():GetPhysicalArmorValue(false) * self:GetSpecialValueFor("damage")/100
			self:GetAbility():Stun(params.attacker, self:GetSpecialValueFor("stun_duration"), false)
			self:GetAbility():DealDamage(self:GetParent(), params.attacker, damage, {}, 0)
		end
	end
end

function modifier_tiny_craggy_exterior_bh:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_tiny_craggy_exterior_bh:IsHidden()
	return true
end