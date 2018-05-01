relic_unique_rusty_dumbbell = class({})

function relic_unique_rusty_dumbbell:OnCreated()
	if IsServer() then
		self:GetParent():SetAbilityPoints( self:GetParent():GetAbilityPoints() + 2 )
		CustomGameEventManager:Send_ServerToAllClients("dota_player_upgraded_stats", {playerID = pID} )
	end
end

function relic_unique_rusty_dumbbell:IsHidden()
	return true
end

function relic_unique_rusty_dumbbell:IsPurgable()
	return false
end

function relic_unique_rusty_dumbbell:RemoveOnDeath()
	return false
end

function relic_unique_rusty_dumbbell:IsPermanent()
	return true
end

function relic_unique_rusty_dumbbell:AllowIllusionDuplicate()
	return true
end

function relic_unique_rusty_dumbbell:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end