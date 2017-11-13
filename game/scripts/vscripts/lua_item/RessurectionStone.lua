function Ressurection(keys)
	local killedUnit = EntIndexToHScript( keys.caster_entindex )
	local Item = keys.ability
	if not killedUnit:IsAlive() and Item:IsCooldownReady() then
		print ('BY THE POWER OF THE GREAT RESSURECTION STONE ! I CALL YOU SHINERON ! RESSURECT ME !')
		killedUnit.resurrectionStoned = true
		if not killedUnit:WillReincarnate() then
			Timers:CreateTimer(3,function()
				killedUnit:RespawnHero(false, false)
				killedUnit.resurrectionStoned = false
				Item:StartCooldown(60)
				if Item:GetCurrentCharges() > 1 then
					Item:SetCurrentCharges(Item:GetCurrentCharges()-1)
				else
					killedUnit:RemoveItem(Item)
				end
			end)
		end
	end
end