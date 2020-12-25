bane_enfeeble_ebf = class({})

function bane_enfeeble_ebf:GetIntrinsicModifierName()
	return "modifier_bane_enfeeble_handler"
end

function bane_enfeeble_ebf:GetBehavior()
	local caster = self:GetCaster()
	if caster:HasTalent("special_bonus_unique_bane_enfeeble_ebf_2") then
		return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
	else
		return DOTA_ABILITY_BEHAVIOR_PASSIVE
	end
end

function bane_enfeeble_ebf:GetCooldown(iLvl)
	if self:GetCaster():HasTalent("special_bonus_unique_bane_enfeeble_ebf_2") then
		return self:GetCaster():FindTalentValue("special_bonus_unique_bane_enfeeble_ebf_2", "cd")
	end
end 

function bane_enfeeble_ebf:GetCastRange( target, position )
	if self:GetCaster():HasTalent("special_bonus_unique_bane_enfeeble_ebf_2") then
		return self:GetCaster():FindTalentValue("special_bonus_unique_bane_enfeeble_ebf_2", "range")
	end
end 

function bane_enfeeble_ebf:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	if caster:HasTalent("special_bonus_unique_bane_enfeeble_ebf_2") then
		target = self:GetCursorPosition()
		local speed = caster:FindTalentValue("special_bonus_unique_bane_enfeeble_ebf_2", "speed")
		local startRadius = caster:FindTalentValue("special_bonus_unique_bane_enfeeble_ebf_2", "start_radius")
		local endRadius = caster:FindTalentValue("special_bonus_unique_bane_enfeeble_ebf_2", "end_radius")
		self:FireLinearProjectile(nil, speed * CalculateDirection( target, caster ), self:GetTrueCastRange(), startRadius, {width_end = endRadius})
		ParticleManager:FireParticle("particles/units/heroes/hero_bane/bane_enfeeble_talent.vpcf", PATTACH_ABSORIGIN, caster, {[0] = caster:GetAbsOrigin()})
	else
		self:ApplyEnfeeble(target)
	end
	EmitSoundOn("Hero_Bane.Enfeeble.Cast", caster)
end

function bane_enfeeble_ebf:OnProjectileHit(target, position)
	if target then
		if target:TriggerSpellAbsorb(self) then return end
		self:ApplyEnfeeble(target)
	end
end

function bane_enfeeble_ebf:ApplyEnfeeble(target)
	local caster = self:GetCaster()
	local baseDuration = 0
	local enfeeble = target:FindModifierByName( "modifier_bane_enfeeble_debuff" )
	if enfeeble then
		baseDuration = math.min( enfeeble:GetRemainingTime(), self:GetTalentSpecialValueFor("debuff_duration") ) + 1
		enfeeble:SetDuration( baseDuration, true )
	else
		target:AddNewModifier(caster, self, "modifier_bane_enfeeble_debuff", {duration = baseDuration + self:GetTalentSpecialValueFor("debuff_duration")})
	end
	
	if caster:HasTalent("special_bonus_unique_bane_enfeeble_ebf_1") then
		caster:AddNewModifier(caster, self, "modifier_bane_enfeeble_buff", {duration = self:GetTalentSpecialValueFor("debuff_duration")})
	end
	EmitSoundOn("Hero_Bane.Enfeeble", caster)
end

modifier_bane_enfeeble_handler = class({})
LinkLuaModifier( "modifier_bane_enfeeble_handler", "heroes/hero_bane/bane_enfeeble_ebf", LUA_MODIFIER_MOTION_NONE )

function modifier_bane_enfeeble_handler:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST }
end

function modifier_bane_enfeeble_handler:OnAbilityFullyCast(params)
	if params.target and params.unit == self:GetParent() and params.unit:HasAbility( params.ability:GetAbilityName() ) then
		self:GetAbility():ApplyEnfeeble(params.target)
	end
end

function modifier_bane_enfeeble_handler:IsHidden()
	return true
end

modifier_bane_enfeeble_debuff = class({})
LinkLuaModifier("modifier_bane_enfeeble_debuff", "heroes/hero_bane/bane_enfeeble_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_bane_enfeeble_debuff:OnCreated()
	self.magic_resist = self:GetTalentSpecialValueFor("magic_resist_reduction")
	self.status_resist = self:GetTalentSpecialValueFor("status_resist_reduction")
	self.spell_amp = self:GetTalentSpecialValueFor("spell_amp_reduction")
	self.status_amp = self:GetTalentSpecialValueFor("status_amp_reduction")
end

function modifier_bane_enfeeble_debuff:OnRefresh()
	self:OnCreated()
end

function modifier_bane_enfeeble_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
			MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
			MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE 
	}
end

function modifier_bane_enfeeble_debuff:GetModifierMagicalResistanceBonus()
	return self.magic_resist
end

function modifier_bane_enfeeble_debuff:GetModifierStatusResistanceStacking()
	return self.status_resist
end

function modifier_bane_enfeeble_debuff:GetModifierSpellAmplify_Percentage()
	return self.spell_amp
end

function modifier_bane_enfeeble_debuff:GetModifierStatusAmplify_Percentage()
	return self.status_amp
end

function modifier_bane_enfeeble_debuff:GetEffectName()
	return "particles/units/heroes/hero_bane/bane_enfeeble.vpcf"
end

function modifier_bane_enfeeble_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

modifier_bane_enfeeble_buff = class({})
LinkLuaModifier("modifier_bane_enfeeble_buff", "heroes/hero_bane/bane_enfeeble_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_bane_enfeeble_buff:OnCreated()
	self.magic_resist = -self:GetTalentSpecialValueFor("magic_resist_reduction")
	self.status_resist = -self:GetTalentSpecialValueFor("status_resist_reduction")
	self.spell_amp = -self:GetTalentSpecialValueFor("spell_amp_reduction")
	self.status_amp = -self:GetTalentSpecialValueFor("status_amp_reduction")
end

function modifier_bane_enfeeble_buff:OnRefresh()
	self:OnRefresh()
end

function modifier_bane_enfeeble_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
			MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
			MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE 
	}
end

function modifier_bane_enfeeble_buff:GetModifierMagicalResistanceBonus()
	return self.magic_resist
end

function modifier_bane_enfeeble_buff:GetModifierStatusResistanceStacking()
	return self.status_resist
end

function modifier_bane_enfeeble_buff:GetModifierSpellAmplify_Percentage()
	return self.spell_amp
end

function modifier_bane_enfeeble_buff:GetModifierStatusAmplify_Percentage()
	return self.status_amp
end

function modifier_bane_enfeeble_buff:GetEffectName()
	return "particles/units/heroes/hero_bane/bane_enfeeble_buff.vpcf"
end

function modifier_bane_enfeeble_buff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end