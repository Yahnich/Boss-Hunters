gladiatrix_valiant_rush = class({})

function gladiatrix_valiant_rush:OnAbilityPhaseStart()
	EmitSoundOn("Hero_LegionCommander.Overwhelming.Cast", self:GetCaster())
	return true
end

function gladiatrix_valiant_rush:OnAbilityPhaseInterrupted()
	StopSoundOn("Hero_LegionCommander.Overwhelming.Cast", self:GetCaster())
end

function gladiatrix_valiant_rush:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	caster:MoveToNPC(target)
	EmitSoundOn("Hero_LegionCommander.Duel.Cast", self:GetCaster())
	caster:AddNewModifier(caster, self, "modifier_valiant_rush_movement", {target = target:entindex()})
end

LinkLuaModifier( "modifier_valiant_rush_movement", "heroes/gladiatrix/gladiatrix_valiant_rush.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_valiant_rush_movement = class({})

function modifier_valiant_rush_movement:OnCreated(kv)
	self.speed = self:GetAbility():GetSpecialValueFor("rush_speed")
	self.radius = self:GetAbility():GetSpecialValueFor("taunt_radius")
	self.duration = self:GetAbility():GetSpecialValueFor("taunt_duration")
	if IsServer() then
		EmitSoundOn("Hero_LegionCommander.Duel.FP", self:GetCaster())
		self.target = EntIndexToHScript(kv.target)
		self:StartIntervalThink(0.1)
	end
end

function modifier_valiant_rush_movement:OnIntervalThink(kv)
	if CalculateDistance(self.target, self:GetParent()) <= 180 then self:Destroy() end
end

function modifier_valiant_rush_movement:OnDestroy()
	if IsServer() then
		local affectedEnemies = self:GetParent():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self.radius, {})
		local taunt = ParticleManager:CreateParticle("particles/heroes/gladiatrix/gladiatrix_valiant_rush_taunta.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:ReleaseParticleIndex(taunt)
		
		StopSoundOn("Hero_LegionCommander.Duel.FP", self:GetCaster())
		EmitSoundOn("Hero_MonkeyKing.FurArmy.End", self:GetCaster())
		EmitSoundOn("Hero_Sven.SignetLayer", self:GetCaster())
		
		for _, enemy in ipairs(affectedEnemies) do
			enemy:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_valiant_rush_taunt", {duration = self.duration})
			if self:GetCaster():HasTalent("gladiatrix_valiant_rush_talent_1") then
				enemy:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_valiant_rush_taunt_slow_talent", {duration = self.duration})
			end
		end
		if #affectedEnemies	 > 0 then self:GetAbility():StartDelayedCooldown(self.duration, true) end
	end
end

function modifier_valiant_rush_movement:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_ORDER,
				MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
				MODIFIER_PROPERTY_MOVESPEED_LIMIT,
				MODIFIER_PROPERTY_MOVESPEED_MAX,
			}
	return funcs
end

function modifier_valiant_rush_movement:CheckState()
	local state = {[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
	return state
end

function modifier_valiant_rush_movement:OnOrder(params)
	if params.unit == self:GetParent() then self:Destroy() end
end

function modifier_valiant_rush_movement:GetModifierMoveSpeed_Absolute()
	return self.speed
end

function modifier_valiant_rush_movement:GetModifierMoveSpeed_Max()
	return self.speed
end

function modifier_valiant_rush_movement:GetModifierMoveSpeed_Limit()
	return self.speed
end

function modifier_valiant_rush_movement:GetEffectName()
	return "particles/heroes/gladiatrix/gladiatrix_valiant_rush_movement.vpcf"
end

LinkLuaModifier( "modifier_valiant_rush_taunt", "heroes/gladiatrix/gladiatrix_valiant_rush.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_valiant_rush_taunt = class({})

if IsServer() then
	function modifier_valiant_rush_taunt:OnCreated(kv)
		self:GetParent():MoveToTargetToAttack(self:GetCaster())
		self:GetParent():SetForceAttackTarget(self:GetCaster())
	end

	function modifier_valiant_rush_taunt:OnDestroy()
		self:GetParent():SetForceAttackTarget(nil)
	end
end

function modifier_valiant_rush_taunt:GetStatusEffectName()
	return "particles/heroes/gladiatrix/status_effect_gladiatrix_imperious_shout.vpcf"
end

function modifier_valiant_rush_taunt:StatusEffectPriority()
	return 10
end

LinkLuaModifier( "modifier_valiant_rush_taunt_slow_talent", "heroes/gladiatrix/gladiatrix_valiant_rush.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_valiant_rush_taunt_slow_talent = class({})

function modifier_valiant_rush_taunt_slow_talent:OnCreated(kv)
	self.slow = self:GetSpecialValueFor("talent_slow")
end

function modifier_valiant_rush_taunt_slow_talent:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			}
	return funcs
end

function modifier_valiant_rush_taunt_slow_talent:GetModifierAttackSpeedBonus_Constant()
	return self.slow
end

function modifier_valiant_rush_taunt_slow_talent:IsHidden()
	return true
end
