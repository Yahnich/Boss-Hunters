modifier_illusion_bonuses = class({})

function modifier_illusion_bonuses:OnCreated()
	self:GetParent().unitOwnerEntity = self:GetCaster()
	if not self:GetCaster() then return end
	local agility = self:GetCaster():GetAgility()
	local strength = self:GetCaster():GetStrength()
	local intellect = self:GetCaster():GetIntellect( false)
	self.as = agility * 1
	self.ms = agility * 0.075
	self.hp = strength * 25
	self.mp = intellect * 20
	self.amp = intellect * 0.25
	self.ar = self:GetCaster():GetAttackRange()
	if IsServer() then
		EmitSoundOn("General.Illusion.Create", self:GetParent())

		self.ps = self:GetCaster():GetProjectileSpeed()
	end
end

function modifier_illusion_bonuses:OnDestroy()
	if IsServer() then
		EmitSoundOn("General.Illusion.Destroy", self:GetParent())
		
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
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_EVENT_ON_DEATH
    }

    return funcs
end

function modifier_illusion_bonuses:GetModifierExtraHealthBonus( params )
	return self.hp
end

function modifier_illusion_bonuses:GetModifierConstantHealthRegen( params )
	return self.hpr
end

function modifier_illusion_bonuses:GetModifierManaBonus( params )
	return self.mp
end

function modifier_illusion_bonuses:GetModifierConstantManaRegen( params )
	return self.mpr
end

function modifier_illusion_bonuses:GetModifierSpellAmplify_Percentage( params )
	return self.amp
end

function modifier_illusion_bonuses:GetModifierAttackRangeOverride( params )
	return self.ar
end

function modifier_illusion_bonuses:GetModifierAttackSpeedBonus_Constant( params )
    return self.as
end

function modifier_illusion_bonuses:GetModifierProjectileSpeedBonus()
	return self.ps
end

function modifier_illusion_bonuses:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_illusion_bonuses:OnDeath(params)
	if params.unit == self:GetParent() then
		params.unit:AddNoDraw( )
		for _, wearable in ipairs( params.unit.wearableList ) do
			wearable:AddNoDraw( )
		end
	end
end

function modifier_illusion_bonuses:IsHidden()
    return true
end

function modifier_illusion_bonuses:RemoveOnDeath()
	return false
end

function modifier_illusion_bonuses:IsPurgable()
	return false
end