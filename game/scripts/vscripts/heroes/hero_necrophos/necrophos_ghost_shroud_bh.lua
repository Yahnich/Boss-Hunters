necrophos_ghost_shroud_bh = class({})

function necrophos_ghost_shroud_bh:GetCooldown( iLvl )
	return self.BaseClass.GetCooldown( self, iLvl ) + self:GetCaster():FindTalentValue("special_bonus_unique_necrophos_ghost_shroud_1")
end

function necrophos_ghost_shroud_bh:OnSpellStart()
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_necrophos_ghost_shroud_bh") then
		caster:RemoveModifierByName("modifier_necrophos_ghost_shroud_bh")
	else
		caster:AddNewModifier( caster, self, "modifier_necrophos_ghost_shroud_bh", {duration = self:GetTalentSpecialValueFor("duration")})
		caster:EmitSound("Hero_Necrolyte.SpiritForm.Cast")
		ProjectileManager:ProjectileDodge( caster )
		self:EndCooldown()
	end
end

modifier_necrophos_ghost_shroud_bh = class({})
LinkLuaModifier( "modifier_necrophos_ghost_shroud_bh", "heroes/hero_necrophos/necrophos_ghost_shroud_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_necrophos_ghost_shroud_bh:OnCreated()
	self.heal_amp = self:GetTalentSpecialValueFor("heal_bonus")
	self.radius = self:GetTalentSpecialValueFor("slow_aoe")
	self.minus_mr = self:GetTalentSpecialValueFor("bonus_damage")
	
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_necrophos_ghost_shroud_1")
	if self.talent1 then
		self.duration = self:GetCaster():FindTalentValue("special_bonus_unique_necrophos_ghost_shroud_1")
	end
end

function modifier_necrophos_ghost_shroud_bh:OnDestroy()
	if IsServer() then self:GetAbility():SetCooldown() end
end

function modifier_necrophos_ghost_shroud_bh:CheckState()
	return {[MODIFIER_STATE_DISARMED] = not self.talent1,
			[MODIFIER_STATE_ATTACK_IMMUNE] = true}
end

function modifier_necrophos_ghost_shroud_bh:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED, 
			MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL, 
			MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
			MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
			MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,}
end

function modifier_necrophos_ghost_shroud_bh:OnAttackLanded(params)
	if self.talent1 and params.attacker == self:GetParent() then
		params.target:DisableHealing(self.duration)
	end
end

function modifier_necrophos_ghost_shroud_bh:GetAbsoluteNoDamagePhysical()
	return 1
end

function modifier_necrophos_ghost_shroud_bh:GetModifierMagicalResistanceBonus()
	return self.minus_mr
end

function modifier_necrophos_ghost_shroud_bh:GetModifierHealAmplify_Percentage()
	return self.heal_amp
end

function modifier_necrophos_ghost_shroud_bh:GetModifierHPRegenAmplify_Percentage()
	return self.heal_amp
end

function modifier_necrophos_ghost_shroud_bh:GetModifierMPRegenAmplify_Percentage()
	return self.heal_amp
end

function modifier_necrophos_ghost_shroud_bh:IsAura()
	return true
end

function modifier_necrophos_ghost_shroud_bh:GetModifierAura()
	return "modifier_necrophos_ghost_shroud_bh_slow"
end

function modifier_necrophos_ghost_shroud_bh:GetAuraRadius()
	return self.radius
end

function modifier_necrophos_ghost_shroud_bh:GetAuraDuration()
	return 0.5
end

function modifier_necrophos_ghost_shroud_bh:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_necrophos_ghost_shroud_bh:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_necrophos_ghost_shroud_bh:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_necrophos_ghost_shroud_bh:GetEffectName()
	return "particles/units/heroes/hero_necrolyte/necrolyte_spirit.vpcf"
end

function modifier_necrophos_ghost_shroud_bh:GetStatusEffectName()
	return "particles/status_fx/status_effect_necrolyte_spirit.vpcf"
end

function modifier_necrophos_ghost_shroud_bh:StatusEffectPriority()
	return 15
end

modifier_necrophos_ghost_shroud_bh_slow = class({})
LinkLuaModifier( "modifier_necrophos_ghost_shroud_bh_slow", "heroes/hero_necrophos/necrophos_ghost_shroud_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_necrophos_ghost_shroud_bh_slow:OnCreated()
	self.slow = self:GetTalentSpecialValueFor("movement_speed") * (-1)
end

function modifier_necrophos_ghost_shroud_bh_slow:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_necrophos_ghost_shroud_bh_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_necrophos_ghost_shroud_bh_slow:GetEffectName()
	return "particles/units/heroes/hero_necrolyte/necrolyte_spirit_debuff.vpcf"
end