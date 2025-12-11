sd_void_release = class({})
LinkLuaModifier("modifier_sd_void_release_handle", "heroes/hero_shadow_demon/sd_void_release", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sd_void_release", "heroes/hero_shadow_demon/sd_void_release", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shadow_demon_insane", "heroes/hero_shadow_demon/sd_void_release", LUA_MODIFIER_MOTION_NONE)

function sd_void_release:IsStealable()
	return false
end

function sd_void_release:IsHiddenWhenStolen()
	return false
end

function sd_void_release:GetIntrinsicModifierName()
	return "modifier_sd_void_release_handle"
end

function sd_void_release:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()
	if hTarget then
		EmitSoundOn("Hero_ShadowDemon.ShadowPoison.Release", hTarget)
		self:DealDamage(caster, hTarget, caster:GetIntellect( false) * self:GetSpecialValueFor("damage")/100, {damage_type = DAMAGE_TYPE_MAGICAL}, 0)
	end
end

modifier_sd_void_release_handle = class({})
function modifier_sd_void_release_handle:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	return funcs
end

function modifier_sd_void_release_handle:OnTakeDamage(params)
	if IsServer() then
		local caster = self:GetCaster()
		if params.attacker == caster and params.unit ~= caster then
			if params.inflictor and params.inflictor ~= self:GetParent():FindAbilityByName("sd_void_release") and not params.inflictor:IsItem() then
				if self:RollPRNG(self:GetSpecialValueFor("chance")) then
					if params.unit:HasModifier("modifier_sd_shadow_poison") then
						self:GetAbility():FireTrackingProjectile("particles/units/heroes/hero_shadow_demon/shadow_demon_projection.vpcf", params.unit, 500, {}, DOTA_PROJECTILE_ATTACHMENT_HITLOCATION, true, true, 500)
					end
				end
			end
		end
	end
end

function modifier_sd_void_release_handle:IsHidden()
	return true
end