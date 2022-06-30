zeus_thunder_bolt = class({})

function zeus_thunder_bolt:IsStealable()
    return true
end

function zeus_thunder_bolt:IsHiddenWhenStolen()
    return false
end

function zeus_thunder_bolt:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
	-- if self:GetCaster():HasTalent("special_bonus_unique_zeus_thunder_bolt_2") then cooldown = cooldown + self:GetCaster():FindTalentValue("special_bonus_unique_zeus_thunder_bolt_2") end
    return cooldown
end

function zeus_thunder_bolt:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local point = self:GetCursorPosition()

	if not target then
		local enemies = caster:FindEnemyUnitsInRadius(point, self:GetTalentSpecialValueFor("search_radius"), {order=FIND_CLOSEST})
		if enemies[1] then
			target = enemies[1]
			point = target:GetAbsOrigin()
		end
	end
	if target then
		point = target:GetAbsOrigin()
	end
	
	EmitSoundOn("Hero_Zuus.LightningBolt.Cast", caster)
	EmitSoundOnLocationWithCaster(point, "Hero_Zuus.LightningBolt", caster)	
	
	
	local bonusTargets = {}
	AddFOWViewer(caster:GetTeam(), point, self:GetTalentSpecialValueFor("vision_radius"), self:GetTalentSpecialValueFor("vision_duration"), false)
	ParticleManager:FireRopeParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_POINT, caster, point, {[0]=point+Vector(0,0,1000)})
	if target then 
		bonusTargets[target] = true
	end
	
	for _, cloud in ipairs( caster._NimbusClouds or {} ) do
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( cloud:GetAbsOrigin(), cloud.radius ) ) do
			bonusTargets[enemy] = true
		end
	end
	for enemy, state in pairs( bonusTargets ) do
		self:ApplyThunderBolt( enemy )
	end
end

function zeus_thunder_bolt:ApplyThunderBolt( target )
	local caster = self:GetCaster()
	local point = target:GetAbsOrigin()
	
	
	ParticleManager:FireRopeParticle("particles/units/heroes/hero_zuus/zuus_smaller_lightning_bolt.vpcf", PATTACH_POINT, caster, point, {[0]=point+Vector(0,0,1000)})
	
	if target:TriggerSpellAbsorb( self ) then return end
	
	self:DealDamage(caster, target, self:GetTalentSpecialValueFor("damage"), {}, 0)
	self:Stun(target, self:GetTalentSpecialValueFor("duration"), false)
	
	if caster:HasTalent("special_bonus_unique_zeus_thunder_bolt_2") then
		caster:AddNewModifier( caster, self, "modifier_zeus_thunder_bolt_talent", {duration = caster:FindTalentValue("special_bonus_unique_zeus_thunder_bolt_2", "duration")})
	end
	AddFOWViewer(caster:GetTeam(), point, self:GetTalentSpecialValueFor("vision_radius"), self:GetTalentSpecialValueFor("vision_duration"), false)
end

modifier_zeus_thunder_bolt_talent = class({})
LinkLuaModifier("modifier_zeus_thunder_bolt_talent", "heroes/hero_zeus/zeus_thunder_bolt", LUA_MODIFIER_MOTION_NONE)

function modifier_zeus_thunder_bolt_talent:OnCreated()
	self.as = self:GetCaster():FindTalentValue("special_bonus_unique_zeus_thunder_bolt_2")
end

function modifier_zeus_thunder_bolt_talent:OnCreated()
	self.as = self:GetCaster():FindTalentValue("special_bonus_unique_zeus_thunder_bolt_2")
end

function modifier_zeus_thunder_bolt_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_zeus_thunder_bolt_talent:GetModifierAttackSpeedBonus_Constant()
	return self.as
end