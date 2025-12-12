puck_illusory_orb_ebf = class({})

function puck_illusory_orb_ebf:GetAssociatedPrimaryAbilities()
	return "puck_ethereal_jaunt_ebf"
end

function puck_illusory_orb_ebf:IsHiddenWhenStolen()
	return false
end

function puck_illusory_orb_ebf:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	
	local speed = self:GetSpecialValueFor("orb_speed")
	local velocity =  CalculateDirection( target, caster ) * speed
	
	self.orbProjectiles = self.orbProjectiles or {}
	
	self:CreateOrb(velocity)
	if caster:HasTalent("special_bonus_unique_puck_illusory_orb_1") then
		self:CreateOrb(-velocity)
	end
	
	EmitSoundOn("Hero_Puck.Illusory_Orb", caster)
end

function puck_illusory_orb_ebf:CreateOrb(velocity, position)
	local caster = self:GetCaster()
	local distance = self:GetSpecialValueFor("max_distance")
	local width = self:GetSpecialValueFor("radius")
	local vision = self:GetSpecialValueFor("orb_vision")
	local projID = self:FireLinearProjectile("particles/units/heroes/hero_puck/puck_illusory_orb.vpcf", velocity, distance, width, {origin = position or caster:GetAbsOrigin()}, false, true, vision)
	self.orbProjectiles[projID] = true
	
	self.jaunt = caster:FindAbilityByName( self:GetAssociatedPrimaryAbilities() )
	self.jaunt:SetActivated(true)
end

function puck_illusory_orb_ebf:OnProjectileHitHandle( target, position, projID )	
	local caster = self:GetCaster()
	local orbDamage = self:GetSpecialValueFor("damage")
	if target and not target:TriggerSpellAbsorb( self ) then
		self:DealDamage( caster, target, orbDamage )
		EmitSoundOn("Hero_Puck.IIllusory_Orb_Damage", target)
	else
		self:OnOrbDestroyed(projID, position)
	end
end

function puck_illusory_orb_ebf:OnOrbDestroyed(projID, position)
	local caster = self:GetCaster()
	
	local pRadius = self:GetSpecialValueFor("radius")
	local vRadius = self:GetSpecialValueFor("orb_vision")
	local vDuration = self:GetSpecialValueFor("vision_duration")
	
	AddFOWViewer ( caster:GetTeam(), position, vRadius, vDuration, false)
	if caster:HasTalent("special_bonus_unique_puck_illusory_orb_2") then
		local orbDamage = self:GetSpecialValueFor("damage")
		local radInc = caster:FindTalentValue("special_bonus_unique_puck_illusory_orb_2")
		local dmgPct = caster:FindTalentValue("special_bonus_unique_puck_illusory_orb_2", "damage") / 100
		ParticleManager:FireParticle("particles/heroes/hero_puck/puck_illusory_orb_talentalliance_explosion.vpcf", PATTACH_WORLDORIGIN, nil, {[1] = position + Vector(0,0, 24)})
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius(position, vRadius * radInc) ) do
			local damage = orbDamage * dmgPct
		end
	end
	self.orbProjectiles[projID] = nil
	self.jaunt:SetActivated(false)
	for projectile,_ in pairs(self.orbProjectiles) do
		self.jaunt:SetActivated(true)
	end
end