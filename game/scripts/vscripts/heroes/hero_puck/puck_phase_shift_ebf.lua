puck_phase_shift_ebf = class({})

function puck_phase_shift_ebf:GetChannelTime()
	self.duration = self:GetTalentSpecialValueFor( "duration" )

	if self:GetCaster():HasTalent("special_bonus_unique_puck_phase_shift_2") then
		return nil
	end

	return self.duration
end

function puck_phase_shift_ebf:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_puck_phase_shift_immune", {duration = self:GetTalentSpecialValueFor( "duration") })
	EmitSoundOn("Hero_Puck.Phase_Shift", caster)
end

function puck_phase_shift_ebf:OnChannelFinish(bInterrupt)
	local caster = self:GetCaster()
	caster:RemoveModifierByName("modifier_puck_phase_shift_immune")
end

modifier_puck_phase_shift_immune = class({})
LinkLuaModifier("modifier_puck_phase_shift_immune", "heroes/hero_puck/puck_phase_shift_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_puck_phase_shift_immune:OnCreated()
	self.regen = self:GetCaster():FindTalentValue("special_bonus_unique_puck_phase_shift_1")
	if IsServer() then 
		self:GetAbility():StartDelayedCooldown()
	end
end

function modifier_puck_phase_shift_immune:OnRefresh()
	self.regen = self:GetCaster():FindTalentValue("special_bonus_unique_puck_phase_shift_1")
	if IsServer() then 
		self:GetAbility():StartDelayedCooldown()
	end
end

function modifier_puck_phase_shift_immune:OnDestroy()
	if IsServer() then 
		self:GetAbility():EndDelayedCooldown()
	end
end

function modifier_puck_phase_shift_immune:CheckState()
	return {[MODIFIER_STATE_ATTACK_IMMUNE] = true,
			[MODIFIER_STATE_MAGIC_IMMUNE] = true,
			[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_NO_HEALTH_BAR] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_UNSELECTABLE] = true,
			[MODIFIER_STATE_OUT_OF_GAME] = true}
end

function modifier_puck_phase_shift_immune:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
	return funcs
end

function modifier_puck_phase_shift_immune:GetOverrideAnimation()
	if not self:GetCaster():HasTalent("special_bonus_unique_puck_phase_shift_2") then return ACT_DOTA_VERSUS end
end

function modifier_puck_phase_shift_immune:OnAttackStart(params)
	if self:GetParent() == params.unit then
		self:Destroy()
	end
end

function modifier_puck_phase_shift_immune:OnAbilityFullyCast(params)
	if self:GetParent() == params.unit and params.ability ~= self:GetAbility() then
		self:Destroy()
	end
end

function modifier_puck_phase_shift_immune:GetModifierHealthRegenPercentage()
	return self.regen
end

function modifier_puck_phase_shift_immune:GetStatusEffectName()
	return "particles/status_fx/status_effect_phase_shift.vpcf"
end

function modifier_puck_phase_shift_immune:StatusEffectPriority()
	return 5
end

function modifier_puck_phase_shift_immune:GetEffectName()
	return "particles/units/heroes/hero_puck/puck_phase_shift.vpcf"
end