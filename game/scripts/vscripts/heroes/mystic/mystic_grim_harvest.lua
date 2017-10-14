mystic_grim_harvest = class({})

function mystic_grim_harvest:OnSpellStart()
	local caster = self:GetCaster()
	local mousePos = self:GetCursorPosition()
	
	local vDir = CalculateDirection(mousePos, caster) * Vector(1,1,0)
	local orbDuration = self:GetSpecialValueFor("orb_lifetime")
	local orbSpeed = self:GetSpecialValueFor("orb_speed")
	local orbRadius = self:GetSpecialValueFor("orb_radius")
	
	local position = caster:GetAbsOrigin()
	local vVelocity = vDir * orbSpeed * FrameTime() * 0.8
	
	if caster:HasTalent("mystic_grim_harvest_talent_1") then
		position =  mousePos
		vVelocity = Vector(0,0,0)
	end
	
	position = GetGroundPosition(position, nil) + Vector(0,0,128)
	
	local ProjectileThink = function(self, ... )
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local position = self:GetPosition()
		local orbRadius = self:GetRadius()
		local orbSpeed = self:GetSpeed()
		local orbVelocity = self:GetVelocity()
		local HOMING_FACTOR = 0.01
		
		local homeEnemies = caster:FindEnemyUnitsInRadius(position, orbRadius * 0.7, {order = FIND_CLOSEST})
		for _, enemy in ipairs(homeEnemies) do
			orbVelocity = orbVelocity + CalculateDirection(enemy, position) * orbSpeed * HOMING_FACTOR * FrameTime()
			if orbVelocity:Length2D() > orbSpeed * FrameTime() then orbVelocity = orbVelocity:Normalized() * orbSpeed * FrameTime() end
			if orbVelocity:Length2D() > CalculateDistance(position, enemy) then orbVelocity = orbVelocity:Normalized() * CalculateDistance(position, enemy) * FrameTime() end
			break
		end
		if #homeEnemies == 0 then
			orbVelocity = orbVelocity + CalculateDirection(mousePos, position) * orbSpeed * HOMING_FACTOR * FrameTime()
			if orbVelocity:Length2D() > orbSpeed * FrameTime() then orbVelocity = orbVelocity:Normalized() * orbSpeed * FrameTime() end
			if orbVelocity:Length2D() > CalculateDistance(position, mousePos) then orbVelocity = orbVelocity:Normalized() * CalculateDistance(position, mousePos) * FrameTime() end
		end

		self:SetVelocity( orbVelocity )
		self:SetPosition( GetGroundPosition(position, nil) + Vector(0,0,128) + orbVelocity )
		
		homeEnemies = nil
	end
	local ProjectileHit = function(self, target, position)
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		target:AddNewModifier(caster, ability, "modifier_mystic_grim_harvest_debuff", {duration = 0.5})
		return true
	end
	ProjectileHandler:CreateProjectile(ProjectileThink, ProjectileHit, {FX = "particles/heroes/mystic/mystic_grim_harvest.vpcf",
															  position = position,
															  caster = caster,
															  ability = self,
															  speed = orbSpeed,
															  radius = orbRadius,
															  velocity = vVelocity,
															  duration = orbDuration})
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