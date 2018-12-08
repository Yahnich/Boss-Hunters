enchantress_untouchable_bh = class({})
LinkLuaModifier("modifier_enchantress_untouchable_bh_slow", "heroes/hero_enchantress/enchantress_untouchable_bh", LUA_MODIFIER_MOTION_NONE)

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
    	return 500
    end
    return self:GetTalentSpecialValueFor("radius")
end

function enchantress_untouchable_bh:GetAOERadius()
    return self:GetTalentSpecialValueFor("radius") * 2
end

function enchantress_untouchable_bh:OnSpellStart()
	local caster = self:GetCaster()
	local point = caster:GetAbsOrigin()

	local radius = self:GetTalentSpecialValueFor("radius")
	
	if caster:HasTalent("special_bonus_unique_enchantress_untouchable_bh_2") then
		point = self:GetCursorPosition()
		radius = radius * 2
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

		enemy:AddNewModifier(caster, self, "modifier_enchantress_untouchable_bh_slow", {Duration = self:GetTalentSpecialValueFor("duration")})
	end

	self:StartDelayedCooldown(self:GetTalentSpecialValueFor("duration"))
end

modifier_enchantress_untouchable_bh_slow = class({})
function modifier_enchantress_untouchable_bh_slow:OnCreated(table)
	self.slow_as = self:GetTalentSpecialValueFor("slow_as")

	if self:GetCaster():HasTalent("special_bonus_unique_enchantress_untouchable_bh_1") then
		self.slow_ms = -50
	end

	if IsServer() then
		EmitSoundOn("Hero_Enchantress.Untouchable", self:GetParent())
	end
end

function modifier_enchantress_untouchable_bh_slow:OnRefresh(table)
	self.slow_as = self:GetTalentSpecialValueFor("slow_as")

	if self:GetCaster():HasTalent("special_bonus_unique_enchantress_untouchable_bh_1") then
		self.slow_ms = -50
	end
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

function modifier_enchantress_untouchable_bh_slow:IsPurgable()
	return true
end