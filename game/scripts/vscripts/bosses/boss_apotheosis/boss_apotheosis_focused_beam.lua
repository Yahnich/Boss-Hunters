boss_apotheosis_focused_beam = class({})

function boss_apotheosis_focused_beam:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local casterPos = caster:GetAbsOrigin()
	ParticleManager:FireLinearWarningParticle( casterPos, casterPos + caster:GetForwardVector() * self:GetTrueCastRange() )
	return true
end

function boss_apotheosis_focused_beam:OnSpellStart()
    local caster = self:GetCaster()
	
	local pathLength = self:GetTrueCastRange()
	local endPos = caster:GetAbsOrigin() + caster:GetForwardVector() * pathLength
	
	local duration = self:GetSpecialValueFor("duration")
	local width = self:GetSpecialValueFor("width")
	local damage = self:GetSpecialValueFor("damage")
	local thinker = 0
	local interval = self:GetSpecialValueFor("tick_interval")
	
	EmitSoundOn("Hero_Phoenix.SunRay.Cast", caster)
	pfx = ParticleManager:CreateParticle( "particles/units/heroes/hero_phoenix/phoenix_sunray.vpcf", PATTACH_ABSORIGIN, caster )
	ParticleManager:SetParticleControlEnt( pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true )
	ParticleManager:SetParticleControl( pfx, 1, endPos )
	Timers:CreateTimer(0, function()
		if duration > 0 and caster:IsAlive() then
			duration = duration - FrameTime()
			thinker = thinker + FrameTime()
			endPos = caster:GetAbsOrigin() + caster:GetForwardVector() * pathLength
			endPos = GetGroundPosition(endPos, nil)
			endPos.z = GetGroundHeight(caster:GetAbsOrigin(), caster) + 92
			ParticleManager:SetParticleControl( pfx, 1, endPos )
			if thinker >= interval then
				for _,enemy in pairs(caster:FindEnemyUnitsInLine(caster:GetAbsOrigin(), endPos, width, {})) do
					self:DealDamage( caster, enemy, damage )
				end
				thinker = 0
			end
			GridNav:DestroyTreesAroundPoint(endPos, self:GetTalentSpecialValueFor("radius"), false)
			return 0
		else
			endPos = 0
			ParticleManager:DestroyParticle(pfx, false)
			return nil
		end
	end)
end