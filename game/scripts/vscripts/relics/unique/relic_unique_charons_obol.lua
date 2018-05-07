relic_unique_charons_obol = class({})

function relic_unique_charons_obol:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function relic_unique_charons_obol:OnIntervalThink()
	self:StartIntervalThink(-1)
	self:SetDuration(-1, true)
end

function relic_unique_charons_obol:GetModifierIncomingDamage_Percentage(params)
	if params.damage > self:GetParent():GetHealth() and self:GetDuration() == -1 then
		self:GetParent():SetHealth(1)
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_invulnerable", {duration = 5})
		self:SetDuration(35.1, true)
		self:StartIntervalThink(35)
		return -999
	end
end

function relic_unique_charons_obol:IsHidden()
	return self:GetDuration() == -1
end

function relic_unique_charons_obol:IsPurgable()
	return false
end

function relic_unique_charons_obol:DestroyOnExpire()
	return false
end


function relic_unique_charons_obol:RemoveOnDeath()
	return false
end

function relic_unique_charons_obol:IsPermanent()
	return true
end

function relic_unique_charons_obol:AllowIllusionDuplicate()
	return true
end

function relic_unique_charons_obol:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end