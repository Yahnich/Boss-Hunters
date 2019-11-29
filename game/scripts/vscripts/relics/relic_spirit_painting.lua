relic_spirit_painting = class(relicBaseClass)

function relic_spirit_painting:OnCreated()	
	if IsServer() then
		LinkLuaModifier( "modifier_relic_spirit_painting_debuff", "relics/relic_spirit_painting", LUA_MODIFIER_MOTION_NONE)
		self:OnIntervalThink()
		self:StartIntervalThink(12)
	end
end

function relic_spirit_painting:OnIntervalThink()
	self:SetDuration(12.1, true)
	for _, enemy in ipairs( self:GetParent():FindEnemyUnitsInRadius( self:GetParent():GetAbsOrigin(), -1 ) ) do
		if enemy:GetCurrentActiveAbility() then 
			self:SetStackCount(1) 
		else
			self:SetStackCount(0)
		end
		ParticleManager:FireParticle("particles/units/heroes/hero_invoker/invoker_sun_strike.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = enemy:GetAbsOrigin()})
		self:GetAbility():DealDamage( self:GetParent(), enemy, self:GetParent():GetPrimaryStatValue() * 2.5, {damage_type = DAMAGE_TYPE_MAGICAL})
		break
	end
end

function relic_spirit_painting:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end

function relic_spirit_painting:GetModifierSpellAmplify_Percentage()
	return 25 * self:GetStackCount()
end

function relic_spirit_painting:IsHidden()
	return false
end