POPUP_SYMBOL_PRE_PLUS = 0
POPUP_SYMBOL_PRE_MINUS = 1
POPUP_SYMBOL_PRE_SADFACE = 2
POPUP_SYMBOL_PRE_BROKENARROW = 3
POPUP_SYMBOL_PRE_SHADES = 4
POPUP_SYMBOL_PRE_MISS = 5
POPUP_SYMBOL_PRE_EVADE = 6
POPUP_SYMBOL_PRE_DENY = 7
POPUP_SYMBOL_PRE_ARROW = 8

POPUP_SYMBOL_POST_EXCLAMATION = 0
POPUP_SYMBOL_POST_POINTZERO = 1
POPUP_SYMBOL_POST_MEDAL = 2
POPUP_SYMBOL_POST_DROP = 3
POPUP_SYMBOL_POST_LIGHTNING = 4
POPUP_SYMBOL_POST_SKULL = 5
POPUP_SYMBOL_POST_EYE = 6
POPUP_SYMBOL_POST_SHIELD = 7
POPUP_SYMBOL_POST_POINTFIVE = 8

function gift_open(keys)
	local item_table = LoadKeyValues("scripts/kv/gift_result.kv")
	local caster = keys.caster
	local round = GameRules._roundnumber
	if GameRules._NewGamePlus == true then round = round + 36 end
	local item = keys.ability
	caster:RemoveItem(item)
	local Tier = "T1"

	if round>=10 and round <16 then Tier = "T2"
	elseif round>=16 and round <28 then Tier = "T3"
	elseif round >= 28 and round <36 then Tier = "T4"
	elseif round >= 36 and round <45 then Tier = "T5"
	elseif round >= 45 then Tier = "T6"
	end
	print ("tier :",Tier)
	local item_list = item_table[Tier]
	--DeepPrintTable (item_list)
	local len = 0
	for k,v in pairs( item_list ) do
		len = len + 1
	end

	local item_number = math.random(1,(len + 8))
	print (item_number)
	if item_number > len then
		local bonus_gold = ((round+1))*(100 + (item_number*5)) + 500
		local asura_core = 0
		if GameRules._NewGamePlus == true then 
			while bonus_gold>= 75000 do
				asura_core = asura_core + 1
				bonus_gold = bonus_gold - 50000
			end
		end
		ShowPopup( {
                        Target = caster,
                        PreSymbol = 0,
                        PostSymbol = 2,
                        Color = Vector( 255, 200, 33 ),
                        Duration = 1.5,
                        Number = bonus_gold,
                        pfx = "gold",
                        Player = PlayerResource:GetPlayer( caster:GetPlayerID() )
                        } )
		local totalgold = caster:GetGold() + bonus_gold
		caster:SetGold(0 , false)
	    caster:SetGold(totalgold, true)
	    if asura_core>0 then
	    	caster.Asura_Core = caster.Asura_Core + asura_core
	    	Timers:CreateTimer(1.0, function()
	    	ShowPopup( {
                        Target = caster,
                        PreSymbol = 0,
                        PostSymbol = 2,
                        Color = Vector( 255, 100, 33 ),
                        Duration = 0.5,
                        Number = asura_core,
                        pfx = "goldbounty",
                        Player = PlayerResource:GetPlayer( caster:GetPlayerID() )
                        } )
	    	end)
		end
	else
		local item_name = item_list[tostring(item_number)]
		local item_reward = CreateItem( item_name, caster, caster )
		caster:AddItem(item_reward)
	end
	
end

function ShowPopup( data )
    if not data then return end

    local target = data.Target or nil
    if not target then error( "ShowNumber without target" ) end
    local number = tonumber( data.Number or nil )
    local pfx = data.Type or "miss"
    local player = data.Player or nil
    local color = data.Color or Vector( 255, 255, 255 )
    local duration = tonumber( data.Duration or 1 )
    local presymbol = tonumber( data.PreSymbol or nil )
    local postsymbol = tonumber( data.PostSymbol or nil )

    local path = "particles/msg_fx/msg_" .. pfx .. ".vpcf"
    local particle = ParticleManager:CreateParticle(path, PATTACH_OVERHEAD_FOLLOW, target)
    if player ~= nil then
        local particle = ParticleManager:CreateParticleForPlayer( path, PATTACH_OVERHEAD_FOLLOW, target, player)
    end

    local digits = 0
    if number ~= nil then digits = #tostring( math.ceil(number) ) end
    if presymbol ~= nil then digits = digits + 1 end
    if postsymbol ~= nil then digits = digits + 1 end

    ParticleManager:SetParticleControl( particle, 1, Vector( presymbol, number, postsymbol ) )
    ParticleManager:SetParticleControl( particle, 2, Vector( duration, digits, 0 ) )
    ParticleManager:SetParticleControl( particle, 3, color )
end
