relic_unique_pocket_sand = class({})

function relic_unique_pocket_sand:OnIntervalThink()
	self:SetDuration(-1, true)
	self:StartIntervalThink(-1)
end

function relic_unique_pocket_sand:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function relic_unique_pocket_sand:OnTakeDamage(params)
	if params.unit == self:GetParent() and self:GetParent() ~= params.attacker and self:GetDuration() == -1 then
		local direction = CalculateDirection( params.unit, params.attacker )
		FindClearSpaceForUnit(params.unit, params.unit:GetAbsOrigin() + direction * 300, true)
		
		ApplyDamage({victim = params.attacker, attacker = params.unit, damage = params.unit:GetPrimaryStatValue() * 2.75, damage_type = DAMAGE_TYPE_PURE})
		
		self:SetDuration(12, true)
		self:StartIntervalThink(12)
	end
end

function relic_unique_pocket_sand:DestroyOnExpire()
	return false
end

function relic_unique_pocket_sand:IsPurgable()
	return false
end

function relic_unique_pocket_sand:RemoveOnDeath()
	return false
end

function relic_unique_pocket_sand:IsPermanent()
	return true
end

function relic_unique_pocket_sand:AllowIllusionDuplicate()
	return true
end

function relic_unique_pocket_sand:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end