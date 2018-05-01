relic_unique_hawks_eye = class({})

function relic_unique_hawks_eye:OnCreated()	
	if IsServer() then
		self:StartIntervalThink(0)
	end
end

function relic_unique_hawks_eye:OnIntervalThink()
	if GameRules:IsDaytime() then
		AddFOWViewer( self:GetParent():GetTeam(), self:GetParent():GetAbsOrigin(), 15000, 0.03, false)
	end
end

function relic_unique_hawks_eye:IsHidden()
	return true
end

function relic_unique_hawks_eye:IsPurgable()
	return false
end

function relic_unique_hawks_eye:RemoveOnDeath()
	return false
end

function relic_unique_hawks_eye:IsPermanent()
	return true
end

function relic_unique_hawks_eye:AllowIllusionDuplicate()
	return true
end

function relic_unique_hawks_eye:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end