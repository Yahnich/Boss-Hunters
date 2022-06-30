lion_frogger = class({})

function lion_frogger:IsStealable()
	return true
end

function lion_frogger:IsHiddenWhenStolen()
	return false
end

function lion_frogger:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

function lion_frogger:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local target = self:GetCursorTarget()
	if self:GetCursorTarget() then
		point = self:GetCursorTarget():GetAbsOrigin()
	end
	
	local maxTargets = self:GetTalentSpecialValueFor("max_targets")
	local duration = self:GetTalentSpecialValueFor("duration")
	local radius = self:GetTalentSpecialValueFor("radius")
	
	local notMinions = {}
	

	for _,enemy in pairs( caster:FindEnemyUnitsInRadius( point, radius ) ) do
		if enemy:IsMinion() then
			if not enemy:TriggerSpellAbsorb( self ) then self:Hex( enemy, duration ) end
		else
			table.insert( notMinions, enemy )
		end
	end
	
	table.sort(notMinions, function(a, b) return CalculateDistance( a, caster ) < CalculateDistance( b, caster ) end)
	
	if target and not target:IsMinion() then
		table.insert( notMinions, 1, target )
	end
	
	local toHex = TernaryOperator( #notMinions, caster:HasTalent("special_bonus_unique_lion_frogger_2") or maxTargets > #notMinions, maxTargets )
	for i = 1, toHex do
		if not enemy:TriggerSpellAbsorb( self ) then self:Hex( notMinions[i], duration ) end
	end
	EmitSoundOnLocationWithCaster(point, "Hero_Lion.Voodoo", caster)
end

function lion_frogger:Hex( target, duration )
	local caster = self:GetCaster()
	ParticleManager:FireParticle("particles/units/heroes/hero_lion/lion_spell_voodoo.vpcf", PATTACH_POINT, target)
	target:AddNewModifier(caster, self, "modifier_lion_frogger", {Duration = duration or self:GetTalentSpecialValueFor("duration")})
end

modifier_lion_frogger = class({})
LinkLuaModifier( "modifier_lion_frogger", "heroes/hero_lion/lion_frogger.lua",LUA_MODIFIER_MOTION_NONE )
function modifier_lion_frogger:OnCreated(table)
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_lion_frogger_2")
	self.amp = self:GetCaster():FindTalentValue("special_bonus_unique_lion_frogger_1")
	self:GetParent():HookInModifier( "GetMoveSpeedLimitBonus", self )
	
	if IsServer() and self.talent2 then
		self:StartIntervalThink(0.25)
	end
end

function modifier_lion_frogger:OnDestroy()
	self:GetParent():HookOutModifier( "GetMoveSpeedLimitBonus", self )
end

function modifier_lion_frogger:OnIntervalThink()
	local caster = self:GetCaster()
	local ability = self:GetAbility()

	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( self:GetParent():GetAbsOrigin(), self:GetTalentSpecialValueFor("radius") ) ) do
		if not enemy:HasModifier("modifier_lion_frogger") then
			ParticleManager:FireParticle("particles/units/heroes/hero_lion/lion_spell_voodoo.vpcf", PATTACH_POINT, enemy)
			enemy:AddNewModifier(caster, ability, "modifier_lion_frogger", {duration = self:GetRemainingTime(), ignoreStatusAmp = true})
		end
	end
end

function modifier_lion_frogger:CheckState()
	local state = { [MODIFIER_STATE_SILENCED] = true,
					[MODIFIER_STATE_MUTED] = true,
					[MODIFIER_STATE_DISARMED] = true,
					[MODIFIER_STATE_EVADE_DISABLED] = true,
					[MODIFIER_STATE_PASSIVES_DISABLED] = true
					}
	return state
end

function modifier_lion_frogger:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_DISABLE_HEALING
	}
	return funcs
end

function modifier_lion_frogger:GetModifierMoveSpeedOverride()
	return 140
end

function modifier_lion_frogger:GetDisableHealing()
	return 1
end

function modifier_lion_frogger:GetModifierModelChange()
	return "models/props_gameplay/frog.vmdl"
end
function modifier_lion_frogger:GetMoveSpeedLimitBonus()
	return -410
end

function modifier_lion_frogger:GetModifierIncomingDamage_Percentage()
   return self.amp
end