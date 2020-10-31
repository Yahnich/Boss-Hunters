relic_phoenix_down = class(relicBaseClass)

function relic_phoenix_down:OnCreated()
	if IsServer() then
		self:GetParent():ModifyBonusMaxLives(1)
		self:GetParent():ModifyLives(1)
	end
end

function relic_phoenix_down:OnDestroy()
	if IsServer() then
		self:GetParent():ModifyLives(-1)
		self:GetParent():ModifyBonusMaxLives(-1)
	end
end