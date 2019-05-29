item_vaudevilles_mystery_box = class({})

function item_vaudevilles_mystery_box:IsConsumable()
	return true
end

function item_vaudevilles_mystery_box:OnSpellStart()
	if self:GetCaster():IsAlive() then
		local pID = self:GetCaster():GetPlayerID()
		
		RelicManager:PushCustomRelicDropsForPlayer(pID, {RelicManager:RollRandomRelicForPlayer(pID)})
		self:Destroy()
	end
end