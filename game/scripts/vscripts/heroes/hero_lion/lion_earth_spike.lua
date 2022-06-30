lion_earth_spike = class({})

function lion_earth_spike:IsStealable()
	return true
end

function lion_earth_spike:IsHiddenWhenStolen()
	return false
end

function lion_earth_spike:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

function lion_earth_spike:OnAbilityPhaseStart()
	local caster = self:GetCaster()

	ParticleManager:FireParticle("particles/units/heroes/hero_lion/lion_spell_impale_staff.vpcf", PATTACH_POINT_FOLLOW, caster, {[0]="attach_attack1"})
	return true
end

function lion_earth_spike:OnSpellStart()
	local caster = self:GetCaster()

	local point = self:GetCursorPosition()
	
	if self:GetCursorTarget() then
		point = self:GetCursorTarget():GetAbsOrigin()
	end

	EmitSoundOn("Hero_Lion.Impale", caster)

	local distance = self:GetTrueCastRange()
	local width = self:GetTalentSpecialValueFor("radius") 
	local direction = CalculateDirection(point,caster:GetAbsOrigin())
	local speed = self:GetTalentSpecialValueFor("speed")
	local velocity = direction * speed
	self.direction = direction
	
	if caster:HasTalent("special_bonus_unique_lion_earth_spike_1") then
		local spikes = caster:FindTalentValue("special_bonus_unique_lion_earth_spike_1", "spikes")
		
		local direction = caster:GetForwardVector()
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( point, 100 ) ) do
			self:OnProjectileHit_ExtraData( enemy, enemy:GetAbsOrigin(), {})
		end
		for i = 1, spikes do
			local rotation = ToRadians(360/spikes * math.floor(i / 2) * (-1)^i)
			local newDir = RotateVector2D( direction, rotation )
			local newVelocity = newDir * speed
			self:FireLinearProjectile("particles/units/heroes/hero_lion/lion_spell_impale.vpcf", newVelocity, self:GetTrueCastRange(), width, {}, {origin = point + newDir * 50}, false, true, 250)
		end
	else
		self:FireLinearProjectile("particles/units/heroes/hero_lion/lion_spell_impale.vpcf", velocity, distance, width, {extraData = {}}, false, true, 250)
	end
end

function lion_earth_spike:OnProjectileHit_ExtraData(hTarget, vLocation)
	local caster = self:GetCaster()
	
	if hTarget ~= nil and not hTarget:TriggerSpellAbsorb( self ) then
		EmitSoundOn("Hero_Lion.ImpaleHitTarget", hTarget)

		ParticleManager:FireParticle("particles/units/heroes/hero_lion/lion_spell_impale_hit_spikes.vpcf", PATTACH_POINT, hTarget, {[0]=hTarget:GetAbsOrigin(),[1]=hTarget:GetAbsOrigin(),[2]=hTarget:GetAbsOrigin()})

		hTarget:ApplyKnockBack(vLocation, 0.5, 0.5, 0, 350, caster, self)
		local stun = self:Stun(hTarget, self:GetTalentSpecialValueFor("duration"), false)
		if caster:HasTalent("special_bonus_unique_lion_earth_spike_2") then
			stun.OnRemoved = function()
				stun:GetParent():Root( stun:GetAbility(), stun:GetCaster(), stun:GetTalentSpecialValueFor("duration") )
			end
		end
		self:DealDamage(caster, hTarget, self:GetTalentSpecialValueFor("damage"), {}, 0)
	end
end