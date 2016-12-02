require( "libraries/Timers" )

if RessurectionStone == nil then
	print ( '[RessurectionStone] creating RessurectionStone' )
	RessurectionStone = {} -- Creates an array to let us beable to index RessurectionStone when creating new functions
	RessurectionStone.__index = RessurectionStone
end
 
function RessurectionStone:new() -- Creates the new class
	print ( '[RessurectionStone] RessurectionStone:new' )
	o = o or {}
	setmetatable( o, RessurectionStone )
	return o
end

function RessurectionStone:start() -- Runs whenever the RessurectionStone.lua is ran
	print('[RessurectionStone] RessurectionStone started!')
end

function Ressurection(keys)
        local killedUnit = EntIndexToHScript( keys.caster_entindex )
        local Item = keys.ability
        if not killedUnit:IsAlive() and Item:IsCooldownReady() then
            print ('BY THE POWER OF THE GREAT RESSURECTION STONE ! I CALL YOU SHINERON ! RESSURECT ME !')
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
				Item:StartCooldown(60)
				Timers:CreateTimer(1.5,function()
					killedUnit:RespawnHero(false, false, false)
					if Item:GetCurrentCharges() > 1 then
						Item:SetCurrentCharges(Item:GetCurrentCharges()-1)
					else
						killedUnit:RemoveItem(Item)
					end
				end)
            end
        end
end