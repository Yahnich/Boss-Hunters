item_fruit_of_knowledge = class({})

function item_fruit_of_knowledge:IsConsumable()
	return true
end

function item_fruit_of_knowledge:OnSpellStart()
	if self:GetCaster():IsAlive() then
		local caster = self:GetCaster()
		
		caster:SetAbilityPoints( caster:GetAbilityPoints() + 1 )
		CustomGameEventManager:Send_ServerToAllClients("dota_player_talent_update", {PlayerID = pID, hero_entindex = entindex} )
		self:Destroy()
	end
end