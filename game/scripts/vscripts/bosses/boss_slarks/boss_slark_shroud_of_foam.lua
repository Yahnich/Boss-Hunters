boss_slark_shroud_of_foam = class({})

function boss_slark_shroud_of_foam:GetIntrinsicModifierName()
	return "modifier_boss_slark_shroud_of_foam_handler"
end

modifier_boss_slark_shroud_of_foam_handler = class({})
LinkLuaModifier("modifier_boss_slark_shroud_of_foam_handler", "bosses/boss_slarks/boss_slark_shroud_of_foam", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_slark_shroud_of_foam_handler:OnCreated()
	self:OnRefresh()
	self.timer = 0
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_boss_slark_shroud_of_foam_handler:OnRefresh()
	self.delay = self:GetTalentSpecialValueFor("delay")
end


function modifier_boss_slark_shroud_of_foam_handler:OnIntervalThink()
	local caster = self:GetCaster()
	if not caster:HasModifier("modifier_boss_slark_shroud_of_foam_effect") then
		for _, unit in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), -1 ) ) do
			if unit:CanEntityBeSeenByMyTeam(caster) then
				self.timer = 0
			else
				self.timer = self.timer + 0.1
			end
		end
		if self.timer >= self.delay then
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_boss_slark_shroud_of_foam_effect", {})
		end
	end
end

function modifier_boss_slark_shroud_of_foam_handler:IsHidden()
	return true
end

modifier_boss_slark_shroud_of_foam_effect = class({})
LinkLuaModifier("modifier_boss_slark_shroud_of_foam_effect", "bosses/boss_slarks/boss_slark_shroud_of_foam", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_slark_shroud_of_foam_effect:OnCreated()
	local parent = self:GetParent()
	self.ms = self:GetSpecialValueFor("bonus_movement_speed")
	self.regen = self:GetSpecialValueFor("bonus_regen_pct")
	self.crit = self:GetSpecialValueFor("break_critical")
	if IsServer() then
		local sFX = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_shadow_dance.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
		ParticleManager:SetParticleControlEnt(sFX, 1, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(sFX, 3, parent, PATTACH_POINT_FOLLOW, "attach_eyeR", parent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(sFX, 4, parent, PATTACH_POINT_FOLLOW, "attach_eyeL", parent:GetAbsOrigin(), true)
		self:AddEffect(sFX)
	end
end

function modifier_boss_slark_shroud_of_foam_effect:GetStatusEffectName()
	return "particles/status_fx/status_effect_boss_slark_shroud_of_foam.vpcf"
end

function modifier_boss_slark_shroud_of_foam_effect:GetStatusEffectName()
	return "particles/status_fx/status_effect_boss_slark_shroud_of_foam.vpcf"
end

function modifier_boss_slark_shroud_of_foam_effect:StatusEffectPriority()
	return 50
end

function modifier_boss_slark_shroud_of_foam_effect:CheckState()
	return {[MODIFIER_STATE_UNTARGETABLE] = true,
			[MODIFIER_STATE_ATTACK_IMMUNE] = true,
			}
end

function modifier_boss_slark_shroud_of_foam_effect:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
			MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
			MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_EVENT_ON_ATTACK_FAIL}
end

function modifier_boss_slark_shroud_of_foam_effect:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		self:Destroy()
	end
end

function modifier_boss_slark_shroud_of_foam_effect:OnAttackFail(params)
	if params.attacker == self:GetParent() then
		self:Destroy()
	end
end

function modifier_boss_slark_shroud_of_foam_effect:GetModifierHealthRegenPercentage()
	return self.regen
end

function modifier_boss_slark_shroud_of_foam_effect:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_boss_slark_shroud_of_foam_effect:GetModifierPreAttack_CriticalStrike()
	return self.crit
end

function modifier_boss_slark_shroud_of_foam_effect:GetModifierInvisibilityLevel()
	return 1
end