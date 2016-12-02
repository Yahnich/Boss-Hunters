if Check_Aghanim == nil then
    print ( '[Check_Aghanim] creating Check_Aghanim' )
    Check_Aghanim = {} -- Creates an array to let us beable to index abilities_simple when creating new functions
    Check_Aghanim.__index = Check_Aghanim
end

function HasCustomScepter(unit)
	local Has_Scepter = false
	for itemSlot = 0, 5, 1 do
        local Item = unit:GetItemInSlot( itemSlot )
        if Item ~= nil and Item:GetName() == "item_ultimate_scepter" then
            Has_Scepter=true
        end
        print (Has_Scepter)
    end

	return Has_Scepter
end

function HasCustomItem(unit,item_to_check)
    local has_item = false
    if item_to_check ~= nil then
        for itemSlot = 0, 5, 1 do
            local Item = unit:GetItemInSlot( itemSlot )
            if Item ~= nil and Item:GetName() == item_to_check:GetName() then
                has_item=true
            end
        end
    end
    return has_item
end