relic_cursed_giants_cudgel = class({})

function relic_cursed_giants_cudgel:OnCreated()
	self:StartIntervalThink(0.33)
end

function relic_cursed_giants_cudgel:OnIntervalThink()
	self.bat = 0
	self.bat = self:GetParent():GetBaseAttackTime() * 1.8
end

function relic_cursed_giants_cudgel:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT}
end

function relic_cursed_giants_cudgel:GetModifierBaseAttackTimeConstant()
	return self.bat
end

function relic_cursed_giants_cudgel:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		ParticleManager:FireParticle("particles/test_particle/ogre_melee_smash.vpcf", PATTACH_ABSORIGIN, params.target, {[1] = Vector(275,1,1)})
		for _, enemy in ipairs( params.attacker:FindEnemyUnitsInRadius( params.target:GetAbsOrigin(), 275 ) ) do
			if enemy ~= params.target then
				ApplyDamage({victim = enemy, attacker = params.attacker, damage = params.original_damage, damage_type = DAMAGE_TYPE_PHYSICAL})
			end
		end
	end
end

function relic_cursed_giants_cudgel:IsHidden()
	return true
end

function relic_cursed_giants_cudgel:IsPurgable()
	return false
end

function relic_cursed_giants_cudgel:RemoveOnDeath()
	return false
end

function relic_cursed_giants_cudgel:IsPermanent()
	return true
end

function relic_cursed_giants_cudgel:AllowIllusionDuplicate()
	return true
end