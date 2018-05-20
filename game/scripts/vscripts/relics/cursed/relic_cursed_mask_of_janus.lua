relic_cursed_mask_of_janus = class({})

if IsServer() then
	function relic_cursed_mask_of_janus:RerollRelic()
		local hero = self:GetParent()
		local pID = hero:GetPlayerID()
		local relicList = {}
		for relic, item in pairs( hero.ownedRelics ) do
			if relic ~= relic_cursed_mask_of_janus then
				table.insert(relicList, relic)
			end
		end
		local relic = relicList[RandomInt(1, #relicList)]
		RelicManager:RemoveRelicOnPlayer(relic, pID)
		local roll = RandomInt( 1, 3 )
		if roll == 1 then
			hero:AddRelic( RelicManager:RollRandomGenericRelicForPlayer(pID) )
		elseif roll == 2 then
			hero:AddRelic( RelicManager:RollRandomCursedRelicForPlayer(pID) )
		else
			hero:AddRelic( RelicManager:RollRandomUniqueRelicForPlayer(pID) )
		end
	end
end

function relic_cursed_mask_of_janus:IsHidden()
	return true
end

function relic_cursed_mask_of_janus:IsPurgable()
	return false
end

function relic_cursed_mask_of_janus:RemoveOnDeath()
	return false
end

function relic_cursed_mask_of_janus:IsPermanent()
	return true
end

function relic_cursed_mask_of_janus:AllowIllusionDuplicate()
	return true
end

function relic_cursed_mask_of_janus:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end