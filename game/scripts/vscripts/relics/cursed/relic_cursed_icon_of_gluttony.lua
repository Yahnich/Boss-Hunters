relic_cursed_icon_of_gluttony = class({})

function relic_cursed_icon_of_gluttony:DeclareFunctions()
	return {MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE, MODIFIER_EVENT_ON_DEATH}
end

function relic_cursed_icon_of_gluttony:GetModifierHPRegenAmplify_Percentage()
	return -33
end

function relic_cursed_icon_of_gluttony:GetModifierMPRegenAmplify_Percentage()
	return -33
end

function relic_cursed_icon_of_gluttony:OnDeath(params)
	if params.attacker == self:GetParent() then
		local heal = 0.15
		local hero = self:GetParent()
		if not params.unit.Holdout_IsCore then heal = 0.01 end
		hero:HealEvent( hero:GetMaxHealth() * heal, nil, nil )
		hero:GiveMana( hero:GetMaxMana() * heal )
	end
end

function relic_cursed_icon_of_gluttony:IsHidden()
	return true
end

function relic_cursed_icon_of_gluttony:IsPurgable()
	return false
end

function relic_cursed_icon_of_gluttony:RemoveOnDeath()
	return false
end

function relic_cursed_icon_of_gluttony:IsPermanent()
	return true
end

function relic_cursed_icon_of_gluttony:AllowIllusionDuplicate()
	return true
end

function relic_cursed_icon_of_gluttony:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end