boss_apotheosis_focused_beam = class({})

function boss_apotheosis_focused_beam:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local casterPos = caster:GetAbsOrigin()
	ParticleManager:FireLinearWarningParticle( casterPos, casterPos + caster:GetForwardVector() * self:GetTrueCastRange(), self:GetSpecialValueFor("width") * 2 )
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
	caster:AddNewModifier(caster, self, "modifier_boss_apotheosis_focused_beam_root", {duration = duration})
	Timers:CreateTimer(0, function()
		if duration > 0 and caster:IsAlive() and caster:HasModifier("modifier_boss_apotheosis_focused_beam_root") then
			duration = duration - FrameTime()
			thinker = thinker + FrameTime()
			endPos = caster:GetAbsOrigin() + caster:GetForwardVector() * pathLength
			endPos = GetGroundPosition(endPos, nil)
			endPos.z = GetGroundHeight(caster:GetAbsOrigin(), caster) + 92
			ParticleManager:SetParticleControl( pfx, 1, endPos )
			if thinker >= interval then
				for _,enemy in pairs(caster:FindEnemyUnitsInLine(caster:GetAbsOrigin(), endPos, width, {})) do
					self:DealDamage( caster, enemy, damage * interval )
				end
				thinker = 0
			end
			GridNav:DestroyTreesAroundPoint(endPos, self:GetTalentSpecialValueFor("radius"), false)
			return 0
		else
			endPos = 0
			caster:RemoveModifierByName("modifier_boss_apotheosis_focused_beam_root")
			ParticleManager:DestroyParticle(pfx, false)
			return nil
		end
	end)
end

modifier_boss_apotheosis_focused_beam_root = class({})
LinkLuaModifier("modifier_boss_apotheosis_focused_beam_root", "bosses/boss_apotheosis/boss_apotheosis_focused_beam", LUA_MODIFIER_MOTION_NONE )
function modifier_boss_apotheosis_focused_beam_root:OnCreated()
	self.turnslow = self:GetSpecialValueFor("turn_slow")
	self.width = self:GetSpecialValueFor("width")
	if IsServer() then
		self.check = 0
		self.timer = self:GetSpecialValueFor("no_target_timer")
		self:StartIntervalThink(0.2) 
	end
end

function modifier_boss_apotheosis_focused_beam_root:OnIntervalThink()
	local caster = self:GetCaster()
	local endPos = caster:GetAbsOrigin() + caster:GetForwardVector() * self:GetAbility():GetTrueCastRange()
	endPos = GetGroundPosition(endPos, nil)
	endPos.z = GetGroundHeight(caster:GetAbsOrigin(), caster) + 92
	for _,enemy in pairs(caster:FindEnemyUnitsInLine(caster:GetAbsOrigin(), endPos, self.width * 2, {})) do
		return
	end
	self.check = self.check + 0.2
	if self.check >= self.timer then
		self:Destroy()
	end
end

function modifier_boss_apotheosis_focused_beam_root:CheckState()
	return {[MODIFIER_STATE_SILENCED] = true,
			[MODIFIER_STATE_ROOTED] = true}
end

function modifier_boss_apotheosis_focused_beam_root:DeclareFunctions()
	return {MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE}
end

function modifier_boss_apotheosis_focused_beam_root:GetModifierTurnRate_Percentage()
	return -100
end