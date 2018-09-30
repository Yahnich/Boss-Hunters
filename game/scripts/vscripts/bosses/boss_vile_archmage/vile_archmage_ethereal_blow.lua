pugna_decrepify_bh = class({})

function pugna_decrepify_bh:OnSpellStart()
	local caster = self:GetCaster()
	local hTarget = self:GetCursorTarget()
	if caster:GetTeam() == hTarget:GetTeam() then
		hTarget:AddNewModifier(caster, self, "modifier_pugna_decrepify_ally", {duration = self:GetTalentSpecialValueFor("tooltip_duration")})
	else
		hTarget:AddNewModifier(caster, self, "modifier_pugna_decrepify_enemy", {duration = self:GetTalentSpecialValueFor("tooltip_duration")})
	end
	EmitSoundOn("Hero_Pugna.Decrepify", hTarget)
end

LinkLuaModifier( "modifier_pugna_decrepify_ally", "heroes/hero_pugna/pugna_decrepify_bh" ,LUA_MODIFIER_MOTION_NONE )
modifier_pugna_decrepify_ally = class({})

function modifier_pugna_decrepify_ally:OnCreated()
	self.magic_damage = self:GetAbility():GetTalentSpecialValueFor("bonus_spell_damage_pct_allies")
	self.slow = self:GetAbility():GetTalentSpecialValueFor("bonus_movement_speed_allies")
	if IsServer() then self:GetAbility():StartDelayedCooldown() end
end

function modifier_pugna_decrepify_ally:OnRefresh()
	self.magic_damage = self:GetAbility():GetTalentSpecialValueFor("bonus_spell_damage_pct_allies")
	self.slow = self:GetAbility():GetTalentSpecialValueFor("bonus_movement_speed_allies")
	if IsServer() then self:GetAbility():StartDelayedCooldown() end
end

function modifier_pugna_decrepify_ally:OnDestroy()
	if IsServer() then self:GetAbility():EndDelayedCooldown() end
end

function modifier_pugna_decrepify_ally:CheckState()
    local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
	}
	return state
end

function modifier_pugna_decrepify_ally:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
				MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
			}
	return funcs
end

function modifier_pugna_decrepify_ally:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_pugna_decrepify_ally:GetModifierMagicalResistanceBonus()
	return self.magic_damage
end

function modifier_pugna_decrepify_ally:GetEffectName()
	return "particles/units/heroes/hero_pugna/pugna_decrepify.vpcf"
end

function modifier_pugna_decrepify_ally:GetStatusEffectName()
	return "particles/status_fx/status_effect_ghost.vpcf"
end

function modifier_pugna_decrepify_ally:StatusEffectPriority()
	return 15
end

LinkLuaModifier( "modifier_pugna_decrepify_enemy", "heroes/hero_pugna/pugna_decrepify_bh" ,LUA_MODIFIER_MOTION_NONE )
modifier_pugna_decrepify_enemy = class({})

function modifier_pugna_decrepify_enemy:OnCreated()
	self.magic_damage = self:GetAbility():GetTalentSpecialValueFor("bonus_spell_damage_pct")
	self.slow = self:GetAbility():GetTalentSpecialValueFor("bonus_movement_speed")
	if IsServer() then self:GetAbility():StartDelayedCooldown() end
end

function modifier_pugna_decrepify_enemy:OnRefresh()
	self.magic_damage = self:GetAbility():GetTalentSpecialValueFor("bonus_spell_damage_pct")
	self.slow = self:GetAbility():GetTalentSpecialValueFor("bonus_movement_speed")
	if IsServer() then self:GetAbility():StartDelayedCooldown() end
end

function modifier_pugna_decrepify_enemy:OnDestroy()
	if IsServer() then self:GetAbility():EndDelayedCooldown() end
end

function modifier_pugna_decrepify_enemy:CheckState()
    local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_DISARMED] = true,
	}
	return state
end

function modifier_pugna_decrepify_enemy:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
				MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
			}
	return funcs
end

function modifier_pugna_decrepify_enemy:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_pugna_decrepify_enemy:GetModifierMagicalResistanceBonus()
	return self.magic_damage
end

function modifier_pugna_decrepify_enemy:GetEffectName()
	return "particles/units/heroes/hero_pugna/pugna_decrepify.vpcf"
end

function modifier_pugna_decrepify_enemy:GetStatusEffectName()
	return "particles/status_fx/status_effect_ghost.vpcf"
end

function modifier_pugna_decrepify_enemy:StatusEffectPriority()
	return 15
end