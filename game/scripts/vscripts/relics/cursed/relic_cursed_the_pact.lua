relic_cursed_the_pact = class({})

function relic_cursed_the_pact:DeclareFunctions()
	return {MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE, MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function relic_cursed_the_pact:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		local heal = math.min( params.attacker:GetHealthDeficit(), params.damage )
		if heal > 0 then
			SendOverheadEventMessage(params.attacker, OVERHEAD_ALERT_HEAL, params.attacker, heal, params.attacker)
			params.attacker:SetHealth( math.max( math.min( params.attacker:GetMaxHealth(), params.attacker:GetHealth() + heal ), 1 ) )
		end
		
	end
end

function relic_cursed_the_pact:GetModifierDamageOutgoing_Percentage()
	return 100
end

function relic_cursed_the_pact:GetModifierHealAmplify_Percentage(params)
	-- regen has no caster
	-- other heals have abilities
	print(params.target == self:GetParent(), params.healer, params.ability)
	if not (params.target == self:GetParent() and params.healer and not params.ability) then
		return -100
	end
end

function relic_cursed_the_pact:IsHidden()
	return true
end

function relic_cursed_the_pact:IsPurgable()
	return false
end

function relic_cursed_the_pact:RemoveOnDeath()
	return false
end

function relic_cursed_the_pact:IsPermanent()
	return true
end

function relic_cursed_the_pact:AllowIllusionDuplicate()
	return true
end