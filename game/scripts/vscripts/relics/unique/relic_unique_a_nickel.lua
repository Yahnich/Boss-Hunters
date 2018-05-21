relic_unique_a_nickel = class(relicBaseClass)

function relic_unique_a_nickel:OnCreated()
	if IsServer() then
		self:GetParent():AddGold(1500)
	end
end