relic_false_idol = class(relicBaseClass)

function relic_false_idol:OnCreated()
	self.damagePct = 0.20
	if IsServer() then
		self.lastPos = self:GetParent():GetAbsOrigin()
		self:StartIntervalThink(0.1)
	end
end

function relic_false_idol:OnIntervalThink()
	if RoundManager:IsRoundGoing() and not self:GetParent():HasModifier("relic_ritual_candle") then
		local damage = math.floor( math.min( CalculateDistance( self.lastPos, self:GetParent():GetAbsOrigin() ), 1200 ) ) * self.damagePct
		self.lastPos = self:GetParent():GetAbsOrigin()
		if damage > 0 then
			local flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_BYPASSES_BLOCK
			self:GetAbility():DealDamage( self:GetParent(), self:GetParent(), damage, {damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = flags})
		end
	end
end

function relic_false_idol:DeclareFunctions()
	return {MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING}
end
function relic_false_idol:GetModifierCastRangeBonusStacking(params)
	return 900
end