relic_unique_hawks_eye = class(relicBaseClass)

function relic_unique_hawks_eye:OnCreated()	
	if IsServer() then
		self:StartIntervalThink(0)
	end
end

function relic_unique_hawks_eye:OnIntervalThink()
	if GameRules:IsDaytime() then
		AddFOWViewer( self:GetParent():GetTeam(), self:GetParent():GetAbsOrigin(), 15000, 0.03, false)
	end
end