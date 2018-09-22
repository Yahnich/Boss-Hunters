relic_unique_rusty_dumbbell = class(relicBaseClass)

function relic_unique_rusty_dumbbell:OnCreated()
	if IsServer() then
		self:GetParent():SetAttributePoints( self:GetParent():GetAttributePoints() + 2 )
		CustomGameEventManager:Send_ServerToAllClients("dota_player_upgraded_stats", {playerID = pID} )
	end
end
