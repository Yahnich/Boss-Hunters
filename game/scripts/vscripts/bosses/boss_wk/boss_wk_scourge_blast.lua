boss_wk_scourge_blast = class({})

function boss_wk_scourge_blast:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	if caster:HasModifier("modifier_boss_wk_reincarnation_enrage") then
		ParticleManager:FireWarningParticle(caster:GetAbsOrigin(), self:GetTrueCastRange())
	else
		local direction = CalculateDirection(target, caster)
		local origPos = caster:GetAbsOrigin()
		local endPos = caster:GetAbsOrigin() + direction * 900
		
		local width = self:GetSpecialValueFor("width")
		local radius = self:GetSpecialValueFor("radius")
		
		ParticleManager:FireWarningParticle(endPos, 225)
		ParticleManager:FireLinearWarningParticle(origPos, endPos, 120)
	end
	return true
end

function boss_wk_scourge_blast:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	
	local direction = CalculateDirection(target, caster)
	local distance = 900
	
	local width = self:GetSpecialValueFor("width")
	caster:EmitSound("Hero_SkeletonKing.Hellfire_Blast")
	if caster:HasModifier("modifier_boss_wk_reincarnation_enrage") then	
		distance = self:GetTrueCastRange()
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), distance ) ) do
			self:FireTrackingProjectile("particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast.vpcf", enemy, 150, { duration = GameRules:GetGameTime() + 5 })
		end
	else
		self:FireLinearProjectile("particles/frostivus_gameplay/frostivus_skeletonking_hellfireblast.vpcf", direction * 900, distance, width, {origin = caster:GetAbsOrigin() + Vector(0,0,128)})
	end
end

function boss_wk_scourge_blast:OnProjectileHit(target, position)
	local caster = self:GetCaster()
	
	local stunDuration = self:GetSpecialValueFor("stun_duration")
	local totDuration = self:GetSpecialValueFor("total_duration")
	local damage = self:GetSpecialValueFor("impact_damage")
	local radius = self:GetSpecialValueFor("radius")
	
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius ) ) do
		if not enemy:TriggerSpellAbsorb(self) then
			self:DealDamage(caster, enemy, damage)
			self:Stun(enemy, stunDuration)
			enemy:AddNewModifier( caster, self, "modifier_boss_wk_scourge_blast_debuff", {duration = totDuration})
		end
	end
	EmitSoundOnLocationWithCaster(position, "Hero_SkeletonKing.Hellfire_BlastImpact", caster)
	return true
end

modifier_boss_wk_scourge_blast_debuff = class({})
LinkLuaModifier("modifier_boss_wk_scourge_blast_debuff", "bosses/boss_wk/boss_wk_scourge_blast", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_wk_scourge_blast_debuff:OnCreated()
	self.damage = self:GetSpecialValueFor("burn_damage")
	self.slow = self:GetSpecialValueFor("slow")
end

function modifier_boss_wk_scourge_blast_debuff:OnRefresh()
	self.damage = self:GetSpecialValueFor("burn_damage")
	self.slow = self:GetSpecialValueFor("slow")
end

function modifier_boss_wk_scourge_blast_debuff:OnIntervalThink()
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage)
end

function modifier_boss_wk_scourge_blast_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_boss_wk_scourge_blast_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_boss_wk_scourge_blast_debuff:GetEffectName()
	return "particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast_debuff.vpcf"
end