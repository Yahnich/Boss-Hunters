mystic_life_swap = class({})

function mystic_life_swap:CastFilterResultTarget(target)
	local caster = self:GetCaster()
	if caster ~= target then
		return UnitFilter(target, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, caster:GetTeamNumber())
	else
		return UF_FAIL_CUSTOM
	end
end

function mystic_life_swap:GetCustomCastErrorTarget(target)
	return "Skill cannot target caster"
end

function mystic_life_swap:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	EmitSoundOn("hero_bloodseeker.rupture.cast", caster)
	local FX = ParticleManager:CreateParticle("particles/heroes/mystic/mystic_life_swap.vpcf", PATTACH_POINT_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(FX, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(FX, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl( FX, 15, Vector(255,0,0) )
	
	local hpSacrifice = caster:GetHealth() * self:GetSpecialValueFor("hp_swap") / 100
	target:AddNewModifier(caster, self, "modifier_mystic_life_swap_buff", {duration = self:GetSpecialValueFor("duration")}):SetStackCount(hpSacrifice)
	if caster:HasTalent("mystic_life_swap_talent_1") then
		caster:AddNewModifier(caster, self, "modifier_mystic_life_swap_talent", {duration = self:GetSpecialValueFor("talent_duration")})
	end
	Timers:CreateTimer(function() target:HealEvent(hpSacrifice, self, caster) end)
end

modifier_mystic_life_swap_buff = class({})
LinkLuaModifier("modifier_mystic_life_swap_buff", "heroes/mystic/mystic_life_swap.lua", 0)

function modifier_mystic_life_swap_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS}
end

function modifier_mystic_life_swap_buff:GetModifierExtraHealthBonus()
	return self:GetStackCount()
end

modifier_mystic_life_swap_talent = class({})
LinkLuaModifier("modifier_mystic_life_swap_talent", "heroes/mystic/mystic_life_swap.lua", 0)

if IsServer() then
	function modifier_mystic_life_swap_talent:OnCreated() self:GetAbility():StartDelayedCooldown() end
	function modifier_mystic_life_swap_talent:OnDestroy() self:GetAbility():EndDelayedCooldown() end
end


function modifier_mystic_life_swap_talent:CheckState()
	return {[MODIFIER_STATE_ATTACK_IMMUNE] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function modifier_mystic_life_swap_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN}
end

function modifier_mystic_life_swap_talent:GetModifierMoveSpeed_AbsoluteMin()
	return 550
end

function modifier_mystic_life_swap_talent:GetEffectName()
	return "particles/items_fx/ghost.vpcf"
end

function modifier_mystic_life_swap_talent:GetStatusEffectName()
	return "particles/status_fx/status_effect_ghost.vpcf"
end

function modifier_mystic_life_swap_talent:StatusEffectPriority()
	return 5
end
