bs_devils_blood = class({})
LinkLuaModifier("modifier_bs_devils_blood", "heroes/hero_bloodseeker/bs_devils_blood", LUA_MODIFIER_MOTION_NONE)

function bs_devils_blood:IsStealable()
	return true
end

function bs_devils_blood:IsHiddenWhenStolen()
	return false
end

function bs_devils_blood:OnSpellStart()
	local caster = self:GetCaster()
	
	EmitSoundOn("Hero_Bloodseeker.BloodRite.Cast", caster)
	caster:AddNewModifier(caster, self, "modifier_bs_devils_blood", {Duration = self:GetTalentSpecialValueFor("duration")})
end

function bs_devils_blood:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()
	if hTarget then
		self:DealDamage(caster, hTarget, self:GetTalentSpecialValueFor("damage"), {}, 0)
	end
end

modifier_bs_devils_blood = class({})

function modifier_bs_devils_blood:OnCreated(table)
	if IsServer() then
		local caster = self:GetParent()

		EmitSoundOn("hero_bloodseeker.rupture_FP", caster)
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_devils_blood_breath.vpcf", PATTACH_POINT_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 3, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true)
		self:AttachEffect(nfx)

		self:StartIntervalThink(self:GetTalentSpecialValueFor("tick_rate"))
	end
end

function modifier_bs_devils_blood:OnIntervalThink()
	local caster = self:GetParent()
	local vDir = caster:GetForwardVector()
	local vPos = caster:GetAbsOrigin()
	local length = 500
	local radius = 300

	local enemies = caster:FindEnemyUnitsInCone(vDir, vPos, radius, length, {})
	for _,enemy in pairs(enemies) do
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_devils_blood_projectile_c.vpcf", PATTACH_POINT_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 3, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
					ParticleManager:ReleaseParticleIndex(nfx)

		self:GetAbility():DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage")*self:GetTalentSpecialValueFor("tick_rate"), {}, 0)
	end

	if caster:HasTalent("special_bonus_unique_bs_devils_blood_2") then
		if self:RollPRNG(caster:FindTalentValue("special_bonus_unique_bs_devils_blood_2")) then
			local enemies = caster:FindEnemyUnitsInCone(vDir, vPos, radius, length, {})
			for _,enemy in pairs(enemies) do
				self:GetAbility():FireTrackingProjectile("particles/units/heroes/hero_bloodseeker/bloodseeker_devils_blood_projectile.vpcf", enemy, 1000, {}, DOTA_PROJECTILE_ATTACHMENT_HITLOCATION, false, false, 0)
				break
			end
		end
	end
end

function modifier_bs_devils_blood:OnRemoved()
	if IsServer() then
		StopSoundOn("hero_bloodseeker.rupture_FP", self:GetParent())
	end
end

function modifier_bs_devils_blood:IsDebuff()
	return false
end