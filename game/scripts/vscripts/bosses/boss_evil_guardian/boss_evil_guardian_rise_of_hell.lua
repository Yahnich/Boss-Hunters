boss_evil_guardian_rise_of_hell = class({})

function boss_evil_guardian_rise_of_hell:OnAbilityPhaseStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_status_immunity", {duration = self:GetCastPoint() - 0.01})
	ParticleManager:FireWarningParticle(GetGroundPosition(self:GetCursorPosition(), self:GetCaster()), self:GetSpecialValueFor("radius"))
	return true
end

function boss_evil_guardian_rise_of_hell:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local enemies = caster:FindEnemyUnitsInRadius( position, self:GetSpecialValueFor("radius") )
	caster:AddNewModifier(caster, self, "modifier_boss_evil_guardian_rise_of_hell_punch", {duration = (#enemies + 1) * 0.1})
	caster:StartGesture(ACT_DOTA_ATTACK)
	local threatTarget
	Timers:CreateTimer(0.1, function()
		for id, enemy in ipairs(enemies) do
			if enemy and not enemy:IsNull() then
				FindClearSpaceForUnit( caster, enemy:GetAbsOrigin() + RandomVector(175), true )
				caster:PerformGenericAttack(enemy, true)
				caster:StartGesture(ACT_DOTA_ATTACK)
				if not threatTarget then threatTarget = enemy end
				if enemy:GetThreat() > threatTarget:GetThreat() then threatTarget = enemy end
			end
			table.remove(enemies, id)
			return 0.1
		end
		caster:RemoveModifierByName("modifier_boss_evil_guardian_rise_of_hell_punch")
		threatTarget = threatTarget or caster
		FindClearSpaceForUnit( caster, threatTarget:GetAbsOrigin() + RandomVector(175), true )
	end)
end

modifier_boss_evil_guardian_rise_of_hell_punch = class({})
LinkLuaModifier("modifier_boss_evil_guardian_rise_of_hell_punch", "bosses/boss_evil_guardian/boss_evil_guardian_rise_of_hell", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_evil_guardian_rise_of_hell_punch:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_MAGIC_IMMUNE] = true,
			[MODIFIER_STATE_CANNOT_MISS] = true,
			[MODIFIER_STATE_ATTACK_IMMUNE] = true,}
end
function modifier_boss_evil_guardian_rise_of_hell_punch:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE}
end

function modifier_boss_evil_guardian_rise_of_hell_punch:GetModifierPreAttack_CriticalStrike()
	return self:GetSpecialValueFor("crit")
end