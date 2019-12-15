tinker_laser_ebf = class({})
LinkLuaModifier("modifier_tinker_laser_ebf_blind", "heroes/hero_tinker/tinker_laser_ebf", 0)

function tinker_laser_ebf:OnAbilityPhaseStart()
	EmitSoundOn("Hero_Tinker.LaserAnim", self:GetCaster())
	return true
end

function tinker_laser_ebf:OnAbilityPhaseInterrupted()
	StopSoundOn("Hero_Tinker.LaserAnim", self:GetCaster())
end

function tinker_laser_ebf:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	EmitSoundOn("Hero_Tinker.Laser", caster)
	self:FireLaser(target)
	
	local hitTargets = {}
	local FindNextUnit = function(lastTarget, targetList)
		for _, unit in ipairs( self:GetCaster():FindEnemyUnitsInRadius(lastTarget:GetAbsOrigin(), self:GetTrueCastRange(), {order = FIND_CLOSEST}) ) do
			if not targetList[unit:entindex()] then
				return unit
			end
		end
	end
	while FindNextUnit(target, hitTargets) do
		local newTarget = FindNextUnit(target, hitTargets)
		hitTargets[target:entindex()] = true
		self:FireLaser(newTarget, target)
		target = newTarget
	end
end

function tinker_laser_ebf:FireLaser(target, oldTarget)
	local caster = self:GetCaster()
	
	EmitSoundOn("Hero_Tinker.LaserImpact", target)
	
	local owner = oldTarget or caster
	local FX = ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/tinker_laser.vpcf", PATTACH_POINT_FOLLOW, owner)

	ParticleManager:SetParticleControlEnt(FX, 9, owner, PATTACH_POINT_FOLLOW, "attach_attack2", owner:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(FX, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	
	ParticleManager:ReleaseParticleIndex(FX)
	
	if target:TriggerSpellAbsorb( self ) then return end
	
	local laserDamage = self:GetTalentSpecialValueFor("laser_damage")

	if caster:HasTalent("special_bonus_unique_tinker_laser_ebf_2") then
		local blindDuration = caster:FindTalentValue("special_bonus_unique_tinker_laser_ebf_2")
		target:AddNewModifier(caster, self, "modifier_tinker_laser_ebf_blind", {duration = blindDuration})
	end

	self:DealDamage(caster, target, laserDamage)
end

modifier_tinker_laser_ebf_blind = class({})

function modifier_tinker_laser_ebf_blind:OnCreated()
	self.miss = self:GetCaster():FindTalentValue("special_bonus_unique_tinker_laser_ebf_2", "blind")
end

function modifier_tinker_laser_ebf_blind:OnRefresh()
	self.miss = self:GetCaster():FindTalentValue("special_bonus_unique_tinker_laser_ebf_2", "blind")
end

function modifier_tinker_laser_ebf_blind:DeclareFunctions()
	return {MODIFIER_PROPERTY_MISS_PERCENTAGE}
end

function modifier_tinker_laser_ebf_blind:GetModifierMiss_Percentage()
	return self.miss
end

function modifier_tinker_laser_ebf_blind:GetEffectName()
	return "particles/units/heroes/hero_tinker/tinker_laser_debuff.vpcf"
end