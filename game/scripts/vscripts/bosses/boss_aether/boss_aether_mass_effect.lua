boss_aether_mass_effect = class({})

function boss_aether_mass_effect:OnSpellStart()
	local caster = self:GetCaster()
	local mousePos = self:GetCursorPosition()
	
	local vDir = CalculateDirection(mousePos, caster) * Vector(1,1,0)
	local orbDuration = self:GetSpecialValueFor("orb_lifetime")
	local orbSpeed = self:GetSpecialValueFor("orb_speed")
	local orbRadius = self:GetSpecialValueFor("orb_radius")
	
	local position = caster:GetAbsOrigin()
	local vVelocity = vDir * orbSpeed * FrameTime() * 0.8
	
	EmitSoundOn("Hero_ElderTitan.AncestralSpirit.Cast", caster)
	
	local ProjectileThink = function(self, ... )
		local caster = self:GetCaster()
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
		if target and target:GetTeam() ~= self:GetCaster():GetTeam() then
			local caster = self:GetCaster()
			local ability = self:GetAbility()
			target:AddNewModifier(caster, ability, "modifier_boss_aether_mass_effect_debuff", {duration = 0.5})
		end
		return true
	end
	ProjectileHandler:CreateProjectile(ProjectileThink, ProjectileHit, {  FX = "particles/bosses/boss_aether/boss_aether_mass_effect.vpcf",
																		  position = position,
																		  caster = caster,
																		  ability = self,
																		  speed = orbSpeed,
																		  radius = orbRadius,
																		  velocity = vVelocity,
																		  duration = orbDuration})
end

modifier_boss_aether_mass_effect_debuff = class({})
LinkLuaModifier("modifier_boss_aether_mass_effect_debuff", "bosses/boss_aether/boss_aether_mass_effect", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_aether_mass_effect_debuff:OnCreated()
	self.amp = self:GetSpecialValueFor("damage_amp")
end

function modifier_boss_aether_mass_effect_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end


function modifier_boss_aether_mass_effect_debuff:GetModifierIncomingDamage_Percentage(params)
	return self.amp
end

function modifier_boss_aether_mass_effect_debuff:GetEffectName()
	return "particles/units/heroes/hero_enigma/enigma_malefice.vpcf"
end


function modifier_boss_aether_mass_effect_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_enigma_malefice.vpcf"
end

function modifier_boss_aether_mass_effect_debuff:StatusEffectPriority()
	return 2
end