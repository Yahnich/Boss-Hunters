relic_eye_of_the_oligarch = class(relicBaseClass)

function relic_eye_of_the_oligarch:OnCreated(kv)
	if IsServer() then
		self.lastGoldCheck = self:GetParent():GetGold()
		self:StartIntervalThink(0.1)
	end
end

function relic_eye_of_the_oligarch:OnIntervalThink()
	AddFOWViewer( self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), self:GetParent():GetGold(), 0.1, false )
	if self.lastGoldCheck > self:GetParent():GetGold() then -- assume a purchase
		self:GetParent():SetGold(self:GetParent():GetGold() - 50, true)
	end
	self.lastGoldCheck = self:GetParent():GetGold()
end