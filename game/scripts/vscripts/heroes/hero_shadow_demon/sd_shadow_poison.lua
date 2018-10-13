sd_shadow_poison = class({})
LinkLuaModifier("modifier_sd_shadow_poison", "heroes/hero_shadow_demon/sd_shadow_poison", LUA_MODIFIER_MOTION_NONE)

function sd_shadow_poison:IsStealable()
	return true
end

function sd_shadow_poison:IsHiddenWhenStolen()
	return false
end

function sd_shadow_poison:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    if self:GetCaster():HasTalent("special_bonus_unique_sd_shadow_poison_1") then cooldown = cooldown + self:GetCaster():FindTalentValue("special_bonus_unique_sd_shadow_poison_1") end
    return cooldown
end

function sd_shadow_poison:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	local direction = CalculateDirection(point, caster:GetAbsOrigin())
	local speed = self:GetSpecialValueFor("speed")
	local distance = self:GetSpecialValueFor("distance")
	local vVel = direction * speed

	EmitSoundOn("Hero_ShadowDemon.ShadowPoison.Cast", caster)
	EmitSoundOn("Hero_ShadowDemon.ShadowPoison", caster)

	self:FireLinearProjectile("particles/units/heroes/hero_shadow_demon/shadow_demon_shadow_poison_projectile.vpcf", vVel, distance, self:GetSpecialValueFor("width"), {}, false, true, 200)
end

function sd_shadow_poison:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()

	if hTarget then
		EmitSoundOn("Hero_ShadowDemon.ShadowPoison.Impact", hTarget)

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_shadow_demon/shadow_demon_loadout.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 2, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetAbsOrigin(), true)
					ParticleManager:SetParticleControl(nfx, 3, Vector(1,0,0))
					ParticleManager:ReleaseParticleIndex(nfx)

		hTarget:AddNewModifier(caster, self, "modifier_sd_shadow_poison", {Duration = self:GetSpecialValueFor("duration")})
	end
end

modifier_sd_shadow_poison = class({})
function modifier_sd_shadow_poison:OnCreated(table)
	if IsServer() then
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_sd_shadow_poison:OnRefresh(table)
	if IsServer() then
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_sd_shadow_poison:OnIntervalThink()
	local caster = self:GetCaster()

	self:GetAbility():DealDamage(caster, self:GetParent(), self:GetSpecialValueFor("damage"), {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)

	self:StartIntervalThink(1)
end

function modifier_sd_shadow_poison:IsDebuff()
	return true
end