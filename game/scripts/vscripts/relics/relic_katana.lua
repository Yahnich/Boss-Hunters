relic_katana = class(relicBaseClass)
function relic_katana:OnCreated()
	self:OnRefresh()
end

function relic_katana:OnRefresh()
	if IsServer() then
		self:GetParent():HookInModifier("GetModifierCriticalDamage", self)
	end
end

function relic_katana:OnDestroy()
	if IsServer() then
		self:GetParent():HookOutModifier("GetModifierCriticalDamage", self)
	end
end

function relic_katana:GetModifierCriticalDamage()
	if self:RollPRNG(20) then return 150 end
end