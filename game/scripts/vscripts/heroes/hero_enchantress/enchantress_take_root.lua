enchantress_take_root = class({})
LinkLuaModifier("modifier_enchantress_take_root", "heroes/hero_enchantress/enchantress_take_root", LUA_MODIFIER_MOTION_NONE)
function enchantress_take_root:IsStealable()
    return false
end

function enchantress_take_root:IsHiddenWhenStolen()
    return false
end

function enchantress_take_root:GetCastRange(vLocation, hTarget)
	local range = self:GetCaster():GetAttackRange() + self:GetCaster():GetAttackRange() * self:GetTalentSpecialValueFor("bonus_ar")/100
    return range
end

function enchantress_take_root:OnToggle()
	local caster = self:GetCaster()

	if caster:HasModifier("modifier_enchantress_take_root") then
		caster:RemoveModifierByName("modifier_enchantress_take_root")
	else
		caster:AddNewModifier(caster, self, "modifier_enchantress_take_root", {})
	end
end

modifier_enchantress_take_root = class(toggleModifierBaseClass)
function modifier_enchantress_take_root:OnCreated(table)
	self.bonus_ar = self:GetParent():GetAttackRange() * self:GetTalentSpecialValueFor("bonus_ar")/100
	self.slow_as = self:GetTalentSpecialValueFor("slow_as")
	self.bonus_dmg = self:GetTalentSpecialValueFor("bonus_dmg")
	self.bonus_acc = self:GetTalentSpecialValueFor("bonus_acc")
	
	self:GetParent():HookInModifier("GetModifierAttackSpeedBonusPercentage", self)
	if IsServer() then
		local parent = self:GetParent()

		self.bonus_proj_speed = self:GetParent():GetProjectileSpeed() * self:GetTalentSpecialValueFor("bonus_proj_speed")/100

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_bear_entangle.vpcf", PATTACH_POINT, parent)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		self:AttachEffect(nfx)
	end
end

function modifier_enchantress_take_root:OnDestroy()
	self:GetParent():HookOutModifier("GetModifierAttackSpeedBonusPercentage", self)
end

function modifier_enchantress_take_root:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
			MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS,
			MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE}
end

function modifier_enchantress_take_root:GetModifierAttackRangeBonus()
	return self.bonus_ar
end

function modifier_enchantress_take_root:GetModifierProjectileSpeedBonus()
	return self.bonus_proj_speed
end

function modifier_enchantress_take_root:GetModifierAttackSpeedBonusPercentage()
	return self.slow_as
end

function modifier_enchantress_take_root:GetAccuracy()
	return self.bonus_acc
end

function modifier_enchantress_take_root:GetModifierDamageOutgoing_Percentage()
	return self.bonus_dmg
end

function modifier_enchantress_take_root:GetEffectName()
	return "particles/units/heroes/hero_lone_druid/lone_druid_bear_entangle_body.vpcf"
end

function modifier_enchantress_take_root:CheckState()
	return {[MODIFIER_STATE_ROOTED] = true}
end

function modifier_enchantress_take_root:IsDebuff()
	return false
end

function modifier_enchantress_take_root:IsPurgable()
	return false
end