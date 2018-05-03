relic_unique_eldritch_rune = class({})


function relic_unique_eldritch_rune:IsHidden()
	return true
end

function relic_unique_eldritch_rune:IsPurgable()
	return false
end

function relic_unique_eldritch_rune:RemoveOnDeath()
	return false
end

function relic_unique_eldritch_rune:IsPermanent()
	return true
end

function relic_unique_eldritch_rune:AllowIllusionDuplicate()
	return true
end

function relic_unique_eldritch_rune:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end