brewmaster_drunken_haze_ebf = class({})

if IsServer() then
	function brewmaster_drunken_haze_ebf:OnSpellStart()
		local projectile = {
			Target = self:GetCursorTarget(),
			Source = self:GetCaster(),
			Ability = self,
			EffectName = "particles/units/heroes/hero_brewmaster/brewmaster_drunken_haze.vpcf",
			bDodgable = false,
			bProvidesVision = false,
			iMoveSpeed = 1300,
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
		}
		ProjectileManager:CreateTrackingProjectile(projectile)
		EmitSoundOn("Hero_Brewmaster.DrunkenHaze.Cast", self:GetCaster())
	end

	function brewmaster_drunken_haze_ebf:OnProjectileHit(target, position)
		local caster = self:GetCaster()
		local duration = self:GetTalentSpecialValueFor("duration")
		EmitSoundOn("Hero_Brewmaster.DrunkenHaze.Target", target)
		if target:GetTeam() == caster:GetTeam() then
			target:AddNewModifier(caster, self, "modifier_brewmaster_drunken_haze_buff", {duration = duration})
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