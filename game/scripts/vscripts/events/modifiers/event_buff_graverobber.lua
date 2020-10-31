event_buff_graverobber_curse = class(relicBaseClass)

if IsServer() then
	function event_buff_graverobber_curse:OnCreated()
		self:GetParent():ModifyLives(-2)
		self:GetParent():ModifyBonusMaxLives(-2)
	end

	function event_buff_graverobber_curse:OnDestroy()
		self:GetParent():ModifyBonusMaxLives(2)
		self:GetParent():ModifyLives(2)
	end
end