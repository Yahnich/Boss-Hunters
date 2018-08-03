boss_troll_warlord_mystic_axes_charge = class({})
LinkLuaModifier( "modifier_boss_troll_warlord_mystic_axes_charge", "bosses/boss_troll_warlord/boss_troll_warlord_mystic_axes_charge.lua" ,LUA_MODIFIER_MOTION_NONE )

function boss_troll_warlord_mystic_axes_charge:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local start = caster:GetAbsOrigin()
	local distance = self:GetTalentSpecialValueFor("range")
	self.direction = CalculateDirection(target, caster)
	self.hitTargets = {}
	EmitSoundOn("Ability.AssassinateLoad", self:GetCaster())
	ParticleManager:FireLinearWarningParticle(start, start + self.direction * distance, self:GetTalentSpecialValueFor("radius"))
	-- Timers:CreateTimer( self:GetCastPoint(), function() self:OnSpellStart() end )
	return true
end

function boss_troll_warlord_mystic_axes_charge:OnSpellStart()
    local caster = self:GetCaster()
	local start = caster:GetAbsOrigin()
	self.distance = self:GetSpecialValueFor("range")
	local endPoint = start + caster:GetForwardVector() * self.distance
	local speed = self:GetSpecialValueFor("speed")*FrameTime()
	local damage = self:GetSpecialValueFor("damage")
	Timers:CreateTimer(function()
		if self:IsNull() then return end
		if self.distance > 0 then
			self.distance = self.distance - speed
			GridNav:DestroyTreesAroundPoint(caster:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"), true)
			caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + self.direction*speed)
			local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetSpecialValueFor("axe_radius"))
			for _,enemy in pairs(enemies) do
				if not self.hitTargets[enemy:entindex()] then
					self:DealDamage(caster, enemy, damage, {}, 0)
					self.hitTargets[enemy:entindex()] = true
				end
			end
			return 0
		else
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), false)
		end
	end)
end