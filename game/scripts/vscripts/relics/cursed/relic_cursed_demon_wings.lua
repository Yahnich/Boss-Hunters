relic_cursed_demon_wings = class({})

if IsServer() then
	function relic_cursed_demon_wings:OnCreated()
		self:StartIntervalThink(0.33)
	end
	
	function relic_cursed_demon_wings:OnIntervalThink()
		local caster = self:GetCaster()
		local point = caster:GetAbsOrigin()
		ParticleManager:FireParticle("particles/relics/relic_cursed_demon_wings_trail.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = point})
		local duration = 1
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( point, 300 ) ) do
			self:GetAbility():DealDamage( caster, enemy, caster:GetPrimaryStatValue(), {damage_type = DAMAGE_TYPE_MAGICAL} )
		end
	end
end

function relic_cursed_demon_wings:CheckState()
	return {[MODIFIER_STATE_FLYING] = true}
end

function relic_cursed_demon_wings:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function relic_cursed_demon_wings:GetModifierMoveSpeedBonus_Percentage()
	return -33
end

function relic_cursed_demon_wings:IsHidden()
	return true
end

function relic_cursed_demon_wings:IsPurgable()
	return false
end

function relic_cursed_demon_wings:RemoveOnDeath()
	return false
end

function relic_cursed_demon_wings:IsPermanent()
	return true
end

function relic_cursed_demon_wings:AllowIllusionDuplicate()
	return true
end

function relic_cursed_demon_wings:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end