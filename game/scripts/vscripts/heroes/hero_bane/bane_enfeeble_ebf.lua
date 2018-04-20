bane_enfeeble_ebf = class({})

function bane_enfeeble_ebf:GetBehavior()
	local caster = self:GetCaster()
	if caster:HasTalent("special_bonus_unique_bane_enfeeble_ebf_2") then
		return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
	else
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
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
	if target then self:ApplyEnfeeble(target) end
end

function bane_enfeeble_ebf:ApplyEnfeeble(target)
	local caster = self:GetCaster()
	target:AddNewModifier(caster, self, "modifier_bane_enfeeble_debuff", {duration = self:GetTalentSpecialValueFor("debuff_duration")})
	if caster:HasTalent("special_bonus_unique_bane_enfeeble_ebf_1") then
		caster:AddNewModifier(caster, self, "modifier_bane_enfeeble_buff", {duration = self:GetTalentSpecialValueFor("debuff_duration")})
	end
	EmitSoundOn("Hero_Bane.Enfeeble", caster)
end

modifier_bane_enfeeble_debuff = class({})
LinkLuaModifier("modifier_bane_enfeeble_debuff", "heroes/hero_bane/bane_enfeeble_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_bane_enfeeble_debuff:OnCreated()
	self.damage = self:GetTalentSpecialValueFor("enfeeble_attack_reduction")
end

function modifier_bane_enfeeble_debuff:OnRefresh()
	self.damage = self:GetTalentSpecialValueFor("enfeeble_attack_reduction")
end

function modifier_bane_enfeeble_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_bane_enfeeble_debuff:GetModifierIncomingDamage_Percentage()
	return -5
end

function modifier_bane_enfeeble_debuff:GetModifierPreAttack_BonusDamage()
	return self.damage
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
	self.damage = self:GetTalentSpecialValueFor("enfeeble_attack_reduction") * (-1)
end

function modifier_bane_enfeeble_buff:OnRefresh()
	self.damage = self:GetTalentSpecialValueFor("enfeeble_attack_reduction") * (-1)
end

function modifier_bane_enfeeble_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function modifier_bane_enfeeble_buff:GetModifierPreAttack_BonusDamage()
	return self.damage
end

function modifier_bane_enfeeble_buff:GetEffectName()
	return "particles/units/heroes/hero_bane/bane_enfeeble_buff.vpcf"
end

function modifier_bane_enfeeble_buff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end