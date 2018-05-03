relic_cursed_boiling_blood = class({})

function relic_cursed_boiling_blood:OnCreated()
	if IsServer() then self:StartIntervalThink(1) end
end

function relic_cursed_boiling_blood:OnIntervalThink()
	local parent = self:GetParent()
	local enemies = parent:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), 600 )
	for _, enemy in ipairs( enemies ) do
		ApplyDamage({victim = enemy, attacker = parent, damage = parent:GetMaxHealth() * 0.02, damage_type = DAMAGE_TYPE_MAGICAL})
	end
	if #enemies > 0 then ApplyDamage({victim = parent, attacker = parent, damage = parent:GetHealth() * 0.02, damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL }) end
end

function relic_cursed_boiling_blood:IsHidden()
	return true
end

function relic_cursed_boiling_blood:IsPurgable()
	return false
end

function relic_cursed_boiling_blood:RemoveOnDeath()
	return false
end

function relic_cursed_boiling_blood:IsPermanent()
	return true
end

function relic_cursed_boiling_blood:AllowIllusionDuplicate()
	return true
end

function relic_cursed_boiling_blood:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end