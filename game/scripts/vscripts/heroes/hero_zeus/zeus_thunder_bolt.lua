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
	EmitSoundOn("Hero_Zuus.LightningBolt.Cast", caster)
	
	if target then
		point = target:GetAbsOrigin()
	end
	ParticleManager:FireRopeParticle("particles/units/heroes/hero_zeus/zeus_thunder_bolt.vpcf", PATTACH_POINT, caster, point, {[0]=point+Vector(0,0,1000)})
	EmitSoundOnLocationWithCaster(point, "Hero_Zuus.LightningBolt", caster)	
	if not target or  target:TriggerSpellAbsorb( self ) then return end
	
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

function modifier_zeus_thunder_bolt_talent:GetModifierAttackSpeedBonus()
	return self.as
end