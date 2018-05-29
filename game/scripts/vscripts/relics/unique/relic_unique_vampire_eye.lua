relic_unique_vampire_eye = class(relicBaseClass)

function relic_unique_vampire_eye:OnCreated()	
	if IsServer() then
		self:StartIntervalThink(0)
	end
end

function relic_unique_vampire_eye:OnIntervalThink()
	if not GameRules:IsDaytime() then
		AddFOWViewer( self:GetParent():GetTeam(), self:GetParent():GetAbsOrigin(), 15000, 0.03, false)
	end
end