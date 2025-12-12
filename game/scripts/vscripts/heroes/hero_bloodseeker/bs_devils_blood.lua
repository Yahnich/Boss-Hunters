bs_devils_blood = class({})

function bs_devils_blood:IsStealable()
	return true
end

function bs_devils_blood:IsHiddenWhenStolen()
	return false
end

function bs_devils_blood:OnSpellStart()
	local caster = self:GetCaster()
	
	EmitSoundOn("Hero_Bloodseeker.BloodRite.Cast", caster)
	caster:AddNewModifier(caster, self, "modifier_bs_devils_blood", {Duration = self:GetSpecialValueFor("duration")})
end

function bs_devils_blood:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()
	if hTarget then
		self:DealDamage(caster, hTarget, self:GetSpecialValueFor("damage"), {}, 0)
	end
end

modifier_bs_devils_blood = class({})
LinkLuaModifier("modifier_bs_devils_blood", "heroes/hero_bloodseeker/bs_devils_blood", LUA_MODIFIER_MOTION_NONE)

function modifier_bs_devils_blood:OnCreated(table)
	self.tick = self:GetSpecialValueFor("tick_rate")
	self.damage = self:GetSpecialValueFor("damage")
	self.duration = self:GetSpecialValueFor("debuff_duration")
	if IsServer() then
		local caster = self:GetParent()

		EmitSoundOn("hero_bloodseeker.rupture_FP", caster)
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_devils_blood_breath.vpcf", PATTACH_POINT_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 3, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true)
		self:AttachEffect(nfx)

		self:StartIntervalThink(self.tick)
	end
end

function modifier_bs_devils_blood:OnIntervalThink()
	local caster = self:GetParent()
	local ability = self:GetAbility()
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

		ability:DealDamage(caster, enemy, self.damage*self.tick, {}, 0)
		enemy:AddNewModifier( caster, ability, "modifier_bs_devils_blood_debuff", {duration = self.duration})
	end

	if caster:HasTalent("special_bonus_unique_bs_devils_blood_2") then
		if self:RollPRNG(caster:FindTalentValue("special_bonus_unique_bs_devils_blood_2")) then
			local enemy = enemies[RandomInt(1, #enemies)]
			ability:FireTrackingProjectile("particles/units/heroes/hero_bloodseeker/bloodseeker_devils_blood_projectile.vpcf", enemy, 1000, {}, DOTA_PROJECTILE_ATTACHMENT_HITLOCATION, false, false, 0)
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


modifier_bs_devils_blood_debuff = class({})
LinkLuaModifier("modifier_bs_devils_blood_debuff", "heroes/hero_bloodseeker/bs_devils_blood", LUA_MODIFIER_MOTION_NONE)

function modifier_bs_devils_blood_debuff:OnCreated()
	self.slow = self:GetSpecialValueFor("debuff_slow")
	self.sr = self:GetSpecialValueFor("debuff_sr")
end

function modifier_bs_devils_blood_debuff:OnRefresh()
	self.slow = self:GetSpecialValueFor("debuff_slow")
	self.sr = self:GetSpecialValueFor("debuff_sr")
end

function modifier_bs_devils_blood_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_bs_devils_blood_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_bs_devils_blood_debuff:GetModifierStatusResistanceStacking()
	return self.sr
end

function modifier_bs_devils_blood_debuff:GetEffectName()
	return "particles/econ/items/bloodseeker/bloodseeker_ti7/bloodseeker_ti7_overhead_vision_drips.vpcf"
end

function modifier_bs_devils_blood_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end


function modifier_bs_devils_blood_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_rupture.vpcf"
end

function modifier_bs_devils_blood_debuff:StatusEffectPriority()
	return 10
end