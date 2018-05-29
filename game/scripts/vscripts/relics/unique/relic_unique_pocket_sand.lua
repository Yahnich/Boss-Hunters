relic_unique_pocket_sand = class(relicBaseClass)

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
		
		self:GetAbility():DealDamage(params.unit, params.attacker, params.unit:GetPrimaryStatValue(), {damage_type = DAMAGE_TYPE_PURE})
		
		self:SetDuration(12, true)
		self:StartIntervalThink(12)
	end
end

function relic_unique_pocket_sand:IsHidden()
	return false
end