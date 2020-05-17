brewmaster_drunken_haze_bh = class({})

function brewmaster_drunken_haze_bh:IsStealable()
	return true
end

function brewmaster_drunken_haze_bh:IsHiddenWhenStolen()
	return false
end

function brewmaster_drunken_haze_bh:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

function brewmaster_drunken_haze_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local radius = self:GetTalentSpecialValueFor("radius")
	if caster:HasScepter() then
		for _, unit in ipairs( caster:FindAllUnitsInRadius( target:GetAbsOrigin(), radius ) ) do
			self:FireTrackingProjectile("particles/units/heroes/hero_brewmaster/brewmaster_cinder_brew_cast.vpcf", unit, 1300, nil, DOTA_PROJECTILE_ATTACHMENT_ATTACK_2)
		end
	else
		for _, unit in ipairs( caster:FindEnemyUnitsInRadius( target:GetAbsOrigin(), radius ) ) do
			self:FireTrackingProjectile("particles/units/heroes/hero_brewmaster/brewmaster_cinder_brew_cast.vpcf", unit, 1300, nil, DOTA_PROJECTILE_ATTACHMENT_ATTACK_2)
		end
	end
	EmitSoundOn("Hero_Brewmaster.CinderBrew.Cast", caster)
	if caster:HasTalent("special_bonus_unique_brewmaster_drunken_haze_1") then
		caster:AddNewModifier(caster, caster:FindAbilityByName("brewmaster_drunken_brawler_bh"), "modifier_brewmaster_drunken_brawler_bh_crit", {})
		caster:AddNewModifier(caster, caster:FindAbilityByName("brewmaster_drunken_brawler_bh"), "modifier_brewmaster_drunken_brawler_bh_evade", {})
	end
end

function brewmaster_drunken_haze_bh:OnProjectileHit(target, position)
	local caster = self:GetCaster()
	local duration = self:GetTalentSpecialValueFor("duration")
	EmitSoundOn("Hero_Brewmaster.CinderBrew.Target", target)
	if target:GetTeam() == caster:GetTeam() then
		target:AddNewModifier(caster, self, "modifier_brewmaster_drunken_haze_buff", {duration = duration})
	elseif not target:TriggerSpellAbsorb( self ) then
		target:AddNewModifier(caster, self, "modifier_brewmaster_drunken_haze_debuff", {duration = duration})
	end
end

LinkLuaModifier( "modifier_brewmaster_drunken_haze_buff", "heroes/hero_brewmaster/brewmaster_drunken_haze_bh.lua", LUA_MODIFIER_MOTION_NONE )
modifier_brewmaster_drunken_haze_buff = class({})

function modifier_brewmaster_drunken_haze_buff:OnCreated()
	self.miss = self:GetAbility():GetSpecialValueFor("scepter_evasion")
end

function modifier_brewmaster_drunken_haze_buff:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_EVASION_CONSTANT
			}
	return funcs
end

function modifier_brewmaster_drunken_haze_buff:GetModifierEvasion_Constant()
	return self.miss
end

function modifier_brewmaster_drunken_haze_buff:GetEffectName()
	return "particles/units/heroes/hero_brewmaster/brewmaster_drunken_haze_debuff.vpcf"
end

function modifier_brewmaster_drunken_haze_buff:GetStatusEffectName()
	return "particles/status_fx/status_effect_brewmaster_drunken_haze.vpcf"
end

LinkLuaModifier( "modifier_brewmaster_drunken_haze_debuff", "heroes/hero_brewmaster/brewmaster_drunken_haze_bh.lua", LUA_MODIFIER_MOTION_NONE )
modifier_brewmaster_drunken_haze_debuff = class({})

function modifier_brewmaster_drunken_haze_debuff:OnCreated()
	self.miss = self:GetAbility():GetSpecialValueFor("miss_chance")
end

function modifier_brewmaster_drunken_haze_debuff:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MISS_PERCENTAGE
			}
	return funcs
end

function modifier_brewmaster_drunken_haze_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.speed
end

function modifier_brewmaster_drunken_haze_debuff:GetEffectName()
	return "particles/units/heroes/hero_brewmaster/brewmaster_drunken_haze_debuff.vpcf"
end

function modifier_brewmaster_drunken_haze_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_brewmaster_drunken_haze.vpcf"
end

function modifier_brewmaster_drunken_haze_debuff:GetTauntTarget()
	if self:GetCaster():HasTalent("special_bonus_unique_brewmaster_drunken_haze_2") then return self:GetCaster() end
end