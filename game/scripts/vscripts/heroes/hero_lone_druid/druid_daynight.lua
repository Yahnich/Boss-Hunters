druid_daynight = class({})

function druid_daynight:IsStealable()
    return false
end

function druid_daynight:IsHiddenWhenStolen()
    return false
end

function druid_daynight:OnSpellStart()
	local caster = self:GetCaster()

	print(GameRules:GetTimeOfDay())

	if GameRules:IsDaytime() then
		GameRules:SetTimeOfDay(0.2)
	else
		GameRules:SetTimeOfDay(1)
	end
end