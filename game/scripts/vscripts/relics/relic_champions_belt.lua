relic_champions_belt = class(relicBaseClass)

function relic_champions_belt:OnCreated()
	self:GetParent():HookInModifier("GetModifierAgilityBonusPercentage", self)
	self:GetParent():HookInModifier("GetModifierStrengthBonusPercentage", self)
end

function relic_champions_belt:OnDestroy()
	self:GetParent():HookOutModifier("GetModifierAgilityBonusPercentage", self)
	self:GetParent():HookOutModifier("GetModifierStrengthBonusPercentage", self)
end

function relic_champions_belt:GetModifierStrengthBonusPercentage()
	return 20
end

function relic_champions_belt:GetModifierAgilityBonusPercentage()
	return 20
end