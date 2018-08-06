brewmaster_drunken_haze_ebf = class({})

function brewmaster_drunken_haze_ebf:IsStealable()
	return true
end

function brewmaster_drunken_haze_ebf:IsHiddenWhenStolen()
	return false
end

if IsServer() then
	function brewmaster_drunken_haze_ebf:OnSpellStart()
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		if caster:HasScepter() then
			for _, unit in ipairs( caster:FindAllUnitsInRadius( target:GetAbsOrigin(), self:GetTalentSpecialValueFor("scepter_radius") ) ) do
				self:FireTrackingProjectile("particles/units/heroes/hero_brewmaster/brewmaster_drunken_haze.vpcf", unit, 1300)
			end
		else
			self:FireTrackingProjectile("particles/units/heroes/hero_brewmaster/brewmaster_drunken_haze.vpcf", target, 1300)
		end
		EmitSoundOn("Hero_Brewmaster.DrunkenHaze.Cast", caster)
	end

	function brewmaster_drunken_haze_ebf:OnProjectileHit(target, position)
		local caster = self:GetCaster()
		local duration = self:GetTalentSpecialValueFor("duration")
		EmitSoundOn("Hero_Brewmaster.DrunkenHaze.Target", target)
		if target:GetTeam() == caster:GetTeam() then
			target:AddNewModifier(caster, self, "modifier_brewmaster_drunken_haze_buff", {duration = duration})
			self:Daze(self, caster, duration)
		else
			target:AddNewModifier(caster, self, "modifier_brewmaster_drunken_haze_debuff", {duration = duration})
		end
		
	end
end

LinkLuaModifier( "modifier_brewmaster_drunken_haze_buff", "heroes/hero_brewmaster/brewmaster_drunken_haze_ebf.lua", LUA_MODIFIER_MOTION_NONE )
modifier_brewmaster_drunken_haze_buff = class({})

function modifier_brewmaster_drunken_haze_buff:OnCreated()
	self.miss = self:GetAbility():GetSpecialValueFor("evasion")
	self.speed = self:GetAbility():GetSpecialValueFor("movement_bonus")
end

function modifier_brewmaster_drunken_haze_buff:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_EVASION_CONSTANT,
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
			}
	return funcs
end

function modifier_brewmaster_drunken_haze_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.speed
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

LinkLuaModifier( "modifier_brewmaster_drunken_haze_debuff", "heroes/hero_brewmaster/brewmaster_drunken_haze_ebf.lua", LUA_MODIFIER_MOTION_NONE )
modifier_brewmaster_drunken_haze_debuff = class({})

function modifier_brewmaster_drunken_haze_debuff:OnCreated()
	self.miss = self:GetAbility():GetSpecialValueFor("miss_chance")
	self.speed = self:GetAbility():GetSpecialValueFor("movement_slow")
end

function modifier_brewmaster_drunken_haze_debuff:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MISS_PERCENTAGE,
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
			}
	return funcs
end

function modifier_brewmaster_drunken_haze_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.speed
end

function modifier_brewmaster_drunken_haze_debuff:GetModifierMiss_Percentage()
	return self.miss
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