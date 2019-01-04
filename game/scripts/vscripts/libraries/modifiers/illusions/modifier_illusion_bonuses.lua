modifier_illusion_bonuses = class({})

function modifier_illusion_bonuses:OnCreated()
	self:GetParent().unitOwnerEntity = self:GetCaster()
	local agility = self:GetCaster():GetAgility()
	self.as = agility * 1
	self.ms = agility * 0.05
	if self:GetCaster():GetPrimaryAttribute() == DOTA_ATTRIBUTE_AGILITY then
		self.as = self.as * 1.25
		self.ms = agility * 0.0625
	end
	self.ar = self:GetCaster():GetAttackRange()
	if IsServer() then
		self.ps = self:GetCaster():GetProjectileSpeed()
	end
end

function modifier_illusion_bonuses:OnDestroy()
	if IsServer() then
		if self:GetParent().wearableList then
			for _, wearable in ipairs( self:GetParent().wearableList ) do
				UTIL_Remove( wearable )
			end
			self:GetParent().wearableList = nil
		end
	end
end

function modifier_illusion_bonuses:DeclareFunctions()
    local funcs = {
		MODIFIER_PROPERTY_ATTACK_RANGE_BASE_OVERRIDE,
		MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_illusion_bonuses:GetModifierAttackRangeOverride( params )
	return self.ar
end

function modifier_illusion_bonuses:GetModifierAttackSpeedBonus( params )
    return self.as
end

function modifier_illusion_bonuses:GetModifierProjectileSpeedBonus()
	return self.ps
end

function modifier_illusion_bonuses:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_illusion_bonuses:IsHidden()
    return true
end