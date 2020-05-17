boss_aeon_distortion_field = class({})

function boss_aeon_distortion_field:GetIntrinsicModifierName()
	return "modifier_boss_aeon_distortion_field"
end

modifier_boss_aeon_distortion_field = class({})
LinkLuaModifier("modifier_boss_aeon_distortion_field", "bosses/boss_aeon/boss_aeon_distortion_field", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_aeon_distortion_field:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_boss_aeon_distortion_field:OnRefresh()
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_boss_aeon_distortion_field:IsAura()
	return not self:GetCaster():PassivesDisabled()
end

function modifier_boss_aeon_distortion_field:GetModifierAura()
	return "modifier_boss_aeon_distortion_field_aura"
end

function modifier_boss_aeon_distortion_field:GetAuraRadius()
	return self.radius
end

function modifier_boss_aeon_distortion_field:GetAuraDuration()
	return 0.5
end

function modifier_boss_aeon_distortion_field:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_boss_aeon_distortion_field:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_boss_aeon_distortion_field:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_boss_aeon_distortion_field:IsHidden()
	return true
end

modifier_boss_aeon_distortion_field_aura = class({})
LinkLuaModifier("modifier_boss_aeon_distortion_field_aura", "bosses/boss_aeon/boss_aeon_distortion_field", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_aeon_distortion_field_aura:OnCreated()
	self.as = self:GetSpecialValueFor("as_slow")
	self.cdr = self:GetSpecialValueFor("cdr_slow")
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_boss_aeon_distortion_field_aura:OnRefresh()
	self.as = self:GetSpecialValueFor("as_slow")
	self.cdr = self:GetSpecialValueFor("cdr_slow")
end

function modifier_boss_aeon_distortion_field_aura:OnIntervalThink()
	local parent = self:GetParent()
	for i = 0, parent:GetAbilityCount() - 1 do
        local ability = parent:GetAbilityByIndex( i )
        if ability then
			local cd = ability:GetCooldownTimeRemaining()
			if cd > 0 then
				ability:EndCooldown()
				ability:StartCooldown(cd - (0.1 * (self.cdr/100)))
				print( cd, ability:GetCooldownTimeRemaining() )
			end
        end
    end
	for i=0, 5, 1 do
		local item = parent:GetItemInSlot(i)
		if item then
			local cd = item:GetCooldownTimeRemaining()
			if cd > 0 then
				item:EndCooldown()
				item:StartCooldown(cd - (0.1 * (self.cdr/100)))
			end
		end
	end
end

function modifier_boss_aeon_distortion_field_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP, MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_ONGOING}
end

function modifier_boss_aeon_distortion_field_aura:OnTooltip()
	return self.as
end

function modifier_boss_aeon_distortion_field_aura:GetModifierAttackSpeedBonus()
	return self.as
end