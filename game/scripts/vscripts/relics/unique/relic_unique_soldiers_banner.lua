relic_unique_soldiers_banner = class({})

function relic_unique_soldiers_banner:OnCreated()
	self.ar = 150 - self:GetParent():GetAttackRange()
	if IsServer() then
		self:GetParent():SetAttackCapability( DOTA_UNIT_CAP_MELEE_ATTACK )
		self:StartIntervalThink(0)
	end
end

function relic_unique_soldiers_banner:OnIntervalThink()
	self.ar = 0
	self.ar = 150 - self:GetParent():GetAttackRange()
end


function relic_unique_soldiers_banner:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function relic_unique_soldiers_banner:GetModifierAttackRangeBonus()
	return self.ar
end

function relic_unique_soldiers_banner:GetModifierPhysicalArmorBonus()
	return 6
end

function relic_unique_soldiers_banner:IsHidden()
	return true
end

function relic_unique_soldiers_banner:IsPurgable()
	return false
end

function relic_unique_soldiers_banner:RemoveOnDeath()
	return false
end

function relic_unique_soldiers_banner:IsPermanent()
	return true
end

function relic_unique_soldiers_banner:AllowIllusionDuplicate()
	return true
end

function relic_unique_soldiers_banner:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end