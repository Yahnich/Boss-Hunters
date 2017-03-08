function Ressurection(keys)
        local killedUnit = EntIndexToHScript( keys.caster_entindex )
        local Item = keys.ability
        if not killedUnit:IsAlive() and Item:IsCooldownReady() then
            print ('BY THE POWER OF THE GREAT RESSURECTION STONE ! I CALL YOU SHINERON ! RESSURECT ME !')
			killedUnit.resurrectionStoned = true
            if killedUnit:GetName() == ( "npc_dota_hero_skeleton_king") then
                local ability = killedUnit:FindAbilityByName("skeleton_king_reincarnation")
				local delay = ability:GetSpecialValueFor("reincarnate_time")
				Timers:CreateTimer(delay+0.1,function()
					if not ability:IsCooldownReady() and not killedUnit:IsAlive() then
						Item:StartCooldown(60)
						killedUnit:RespawnHero(false, false, false)
						if Item:GetCurrentCharges() > 1 then
							Item:SetCurrentCharges(Item:GetCurrentCharges()-1)
						else
							killedUnit:RemoveItem(Item)
						end
					end
				end)
			else
				Timers:CreateTimer(3,function()
					killedUnit:RespawnHero(false, false, false)
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