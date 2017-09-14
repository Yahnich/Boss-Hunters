mystic_grim_harvest = class({})

function mystic_grim_harvest:OnSpellStart()
	local caster = self:GetCaster()
	local mousePos = self:GetCursorPosition()
	
	local vDir = CalculateDirection(mousePos, caster) * Vector(1,1,0)
	local orbDuration = self:GetSpecialValueFor("orb_lifetime")
	local orbSpeed = self:GetSpecialValueFor("orb_speed")
	local orbRadius = self:GetSpecialValueFor("orb_radius")
	local orbAliveTime = 0
	
	local position = caster:GetAbsOrigin()
	local vVelocity = vDir * orbSpeed * FrameTime() * 0.8
	
	if caster:HasTalent("mystic_grim_harvest_talent_1") then
		position =  mousePos
		vVelocity = Vector(0,0,0)
	end
	
	position = GetGroundPosition(position, nil) + Vector(0,0,128)
	local grimOrb = ParticleManager:CreateParticle("particles/heroes/mystic/mystic_grim_harvest.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl( grimOrb, 2, Vector(orbSpeed,0,0) )
	ParticleManager:SetParticleControl( grimOrb, 0, position )
	ParticleManager:SetParticleControl( grimOrb, 1, position )
	ParticleManager:SetParticleControl( grimOrb, 3, position )
	
	local HOMING_FACTOR = 0.03
	
	Timers:CreateTimer(FrameTime(), function()
		local homeEnemies = caster:FindEnemyUnitsInRadius(position, orbRadius * 0.7, {order = FIND_CLOSEST})
		for _, enemy in ipairs(homeEnemies) do
			vVelocity = vVelocity + CalculateDirection(enemy, position) * orbSpeed * HOMING_FACTOR * FrameTime()
			if vVelocity:Length2D() > orbSpeed * FrameTime() then vVelocity = vVelocity:Normalized() * orbSpeed * FrameTime() end
			break
		end
		if #homeEnemies == 0 then
			vVelocity = vVelocity + CalculateDirection(mousePos, position) * orbSpeed * HOMING_FACTOR * FrameTime()
			if vVelocity:Length2D() > orbSpeed * FrameTime() then vVelocity = vVelocity:Normalized() * orbSpeed * FrameTime() end
		end
		position = GetGroundPosition(position, nil) + Vector(0,0,128) + vVelocity
		ParticleManager:SetParticleControl( grimOrb, 2, Vector(vVelocity:Length2D() / FrameTime(),0,0) )
		ParticleManager:SetParticleControl( grimOrb, 0, position )
		ParticleManager:SetParticleControl( grimOrb, 1, position )
		ParticleManager:SetParticleControl( grimOrb, 3, position )
		homeEnemies = nil
		local enemies = caster:FindEnemyUnitsInRadius(position, orbRadius)
		for _, enemy in ipairs(enemies) do
			enemy:AddNewModifier(caster, self, "modifier_mystic_grim_harvest_debuff", {duration = 0.5})
		end
		if orbAliveTime < orbDuration then
			orbAliveTime = orbAliveTime + FrameTime()
			return FrameTime()
		else
			ParticleManager:DestroyParticle(grimOrb, false)
			ParticleManager:ReleaseParticleIndex(grimOrb)
		end
	end)
end

modifier_mystic_grim_harvest_debuff = class({})
LinkLuaModifier("modifier_mystic_grim_harvest_debuff", "heroes/mystic/mystic_grim_harvest.lua", 0)

function modifier_mystic_grim_harvest_debuff:OnCreated()
	self.amp = self:GetSpecialValueFor("damage_amp")
	self.lifesteal = self:GetSpecialValueFor("lifesteal") / 100
end

function modifier_mystic_grim_harvest_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end


function modifier_mystic_grim_harvest_debuff:GetModifierIncomingDamage_Percentage(params)
	if params.attacker:IsSameTeam(self:GetCaster()) then
		params.attacker:HealEvent(params.damage * self.lifesteal, self:GetAbility(), params.attacker)
	end
	return self.amp
end

function modifier_mystic_grim_harvest_debuff:GetEffectName()
	return "particles/heroes/mystic/mystic_grim_harvest_debuff.vpcf"
end


function modifier_mystic_grim_harvest_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_rupture.vpcf"
end

function modifier_mystic_grim_harvest_debuff:StatusEffectPriority()
	return 2
end