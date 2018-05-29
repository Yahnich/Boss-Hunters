relic_cursed_giants_cudgel = class(relicBaseClass)

function relic_cursed_giants_cudgel:OnCreated()
	self.as = self:GetParent():GetIncreasedAttackSpeed() * (-40)
	self:StartIntervalThink(0.33)
end

function relic_cursed_giants_cudgel:OnIntervalThink()
	self.as = 0
	self.as = self:GetParent():GetIncreasedAttackSpeed() * (-40)
end

function relic_cursed_giants_cudgel:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function relic_cursed_giants_cudgel:GetModifierAttackSpeedBonus_Constant()
	if not self:GetParent():HasModifier("relic_unique_ritual_candle") then return self.as end
end

function relic_cursed_giants_cudgel:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		ParticleManager:FireParticle("particles/test_particle/ogre_melee_smash.vpcf", PATTACH_ABSORIGIN, params.target, {[1] = Vector(275,1,1)})
		for _, enemy in ipairs( params.attacker:FindEnemyUnitsInRadius( params.target:GetAbsOrigin(), 275 ) ) do
			ApplyDamage({victim = enemy, attacker = params.attacker, damage = params.original_damage, damage_type = DAMAGE_TYPE_PHYSICAL})
		end
	end
end