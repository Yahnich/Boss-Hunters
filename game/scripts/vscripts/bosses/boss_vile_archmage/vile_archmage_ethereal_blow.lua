vile_archmage_ethereal_blow = class({})

function vile_archmage_ethereal_blow:OnSpellStart()
	local caster = self:GetCaster()
	local hTarget = self:GetCursorTarget()
	if hTarget:TriggerSpellAbsorb(self) then return end
	hTarget:AddNewModifier(caster, self, "modifier_vile_archmage_ethereal_blow", {duration = self:GetTalentSpecialValueFor("duration")})
	hTarget:ModifyThreat( 50, true )
	EmitSoundOn("Hero_Pugna.Decrepify", hTarget)
end

LinkLuaModifier( "modifier_vile_archmage_ethereal_blow", "bosses/boss_vile_archmage/vile_archmage_ethereal_blow" ,LUA_MODIFIER_MOTION_NONE )
modifier_vile_archmage_ethereal_blow = class({})

function modifier_vile_archmage_ethereal_blow:OnCreated()
	self.magic_damage = self:GetAbility():GetTalentSpecialValueFor("mr_loss")
	self.slow = self:GetAbility():GetTalentSpecialValueFor("slow")
	if IsServer() then self:GetAbility():StartDelayedCooldown() end
end

function modifier_vile_archmage_ethereal_blow:OnRefresh()
	self.magic_damage = self:GetAbility():GetTalentSpecialValueFor("mr_loss")
	self.slow = self:GetAbility():GetTalentSpecialValueFor("slow")
	if IsServer() then self:GetAbility():StartDelayedCooldown() end
end

function modifier_vile_archmage_ethereal_blow:OnDestroy()
	if IsServer() then self:GetAbility():EndDelayedCooldown() end
end

function modifier_vile_archmage_ethereal_blow:CheckState()
    local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_DISARMED] = true,
	}
	return state
end

function modifier_vile_archmage_ethereal_blow:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
				MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
			}
	return funcs
end

function modifier_vile_archmage_ethereal_blow:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_vile_archmage_ethereal_blow:GetModifierMagicalResistanceBonus()
	return self.magic_damage
end

function modifier_vile_archmage_ethereal_blow:GetEffectName()
	return "particles/units/heroes/hero_pugna/pugna_decrepify.vpcf"
end

function modifier_vile_archmage_ethereal_blow:GetStatusEffectName()
	return "particles/status_fx/status_effect_ghost.vpcf"
end

function modifier_vile_archmage_ethereal_blow:StatusEffectPriority()
	return 15
end