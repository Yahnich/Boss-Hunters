boss_necro_vile_aura = class({})

function boss_necro_vile_aura:GetIntrinsicModifierName()
	return "modifier_boss_necro_vile_aura"
end

modifier_boss_necro_vile_aura = class({})
LinkLuaModifier("modifier_boss_necro_vile_aura", "bosses/boss_necro/boss_necro_vile_aura1", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_necro_vile_aura:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
	if IsServer() then self:StartIntervalThink( self:GetSpecialValueFor("blink_rate") ) end
end

function modifier_boss_necro_vile_aura:OnRefresh()
	self.radius = self:GetSpecialValueFor("radius")
	if IsServer() then self:StartIntervalThink( self:GetSpecialValueFor("blink_rate") ) end
end

function modifier_boss_necro_vile_aura:OnIntervalThink()
	local parent = self:GetParent()
	local position = parent:GetAbsOrigin() + ActualRandomVector(600, 150)
	if RollPercentage(50) then -- random position
		if parent:GetTauntTarget() then
			position = parent:GetTauntTarget():GetAbsOrigin() + ActualRandomVector(600, 150)
		else
			for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), 1500 ) ) do
				if RollPercentage(60) then
					position = enemy:GetAbsOrigin() + ActualRandomVector(600, 150)
					break
				end
			end
		end
	end
	parent:Blink(position)
end

function modifier_boss_necro_vile_aura:IsAura()
	return true
end

function modifier_boss_necro_vile_aura:GetModifierAura()
	return "modifier_boss_necro_vile_aura_effect"
end

function modifier_boss_necro_vile_aura:GetAuraRadius()
	return self.radius
end

function modifier_boss_necro_vile_aura:GetAuraDuration()
	return 0.5
end

function modifier_boss_necro_vile_aura:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_boss_necro_vile_aura:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_boss_necro_vile_aura:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

modifier_boss_necro_vile_aura_effect = class({})
LinkLuaModifier("modifier_boss_necro_vile_aura_effect", "bosses/boss_necro/boss_necro_vile_aura1", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_necro_vile_aura_effect:OnCreated()
	self.healRed = self:GetSpecialValueFor("heal_reduction")
end

function modifier_boss_necro_vile_aura_effect:GetModifierHealAmplify_Percentage()
	return self.healRed
end