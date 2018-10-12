boss_broodmother_web_shot = class({})

function boss_broodmother_web_shot:OnAbilityPhaseStart()
	ParticleManager:FireLinearWarningParticle(self:GetCaster():GetAbsOrigin(), self:GetCaster():GetAbsOrigin() + CalculateDirection( self:GetCursorPosition(), self:GetCaster():GetAbsOrigin() ) * self:GetTrueCastRange(), self:GetSpecialValueFor("width"))
	return true
end

function boss_broodmother_web_shot:OnSpellStart()
	local caster = self:GetCaster()
	local position = caster:GetAbsOrigin() + Vector(0,0,128)
	
	local direction = CalculateDirection( self:GetCursorPosition(), position )
	
	local hookFX = ParticleManager:CreateParticle("particles/bosses/boss_broodmother/boss_broodmother_web_shot.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl( hookFX, 0, caster:GetAbsOrigin() )
	ParticleManager:SetParticleControlEnt(hookFX, 3, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
	
	local maxDistance = self:GetTrueCastRange()
	local speed = self:GetSpecialValueFor("speed") * FrameTime()
	local radius = self:GetSpecialValueFor("width")
	local distance = 0
	local grabTarget
	
	caster:AddNewModifier(caster, self, "modifier_boss_broodmother_web_shot_pulling", {duration = (maxDistance * 2) / (speed / FrameTime()) + 0.5 })
	Timers:CreateTimer(FrameTime(), function()
		if not grabTarget then
			distance = distance + speed
			position = position + direction * speed
			ParticleManager:SetParticleControl( hookFX, 0, position )
			for _, enemy in ipairs( caster:FindEnemyUnitsInRadius(position, radius) ) do
				if enemy:TriggerSpellAbsorb(self) then return end
				grabTarget = enemy
				grabTarget:SetAbsOrigin( position )
				grabTarget:AddNewModifier(caster, self, "modifier_boss_broodmother_web_shot_pull", {duration = CalculateDistance(grabTarget, caster) / (speed / FrameTime()) + 0.5 })
				break
			end
			if distance < maxDistance then
				return FrameTime()
			else
				grabTarget = {}
				return FrameTime()
			end
		else
			distance = distance - speed
			position = position - direction * speed
			if grabTarget.SetAbsOrigin then grabTarget:SetAbsOrigin( position ) end
			ParticleManager:SetParticleControl( hookFX, 0, position )
			if distance > 0 then
				return FrameTime()
			else
				if grabTarget.RemoveModifierByName then 
					grabTarget:RemoveModifierByName( "modifier_boss_broodmother_web_shot_pull" ) 
					caster:Taunt(self, grabTarget, self:GetSpecialValueFor("taunt_duration"))
				end
				ParticleManager:ClearParticle( hookFX )
				caster:RemoveModifierByName("modifier_boss_broodmother_web_shot_pulling")
				ResolveNPCPositions(position, 5000)
			end
		end
	end)
end

modifier_boss_broodmother_web_shot_pull = class({})
LinkLuaModifier("modifier_boss_broodmother_web_shot_pull", "bosses/boss_broodmother/boss_broodmother_web_shot", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_broodmother_web_shot_pull:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,}
end

function modifier_boss_broodmother_web_shot_pull:IsHidden()
	return false
end

modifier_boss_broodmother_web_shot_pulling = class({})
LinkLuaModifier("modifier_boss_broodmother_web_shot_pulling", "bosses/boss_broodmother/boss_broodmother_web_shot", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_broodmother_web_shot_pulling:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true}
end

function modifier_boss_broodmother_web_shot_pulling:IsHidden()
	return false
end