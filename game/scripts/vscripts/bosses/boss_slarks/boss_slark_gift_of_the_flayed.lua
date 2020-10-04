boss_slark_gift_of_the_flayed = class({})

function boss_slark_gift_of_the_flayed:OnSpellStart()
	local caster = self:GetCaster()
	
	EmitSoundOn("Hero_Bloodseeker.BloodRite.Cast", caster)
	caster:AddNewModifier(caster, self, "modifier_boss_slark_gift_of_the_flayed", {Duration = 0.5})
end

modifier_boss_slark_gift_of_the_flayed = class({})
LinkLuaModifier("modifier_boss_slark_gift_of_the_flayed", "bosses/boss_slarks/boss_slark_gift_of_the_flayed", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_slark_gift_of_the_flayed:OnCreated(table)
	self.tick = 0.1
	self.radius = self:GetSpecialValueFor("end_width") / 2
	self.length = self:GetSpecialValueFor("distance")
	self.duration = self:GetSpecialValueFor("duration")
	if IsServer() then
		self.hitEnemies = {}
		local caster = self:GetParent()

		EmitSoundOn("hero_bloodseeker.rupture_FP", caster)
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_devils_blood_breath.vpcf", PATTACH_POINT_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 3, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true)
		self:AttachEffect(nfx)

		self:StartIntervalThink(self.tick)
	end
end

function modifier_boss_slark_gift_of_the_flayed:OnIntervalThink()
	local caster = self:GetParent()
	local ability = self:GetAbility()
	local vDir = caster:GetForwardVector()
	local vPos = caster:GetAbsOrigin()

	local enemies = caster:FindEnemyUnitsInCone(vDir, vPos, self.radius, self.length, {})
	for _,enemy in pairs(enemies) do
		if not self.hitEnemies[enemy] then
			if not enemy:TriggerSpellAbsorb( ability ) then
				local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_devils_blood_projectile_c.vpcf", PATTACH_POINT_FOLLOW, caster)
							ParticleManager:SetParticleControlEnt(nfx, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
							ParticleManager:SetParticleControlEnt(nfx, 3, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
							ParticleManager:ReleaseParticleIndex(nfx)
				enemy:AddNewModifier( caster, ability, "modifier_boss_slark_gift_of_the_flayed_debuff", {duration = self.duration})
			end
			self.hitEnemies[enemy] = true
		end
	end
end

function modifier_boss_slark_gift_of_the_flayed:OnRemoved()
	if IsServer() then
		StopSoundOn("hero_bloodseeker.rupture_FP", self:GetParent())
	end
end

function modifier_boss_slark_gift_of_the_flayed:IsDebuff()
	return false
end


modifier_boss_slark_gift_of_the_flayed_debuff = class({})
LinkLuaModifier("modifier_boss_slark_gift_of_the_flayed_debuff", "bosses/boss_slarks/boss_slark_gift_of_the_flayed", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_slark_gift_of_the_flayed_debuff:OnCreated()
	if IsServer() then
		self.lastPos = self:GetParent():GetAbsOrigin()
		self:OnRefresh()
		self:StartIntervalThink(0.25)
	end
end

function modifier_boss_slark_gift_of_the_flayed_debuff:OnRefresh()
	self.moveLimit = self:GetSpecialValueFor("move_limit")
	self.moveDamage = self:GetSpecialValueFor("movement_damage_pct") / 100
end

function modifier_boss_slark_gift_of_the_flayed_debuff:OnIntervalThink()
	local parent = self:GetParent()
	local newPos = parent:GetAbsOrigin()
	local distance = CalculateDistance( newPos, self.lastPos )
	self.lastPos = newPos
	
	local damage = distance * self.moveDamage
	if distance < self.moveLimit and distance > 10 then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		ability:DealDamage( caster, parent, damage )
	end
end

function modifier_boss_slark_gift_of_the_flayed_debuff:CheckState()
	return {[MODIFIER_STATE_PASSIVES_DISABLED] = true}
end

function modifier_boss_slark_gift_of_the_flayed_debuff:GetEffectName()
	return "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf"
end

function modifier_boss_slark_gift_of_the_flayed_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_rupture.vpcf"
end

function modifier_boss_slark_gift_of_the_flayed_debuff:StatusEffectPriority()
	return 10
end