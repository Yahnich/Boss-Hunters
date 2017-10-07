boss19_chasm = class({})

function boss19_chasm:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	local startPos = caster:GetAbsOrigin()
	local endPos = startPos + CalculateDirection(position, caster) * self:GetSpecialValueFor("proj_distance")
	ParticleManager:FireLinearWarningParticle(startPos, endPos)
	return true
end

function boss19_chasm:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local velocity = CalculateDirection(position, caster) * self:GetSpecialValueFor("proj_speed")
	local distance = self:GetSpecialValueFor("proj_distance")
	local width = self:GetSpecialValueFor("proj_width")
	self:FireLinearProjectile("particles/econ/items/nyx_assassin/nyx_assassin_ti6/nyx_assassin_impale_ti6.vpcf", velocity, distance, width)
	EmitSoundOn("Hero_NyxAssassin.Impale", caster)
end

if IsServer() then
	function boss19_chasm:OnProjectileHit(target, position)
		if not target then return end
		local caster =  self:GetCaster()
		local ability = self
		local knockUpDuration = self:GetSpecialValueFor("knockup_duration")
		StartAnimation(target, {activity = ACT_DOTA_FLAIL, rate = 1, duration = knockUpDuration})
		target:AddNewModifier(caster, self, "modifier_stunned_generic", {duration = knockUpDuration, delay = false})
		local Z_VECTOR = Vector(0,0,1)
		ParticleManager:FireParticle("particles/econ/items/nyx_assassin/nyx_assassin_ti6/nyx_assassin_impale_hit_ti6.vpcf", PATTACH_POINT_FOLLOW, target)
		local distance_traveled = 0
		local distance = self:GetSpecialValueFor("knockup_height")
		local speed = (distance * 2/ knockUpDuration) * FrameTime()
			
		local cd = self:GetCooldownTimeRemaining()
		self:EndCooldown()
		self:StartCooldown( math.min(cd, math.max( 5, cd - 3) ) )
		EmitSoundOn("Hero_NyxAssassin.Impale.Target", target)
		Timers:CreateTimer(function ()
			if not target:HasMovementCapability() or not target:IsAlive() or target:IsNull() then return end
			if distance_traveled < distance / 2 then
				target:SetAbsOrigin(target:GetAbsOrigin() + Z_VECTOR * speed)
				distance_traveled = distance_traveled + speed
				return FrameTime()
			elseif distance_traveled > distance / 2 and distance_traveled < distance then
				target:SetAbsOrigin(target:GetAbsOrigin() - Z_VECTOR * speed)
				distance_traveled = distance_traveled + speed
				return FrameTime()
			else
				self:DealDamage(caster, target, ability:GetSpecialValueFor("knockup_damage"))
				target:SetAbsOrigin(target:GetAbsOrigin() - Z_VECTOR * speed)
				FindClearSpaceForUnit(target, target:GetAbsOrigin(), true)
				EmitSoundOn("Hero_NyxAssassin.Impale.TargetLand", target)
				self.isInKnockbackState = false
				return nil
			end 
		end)
	end
end