relic_cursed_demon_wings = class(relicBaseClass)

if IsServer() then
	function relic_cursed_demon_wings:OnCreated()
		self:StartIntervalThink(0.33)
	end
	
	function relic_cursed_demon_wings:OnIntervalThink()
		local caster = self:GetCaster()
		local point = caster:GetAbsOrigin()
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
	if not self:GetParent():HasModifier("relic_unique_ritual_candle") then return -33 end
end
