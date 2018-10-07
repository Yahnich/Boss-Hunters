relic_cursed_evil_eye_amulet = class(relicBaseClass)

function relic_cursed_evil_eye_amulet:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0)
	end
end

function relic_cursed_evil_eye_amulet:OnIntervalThink()
	if not self:GetParent():HasModifier("relic_unique_ritual_candle") then
		AddFOWViewer( DOTA_TEAM_BADGUYS, self:GetParent():GetAbsOrigin(), 128, 0.03, false )
	end
	for _, enemy in ipairs( self:GetParent():FindEnemyUnitsInRadius( self:GetParent():GetAbsOrigin(), 3000 ) ) do
		AddFOWViewer( DOTA_TEAM_GOODGUYS, self:GetParent():GetAbsOrigin(), 128, 0.03, false )
	end
end
