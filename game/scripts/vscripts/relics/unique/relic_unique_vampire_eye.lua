relic_unique_vampire_eye = class({})

function relic_unique_vampire_eye:OnCreated()	
	if IsServer() then
		self:StartIntervalThink(0)
	end
end

function relic_unique_vampire_eye:OnIntervalThink()
	if not GameRules:IsDaytime() then
		AddFOWViewer( self:GetParent():GetTeam(), self:GetParent():GetAbsOrigin(), 15000, 0.03, false)
	end
end

function relic_unique_vampire_eye:IsHidden()
	return true
end

function relic_unique_vampire_eye:IsPurgable()
	return false
end

function relic_unique_vampire_eye:RemoveOnDeath()
	return false
end

function relic_unique_vampire_eye:IsPermanent()
	return true
end

function relic_unique_vampire_eye:AllowIllusionDuplicate()
	return true
end

function relic_unique_vampire_eye:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end