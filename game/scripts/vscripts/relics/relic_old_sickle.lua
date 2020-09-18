relic_old_sickle = class(relicBaseClass)

function relic_old_sickle:OnCreated()
	self:GetParent():HookInModifier( "GetModifierAreaDamage", self )
end

function relic_old_sickle:OnDestroy()
	self:GetParent():HookOutModifier( "GetModifierAreaDamage", self )
end

function relic_old_sickle:GetModifierAreaDamage(params)
	return 25
end