relic_cursed_giants_cudgel = class({})

function relic_cursed_giants_cudgel:OnCreated()
	self.as = self:GetParent():GetIncreasedAttackSpeed() * (-40)
	self:StartIntervalThink(0.33)
end

function relic_cursed_giants_cudgel:OnIntervalThink()
	self.as = 0
	self.as = self:GetParent():GetIncreasedAttackSpeed() * (-40)
	print(self.as)
end

function relic_cursed_giants_cudgel:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function relic_cursed_giants_cudgel:GetModifierAttackSpeedBonus_Constant()
	return self.as
end

function relic_cursed_giants_cudgel:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		ParticleManager:FireParticle("particles/test_particle/ogre_melee_smash.vpcf", PATTACH_ABSORIGIN, params.target, {[1] = Vector(275,1,1)})
		for _, enemy in ipairs( params.attacker:FindEnemyUnitsInRadius( params.target:GetAbsOrigin(), 275 ) ) do
			ApplyDamage({victim = enemy, attacker = params.attacker, damage = params.original_damage, damage_type = DAMAGE_TYPE_PHYSICAL})
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

function relic_cursed_giants_cudgel:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end