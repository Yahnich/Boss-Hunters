generic_gold_dropper = class({})

function generic_gold_dropper:GetIntrinsicModifierName()
	return "modifier_generic_gold_dropper"
end

function generic_gold_dropper:IsStealable()
	return false
end

modifier_generic_gold_dropper = class({})
LinkLuaModifier("modifier_generic_gold_dropper", "generic/generic_gold_dropper.lua", 0)

function modifier_generic_gold_dropper:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_generic_gold_dropper:GetModifierIncomingDamage_Percentage(params)
	local parent = self:GetParent()
	for _, hero in ipairs( HeroList:GetRealHeroes() ) do
		hero:AddGold( math.min( 50, math.max( math.ceil(math.sqrt(params.damage/10)), 2 ) ) )
	end
	if params.damage > 0 then
		return -999
	end
end

function modifier_generic_gold_dropper:IsHidden()
	return false
end