enchantress_untouchable_bh = class({})

function enchantress_untouchable_bh:IsStealable()
    return true
end

function enchantress_untouchable_bh:IsHiddenWhenStolen()
    return false
end

function enchantress_untouchable_bh:GetBehavior()
    if self:GetCaster():HasTalent("special_bonus_unique_enchantress_untouchable_bh_2") then
    	return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_AOE
    end
    return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
end

function enchantress_untouchable_bh:GetCastRange(vLocation, hTarget)
    if self:GetCaster():HasTalent("special_bonus_unique_enchantress_untouchable_bh_2") then
    	return self:GetCaster():FindTalentValue("special_bonus_unique_enchantress_untouchable_bh_2", "cast_range")
    end
    return self:GetTalentSpecialValueFor("radius")
end

function enchantress_untouchable_bh:GetAOERadius()
    return self:GetTalentSpecialValueFor("radius")
end

function enchantress_untouchable_bh:GetIntrinsicModifierName()
	return "modifier_enchantress_untouchable_bh"
end

function enchantress_untouchable_bh:OnSpellStart()
	local caster = self:GetCaster()
	local point = caster:GetAbsOrigin()

	local radius = self:GetTalentSpecialValueFor("radius")
	local duration = self:GetTalentSpecialValueFor("duration")
	print( duration, radius )
	if caster:HasTalent("special_bonus_unique_enchantress_untouchable_bh_2") then
		point = self:GetCursorPosition()
	end

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_enchantress/enchantress_untouchable_cast.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControl(nfx, 0, point)
				ParticleManager:SetParticleControl(nfx, 1, Vector(radius, radius, radius))
				ParticleManager:ReleaseParticleIndex(nfx)

	local enemies = caster:FindEnemyUnitsInRadius(point, radius)
	for _,enemy in pairs(enemies) do
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_enchantress/enchantress_untouchable.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, enemy, PATTACH_POINT, "attach_hitloc", enemy:GetAbsOrigin(), true)
					ParticleManager:ReleaseParticleIndex(nfx)

		enemy:AddNewModifier(caster, self, "modifier_enchantress_untouchable_bh_slow", {Duration = duration})
	end
	self:StartDelayedCooldown(duration)
end

modifier_enchantress_untouchable_bh = class({})
LinkLuaModifier("modifier_enchantress_untouchable_bh", "heroes/hero_enchantress/enchantress_untouchable_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_enchantress_untouchable_bh:OnCreated()
	self.duration = self:GetTalentSpecialValueFor("duration") / 2
end

function modifier_enchantress_untouchable_bh:OnRefresh()
	self.duration = self:GetTalentSpecialValueFor("duration") / 2
end

function modifier_enchantress_untouchable_bh:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_RECORD, MODIFIER_EVENT_ON_ATTACK_START}
end

function modifier_enchantress_untouchable_bh:OnAttackRecord(params)
	if params.target == self:GetParent() then
		params.attacker:AddNewModifier(params.target, self:GetAbility(), "modifier_enchantress_untouchable_bh_passive_slow", {duration = self.duration})
	elseif params.attacker:HasModifier("modifier_enchantress_untouchable_bh_passive_slow") then
		params.attacker:RemoveModifierByName("modifier_enchantress_untouchable_bh_passive_slow")
	end
end

function modifier_enchantress_untouchable_bh:OnAttackStart(params)
	if params.target == self:GetParent() then
		params.attacker:AddNewModifier(params.target, self:GetAbility(), "modifier_enchantress_untouchable_bh_passive_slow", {duration = self.duration})
	elseif params.attacker:HasModifier("modifier_enchantress_untouchable_bh_passive_slow") then
		params.attacker:RemoveModifierByName("modifier_enchantress_untouchable_bh_passive_slow")
	end
end

function modifier_enchantress_untouchable_bh:IsHidden()
	return true
end

modifier_enchantress_untouchable_bh_slow = class({})
LinkLuaModifier("modifier_enchantress_untouchable_bh_slow", "heroes/hero_enchantress/enchantress_untouchable_bh", LUA_MODIFIER_MOTION_NONE)
function modifier_enchantress_untouchable_bh_slow:OnCreated(table)
	self.slow_as = self:GetTalentSpecialValueFor("slow_as")
	self.slow_ms = self:GetCaster():FindTalentValue("special_bonus_unique_enchantress_untouchable_bh_1", "ms")
	if IsServer() then
		EmitSoundOn("Hero_Enchantress.Untouchable", self:GetParent())
	end
end

function modifier_enchantress_untouchable_bh_slow:OnRefresh(table)
	self.slow_as = self:GetTalentSpecialValueFor("slow_as")
	self.slow_ms = self:GetCaster():FindTalentValue("special_bonus_unique_enchantress_untouchable_bh_1", "ms")
end

function modifier_enchantress_untouchable_bh_slow:DeclareFunctions()
	local funcs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
	return funcs
end

function modifier_enchantress_untouchable_bh_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.slow_ms
end

function modifier_enchantress_untouchable_bh_slow:OnRemoved()
	if IsServer() then
		self:GetAbility():EndDelayedCooldown()
	end
end

function modifier_enchantress_untouchable_bh_slow:GetModifierAttackSpeedBonus()
	return self.slow_as
end

function modifier_enchantress_untouchable_bh_slow:GetEffectName()
	return "particles/units/heroes/hero_enchantress/enchantress_untouchable_debuff.vpcf"
end

function modifier_enchantress_untouchable_bh_slow:GetStatusEffectName()
	return "particles/status_fx/status_effect_enchantress_untouchable.vpcf"
end

function modifier_enchantress_untouchable_bh_slow:StatusEffectPriority()
	return 11
end

function modifier_enchantress_untouchable_bh_slow:IsDebuff()
	return true
end

modifier_enchantress_untouchable_bh_passive_slow = class({})
LinkLuaModifier("modifier_enchantress_untouchable_bh_passive_slow", "heroes/hero_enchantress/enchantress_untouchable_bh", LUA_MODIFIER_MOTION_NONE)
function modifier_enchantress_untouchable_bh_passive_slow:OnCreated(table)
	self.slow_as = self:GetTalentSpecialValueFor("passive_as")
	self.slow_ms = self:GetCaster():FindTalentValue("special_bonus_unique_enchantress_untouchable_bh_1", "passive_ms")
	if IsServer() then
		EmitSoundOn("Hero_Enchantress.Untouchable", self:GetParent())
	end
end

function modifier_enchantress_untouchable_bh_passive_slow:OnRefresh(table)
	self.slow_as = self:GetTalentSpecialValueFor("passive_as")
	self.slow_ms = self:GetCaster():FindTalentValue("special_bonus_unique_enchantress_untouchable_bh_1", "passive_ms")
end

function modifier_enchantress_untouchable_bh_passive_slow:DeclareFunctions()
	local funcs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
	return funcs
end

function modifier_enchantress_untouchable_bh_passive_slow:GetModifierMoveSpeedBonus_Percentage()
	if not self:GetParent():HasModifier("modifier_enchantress_untouchable_bh_slow") then return self.slow_ms end
end

function modifier_enchantress_untouchable_bh_passive_slow:OnRemoved()
	if IsServer() then
		self:GetAbility():EndDelayedCooldown()
	end
end

function modifier_enchantress_untouchable_bh_passive_slow:GetModifierAttackSpeedBonus()
	if not self:GetParent():HasModifier("modifier_enchantress_untouchable_bh_slow") then return self.slow_as end
end

function modifier_enchantress_untouchable_bh_passive_slow:GetEffectName()
	return "particles/units/heroes/hero_enchantress/enchantress_untouchable_debuff.vpcf"
end

function modifier_enchantress_untouchable_bh_passive_slow:GetStatusEffectName()
	return "particles/status_fx/status_effect_enchantress_untouchable.vpcf"
end

function modifier_enchantress_untouchable_bh_passive_slow:StatusEffectPriority()
	return 11
end

function modifier_enchantress_untouchable_bh_passive_slow:IsDebuff()
	return true
end

function modifier_enchantress_untouchable_bh_passive_slow:IsHidden()
	return self:GetParent():HasModifier("modifier_enchantress_untouchable_bh_slow")
end