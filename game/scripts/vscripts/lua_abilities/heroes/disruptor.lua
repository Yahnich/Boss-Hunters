function ApplyTeslaEffects(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	if RollPercentage( ability:GetTalentSpecialValueFor("chance") ) then
		EmitSoundOn("Item.Maelstrom.Chain_Lightning", target)
		ApplyDamage({ victim = target, attacker = caster, damage = ability:GetAbilityDamage(), damage_type = ability:GetAbilityDamageType(), ability = ability })
		ability:ApplyDataDrivenModifier(caster, target, keys.modifier, {duration = ability:GetTalentSpecialValueFor("silence_duration")})
		local AOE_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_rhasta/rhasta_spell_forked_lightning.vpcf", PATTACH_POINT_FOLLOW  , caster)
			ParticleManager:SetParticleControlEnt(AOE_effect, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(AOE_effect, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(AOE_effect)
	end
end

function ApplyTeslaEffectsNearest(keys)
	local caster = keys.caster
	local ability = keys.ability
	local usedability = keys.event_ability
	if usedability:GetCooldown(-1) <= 1 or usedability:GetName() == "item_shadow_amulet" or usedability:GetName() == "item_bottle" then return end
	local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, ability:GetCastRange(), ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
	for _,unit in pairs(units) do
		local AOE_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_rhasta/rhasta_spell_forked_lightning.vpcf", PATTACH_POINT_FOLLOW  , caster)
			ParticleManager:SetParticleControlEnt(AOE_effect, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(AOE_effect, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(AOE_effect)
		ApplyDamage({ victim = unit, attacker = caster, damage = ability:GetAbilityDamage(), damage_type = ability:GetAbilityDamageType(), ability = ability })
		ability:ApplyDataDrivenModifier(caster, unit, keys.modifier, {duration = ability:GetTalentSpecialValueFor("silence_duration")})
	end
end

disruptor_kinetic_charge = class({})

if IsServer() then
	function disruptor_kinetic_charge:OnSpellStart()
		local hTarget = self:GetCursorTarget()
		local caster = self:GetCaster()
		ApplyDamage({ victim = hTarget, attacker = caster, damage = self:GetAbilityDamage(), damage_type = self:GetAbilityDamageType(), ability = self })
		hTarget:AddNewModifier(caster, self, "modifier_disruptor_kinetic_charge_pull", {duration = self:GetTalentSpecialValueFor("pull_duration")})
	end
end

LinkLuaModifier( "modifier_disruptor_kinetic_charge_pull", "lua_abilities/heroes/disruptor.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_disruptor_kinetic_charge_pull = class({})

function modifier_disruptor_kinetic_charge_pull:OnCreated()
	self.aura_radius = self:GetAbility():GetSpecialValueFor("pull_radius")
	self.slow = self:GetAbility():GetSpecialValueFor("pull_slow")
	if IsServer() then
		self:StartIntervalThink(1)
	end
end

function modifier_disruptor_kinetic_charge_pull:OnIntervalThink()
	local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.aura_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false )
	EmitSoundOn("Item.Maelstrom.Chain_Lightning", self:GetParent())
	for _, unit in pairs(units) do
		local AOE_effect = ParticleManager:CreateParticle("particles/items_fx/chain_lightning.vpcf", PATTACH_POINT_FOLLOW  , self:GetParent())
			ParticleManager:SetParticleControlEnt(AOE_effect, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(AOE_effect, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)
			ParticleManager:SetParticleControl(AOE_effect, 2, Vector(RandomInt(1,10),RandomInt(1,10),RandomInt(1,10)))
		ParticleManager:ReleaseParticleIndex(AOE_effect)
		ApplyDamage({ victim = self:GetParent(), attacker = self:GetCaster(), damage = self:GetAbility():GetAbilityDamage(), damage_type = self:GetAbility():GetAbilityDamageType(), ability = self:GetAbility() })
	end
end

function modifier_disruptor_kinetic_charge_pull:IsAura()
	return true
end

function modifier_disruptor_kinetic_charge_pull:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			}
	return funcs
end

function modifier_disruptor_kinetic_charge_pull:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

--------------------------------------------------------------------------------

function modifier_disruptor_kinetic_charge_pull:GetModifierAura()
	return "modifier_disruptor_kinetic_charge_pull_aura"
end

function modifier_disruptor_kinetic_charge_pull:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_disruptor_kinetic_charge_pull:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

--------------------------------------------------------------------------------

function modifier_disruptor_kinetic_charge_pull:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

--------------------------------------------------------------------------------

function modifier_disruptor_kinetic_charge_pull:GetAuraRadius()
	return self.aura_radius
end

LinkLuaModifier( "modifier_disruptor_kinetic_charge_pull_aura", "lua_abilities/heroes/disruptor.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_disruptor_kinetic_charge_pull_aura = class({})

function modifier_disruptor_kinetic_charge_pull_aura:OnCreated()
	self.pullTick = self:GetAbility():GetSpecialValueFor("pull_speed") * 0.03
	self.pullRadius = self:GetAbility():GetSpecialValueFor("pull_radius")
	local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.pullRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 1, false )
	for _, unit in pairs(units) do
		if unit:HasModifier("modifier_disruptor_kinetic_charge_pull") then
			self.auraParent = unit
			break
		end
	end
	if IsServer() then
		self:StartIntervalThink(0.03)
	end
end

function modifier_disruptor_kinetic_charge_pull_aura:GetEffectName()
	return "particles/disruptor_kinetic_charge_debuff.vpcf"
end



function modifier_disruptor_kinetic_charge_pull_aura:OnIntervalThink()
	local targetPos = self:GetParent():GetAbsOrigin()
    local casterPos = self.auraParent:GetAbsOrigin()
	if not self.auraParent:IsAlive() then return end
    local direction = targetPos - casterPos
    local vec = direction:Normalized() * self.pullTick
	if direction:Length2D() <= self.pullRadius and direction:Length2D() >= 200 and self.auraParent:IsAlive() then
		self:GetParent():SetAbsOrigin(targetPos - vec)
		ResolveNPCPositions(self:GetParent():GetAbsOrigin(), 100)
	else
		FindClearSpaceForUnit(self:GetParent(), targetPos, false)
	end
end