relic_spinning_top = class(relicBaseClass)

function relic_spinning_top:OnCreated()
	self:GetParent():HookInModifier("GetBaseAttackTime_Bonus", self)
end

function relic_spinning_top:OnDestroy()
	self:GetParent():HookOutModifier("GetBaseAttackTime_Bonus", self)
end

function relic_spinning_top:GetBaseAttackTime_Bonus()
	return -0.15
end