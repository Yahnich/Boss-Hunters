puck_faerie_orb = class({})

function puck_faerie_orb:GetIntrinsicModifierName()
	if self:GetSpecialValueFor("cooldown_increase") ~= 0 then
		return "modifier_puck_faerie_orb_crystalhide"
	end
end

function puck_faerie_orb:GetAssociatedPrimaryAbilities()
	return "puck_wander"
end

function puck_faerie_orb:IsHiddenWhenStolen()
	return false
end

function puck_faerie_orb:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	
	local speed = self:GetSpecialValueFor("orb_speed")
	local velocity =  CalculateDirection( target, caster ) * speed
	
	self.orbProjectiles = self.orbProjectiles or {}
	
	self:CreateOrb(velocity)
	if self:GetSpecialValueFor("mirror_projectile") == 1 then
		self:CreateOrb(-velocity)
	end
	
	EmitSoundOn("Hero_Puck.Illusory_Orb", caster)
end

function puck_faerie_orb:CreateOrb(velocity, position)
	local caster = self:GetCaster()
	local distance = self:GetSpecialValueFor("max_distance")
	local width = self:GetSpecialValueFor("radius")
	local vision = self:GetSpecialValueFor("orb_vision")
	local projID = self:FireLinearProjectile("particles/units/heroes/hero_puck/puck_illusory_orb_linear_projectile.vpcf", velocity, distance, width, {origin = position or caster:GetAbsOrigin()}, false, true, vision)
	self.orbProjectiles[projID] = true
	
	self.jaunt = caster:FindAbilityByName( self:GetAssociatedPrimaryAbilities() )
	self.jaunt:SetActivated(true)
end

function puck_faerie_orb:OnProjectileHitHandle( target, position, projID )	
	local caster = self:GetCaster()
	local orbDamage = self:GetSpecialValueFor("damage")
	if target and not target:TriggerSpellAbsorb( self ) then
		self:DealDamage( caster, target, orbDamage )
		EmitSoundOn("Hero_Puck.IIllusory_Orb_Damage", target)
	else
		self:OnOrbDestroyed(projID, position)
	end
end

function puck_faerie_orb:OnProjectileThinkHandle(projID)
	if self:GetSpecialValueFor("pulse_radius") == 0 then return end
	local caster = self:GetCaster()
	local pulse_radius = self:GetSpecialValueFor("pulse_radius")
	local projLoc = ProjectileManager:GetLinearProjectileLocation(projID)
	--need to put pulse fx
	for _, enemy in ipairs(caster:FindEnemyUnitsInRadius(projLoc, pulse_radius )) do
		enemy:AddNewModifier(caster, self, "modifier_puck_faerie_orb_debuff", {duration = self:GetSpecialValueFor("debuff_duration")})
	end
end

function puck_faerie_orb:OnOrbDestroyed(projID, position)
	local caster = self:GetCaster()
	
	local pRadius = self:GetSpecialValueFor("radius")
	local vRadius = self:GetSpecialValueFor("orb_vision")
	local vDuration = self:GetSpecialValueFor("vision_duration")
	
	AddFOWViewer ( caster:GetTeam(), position, vRadius, vDuration, false)
	local dmgPct = self:GetSpecialValueFor("end_damage_pct") / 100
	if dmgPct > 0 then
		local orbDamage = self:GetSpecialValueFor("damage")
		local radInc = self:GetSpecialValueFor("end_damage_radius")
		ParticleManager:FireParticle("particles/units/heroes/hero_puck/puck_illusory_orb_explode.vpcf", PATTACH_WORLDORIGIN, nil, {[1] = position + Vector(0,0, 24)})
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius(position, pRadius * radInc) ) do
			local damage = orbDamage * dmgPct
			self:DealDamage(caster, enemy, damage)
		end
	end
	self.orbProjectiles[projID] = nil
	self.jaunt:SetActivated(false)
	for projectile,_ in pairs(self.orbProjectiles) do
		self.jaunt:SetActivated(true)
	end
	caster:StopSound("Hero_Puck.Illusory_Orb")
end

modifier_puck_faerie_orb_debuff = class({})
LinkLuaModifier("modifier_puck_faerie_orb_debuff", "heroes/hero_puck/puck_faerie_orb", LUA_MODIFIER_MOTION_NONE)

function modifier_puck_faerie_orb_debuff:IsDebuff()
	return true
end

function modifier_puck_faerie_orb_debuff:OnCreated()
	self:OnRefresh()
end

function modifier_puck_faerie_orb_debuff:OnRefresh()
	self.incoming_dmg = self:GetSpecialValueFor("incoming_dmg")
end

function modifier_puck_faerie_orb_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_puck_faerie_orb_debuff:GetModifierIncomingDamage_Percentage()
	return -self.incoming_dmg
end

function modifier_puck_faerie_orb_debuff:GetStatusEffectName()
	return "particles/heroes/hero_puck/puck_waning_rift_debuff_slow.vpcf"
end

modifier_puck_faerie_orb_crystalhide = class({})
LinkLuaModifier("modifier_puck_faerie_orb_crystalhide", "heroes/hero_puck/puck_faerie_orb", LUA_MODIFIER_MOTION_NONE)

function modifier_puck_faerie_orb_crystalhide:IsHidden()
	return true
end

function modifier_puck_faerie_orb_crystalhide:OnCreated()
	self:OnRefresh()
	self.tick = 0.33
end

function modifier_puck_faerie_orb_crystalhide:OnRefresh()
	self.cdr = self:GetSpecialValueFor("cooldown_increase") / 100
end

function modifier_puck_faerie_orb_crystalhide:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_puck_faerie_orb_crystalhide:OnAttackLanded(params)
	if not params.target == self:GetParent() then return end
	if IsServer() then self:StartIntervalThink(self.tick) end
end

function modifier_puck_faerie_orb_crystalhide:OnIntervalThink()
	local ability = self:GetAbility()
	if ability and ability:GetCooldownTimeRemaining() > 0 and ability ~= nil and not ability:IsInnateAbility() then
        ability:ModifyCooldown(-self.cdr * self.tick)
    end
end