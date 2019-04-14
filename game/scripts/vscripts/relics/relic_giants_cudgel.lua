relic_giants_cudgel = class(relicBaseClass)

function relic_giants_cudgel:DeclareFunctions()
	return { MODIFIER_EVENT_ON_ATTACK_LANDED,
			 MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE }
end

function relic_giants_cudgel:GetModifierAttackSpeedBonusPercentage()
	if not self:GetParent():HasModifier("relic_ritual_candle") then return -40 end
end

function relic_giants_cudgel:GetModifierDamageOutgoing_Percentage()
	return 35
end

function relic_giants_cudgel:OnAttackLanded(params)
	if params.attacker == self:GetParent() and params.target then
		ParticleManager:FireParticle("particles/test_particle/ogre_melee_smash.vpcf", PATTACH_ABSORIGIN, params.target, {[1] = Vector(275,1,1)})
	end
end

function relic_giants_cudgel:GetModifierAreaDamage(params)
	return 100
end