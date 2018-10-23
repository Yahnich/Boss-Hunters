sd_shadow_poison = class({})
LinkLuaModifier("modifier_sd_shadow_poison", "heroes/hero_shadow_demon/sd_shadow_poison", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sd_soul_catcher", "heroes/hero_shadow_demon/sd_soul_catcher", LUA_MODIFIER_MOTION_NONE)

function sd_shadow_poison:IsStealable()
	return true
end

function sd_shadow_poison:IsHiddenWhenStolen()
	return false
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

		local impactDamage = self:GetSpecialValueFor("damage_impact")

		if hTarget:HasModifier("modifier_sd_shadow_poison") then
			local stackDamage = hTarget:FindModifierByName("modifier_sd_shadow_poison"):GetStackCount()
			if stackDamage < 1 then stackDamage = 1 end
			impactDamage = impactDamage * stackDamage

			if hTarget:FindModifierByName("modifier_sd_shadow_poison"):GetStackCount() < self:GetSpecialValueFor("stacks") then
				hTarget:AddNewModifier(caster, self, "modifier_sd_shadow_poison", {Duration = self:GetSpecialValueFor("duration")}):IncrementStackCount()
			else
				hTarget:AddNewModifier(caster, self, "modifier_sd_shadow_poison", {Duration = self:GetSpecialValueFor("duration")})
			end
		else
			hTarget:AddNewModifier(caster, self, "modifier_sd_shadow_poison", {Duration = self:GetSpecialValueFor("duration")}):IncrementStackCount()
		end

		self:DealDamage(caster, hTarget, impactDamage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
	end
end

modifier_sd_shadow_poison = class({})
function modifier_sd_shadow_poison:OnCreated(table)
	if IsServer() then
		self:StartIntervalThink(1)
	end
end

function modifier_sd_shadow_poison:OnRefresh(table)
	if IsServer() then
		self:StartIntervalThink(1)
	end
end

function modifier_sd_shadow_poison:OnIntervalThink()
	local caster = self:GetCaster()

	self:GetAbility():DealDamage(caster, self:GetParent(), self:GetSpecialValueFor("damage_time") * self:GetStackCount(), {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
end

function modifier_sd_shadow_poison:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = caster:FindAbilityByName("sd_soul_catcher")

		if caster:HasTalent("special_bonus_unique_sd_shadow_poison_1") then
			if RollPercentage(25) then
				parent:AddNewModifier(caster, ability, "modifier_sd_soul_catcher", {Duration = ability:GetSpecialValueFor("duration")})
			end
		end
	end
end

function modifier_sd_shadow_poison:IsDebuff()
	return true
end