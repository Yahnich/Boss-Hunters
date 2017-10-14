wraith_wraithfire = class({})

function wraith_wraithfire:OnAbilityPhaseStart()
	self.warmUp = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast_warmup.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControlEnt(self.warmUp, 0, self:GetCaster(), PATTACH_CUSTOMORIGIN_FOLLOW, "attach_attack2", self:GetCaster():GetAbsOrigin(), true)
	return true
end

function wraith_wraithfire:OnAbilityPhaseInterrupted()
	ParticleManager:DestroyParticle(self.warmUp ,false)
	ParticleManager:ReleaseParticleIndex(self.warmUp)
end

function wraith_wraithfire:OnSpellStart()
	ParticleManager:DestroyParticle(self.warmUp ,false)
	ParticleManager:ReleaseParticleIndex(self.warmUp)
	local projectile = {
		Target = self:GetCursorTarget(),
		Source = self:GetCaster(),
		Ability = self,
		EffectName = "particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast.vpcf",
		bDodgable = true,
		bProvidesVision = false,
		iMoveSpeed = self:GetTalentSpecialValueFor("blast_speed"),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2,
	}
	ProjectileManager:CreateTrackingProjectile(projectile)
	EmitSoundOn("Hero_SkeletonKing.Hellfire_Blast", self:GetCaster())
end

function wraith_wraithfire:OnProjectileHit(target, position)
	EmitSoundOn("Hero_SkeletonKing.Hellfire_BlastImpact", target)
	local caster = self:GetCaster()
	local radius = self:GetTalentSpecialValueFor("blast_dot_radius")
	ApplyDamage({victim = target, attacker = caster, damage = self:GetSpecialValueFor("blast_damage"), damage_type = self:GetAbilityDamageType(), ability = self})
	local enemies = FindUnitsInRadius(caster:GetTeam(),
						  target:GetAbsOrigin(),
						  nil,
						  radius,
						  DOTA_UNIT_TARGET_TEAM_ENEMY,
						  DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
						  DOTA_UNIT_TARGET_FLAG_NONE,
						  FIND_ANY_ORDER,
						  false)
	local duration = self:GetSpecialValueFor("blast_dot_duration")
	target:AddNewModifier(caster, self, "modifier_stunned_generic", {duration = self:GetSpecialValueFor("blast_stun_duration")})
	for _, enemy in pairs(enemies) do
		enemy:AddNewModifier(caster, self, "modifier_wraith_wraithfire_dot", {duration = duration})
	end
	local explosion = ParticleManager:CreateParticle("particles/frostivus_gameplay/frostivus_skeletonking_hellfireblast_explosion_ebf.vpcf", PATTACH_POINT_FOLLOW, target)
		ParticleManager:SetParticleControl(explosion, 1, Vector(radius,0,0))
		ParticleManager:SetParticleControl(explosion, 3, target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(explosion)
end

LinkLuaModifier( "modifier_wraith_wraithfire_dot", "heroes/wraith/wraith_wraithfire.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_wraith_wraithfire_dot = class({})

function modifier_wraith_wraithfire_dot:OnCreated()
	self.damage = self:GetAbility():GetSpecialValueFor("blast_dot_damage")
	self.slow = self:GetAbility():GetSpecialValueFor("blast_slow")
	if IsServer() then
		self:StartIntervalThink(1)
	end
end

function modifier_wraith_wraithfire_dot:OnIntervalThink()
	ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = self.damage, damage_type = self:GetAbility():GetAbilityDamageType(), ability = self:GetAbility()})
end

function modifier_wraith_wraithfire_dot:GetEffectName()
	return "particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast_debuff.vpcf"
end

function modifier_wraith_wraithfire_dot:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_DISABLE_HEALING
			}
	return funcs
end

function modifier_wraith_wraithfire_dot:GetDisableHealing()
	if self:GetCaster():HasTalent("wraith_wraithfire_talent_1") then return 1 end
end

function modifier_wraith_wraithfire_dot:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end