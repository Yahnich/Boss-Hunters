relic_cursed_cursed_dice = class({})

function relic_cursed_cursed_dice:OnCreated()
	if IsServer() then
		local pID = self:GetParent():GetPlayerID()
		local rerolls = RelicManager:ClearRelics( pID )
		local bonusRolls = RandomInt(0, math.floor(rerolls/2) )
		for i = 1, rerolls + bonusRolls do
			local roll = RandomInt( 1, 3 )
			if roll == 1 then
				self:GetParent():AddRelic( RelicManager:RollRandomGenericRelicForPlayer(pID) )
			elseif roll == 2 then
				self:GetParent():AddRelic( RelicManager:RollRandomCursedRelicForPlayer(pID) )
			else
				self:GetParent():AddRelic( RelicManager:RollRandomUniqueRelicForPlayer(pID) )
			end
		end
	end
end

function relic_cursed_cursed_dice:IsHidden()
	return true
end

function relic_cursed_cursed_dice:IsPurgable()
	return false
end

function relic_cursed_cursed_dice:RemoveOnDeath()
	return false
end

function relic_cursed_cursed_dice:IsPermanent()
	return true
end

function relic_cursed_cursed_dice:AllowIllusionDuplicate()
	return true
end

function relic_cursed_cursed_dice:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end