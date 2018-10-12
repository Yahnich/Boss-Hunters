boss_necro_vile_aura = class({})

function boss_necro_vile_aura:GetIntrinsicModifierName()
	return "modifier_boss_necro_vile_aura"
end

modifier_boss_necro_vile_aura = class({})
LinkLuaModifier("modifier_boss_necro_vile_aura", "bosses/boss_necro/boss_necro_vile_aura", LUA_MODIFIER_MOTION_NONE)

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
	local position = parent:GetAbsOrigin() + ActualRandomVector(600, 250)
	if parent:IsStunned() or parent:IsSilenced() or parent:IsRooted() then
		self:StartIntervalThink( 0.5 )
		return
	end
	if RollPercentage(50) then -- random position
		if parent:GetTauntTarget() then
			position = parent:GetTauntTarget():GetAbsOrigin() + ActualRandomVector(600, 250)
		else
			for _, enemy in ipairs( parent:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), -1 ) ) do
				if RollPercentage(60) then
					position = enemy:GetAbsOrigin() + ActualRandomVector(600, 250)
					break
				end
			end
		end
	end
	self:StartIntervalThink( -1 )
	ParticleManager:FireWarningParticle( position, self:GetParent():GetHullRadius() * 2.5 )
	local modifier = self
	Timers:CreateTimer(1.5, function()
		parent:Blink(position)
		if not modifier or modifier:IsNull() then return end
		if IsServer() then modifier:StartIntervalThink( modifier:GetAbility():GetSpecialValueFor("blink_rate") ) end
	end)
end

function modifier_boss_necro_vile_aura:IsAura()
	return self:GetCaster():PassivesDisabled()
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

function modifier_boss_necro_vile_aura:IsHidden()
	return true
end

modifier_boss_necro_vile_aura_effect = class({})
LinkLuaModifier("modifier_boss_necro_vile_aura_effect", "bosses/boss_necro/boss_necro_vile_aura", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_necro_vile_aura_effect:OnCreated()
	self.healRed = self:GetSpecialValueFor("heal_reduction")
end

function modifier_boss_necro_vile_aura_effect:GetModifierHealAmplify_Percentage()
	return self.healRed
end