faceless_time_lock = class({})
LinkLuaModifier( "modifier_faceless_time_lock_handle", "heroes/hero_faceless_void/faceless_time_lock.lua",LUA_MODIFIER_MOTION_NONE )

function faceless_time_lock:GetIntrinsicModifierName()
	return "modifier_faceless_time_lock_handle"
end

function faceless_time_lock:IsStealable()
	return false
end

function faceless_time_lock:TimeLock(target)
	local caster = self:GetCaster()
	EmitSoundOn("Hero_FacelessVoid.TimeLockImpact", target)
	
	local nFX = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_time_lock_bash.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(nFX, 0, target:GetAbsOrigin() )
	ParticleManager:SetParticleControl(nFX, 1, target:GetAbsOrigin() )
	ParticleManager:SetParticleControlEnt(nFX, 2, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(nFX, 4, target:GetAbsOrigin() )
	ParticleManager:SetParticleControl(nFX, 5, Vector(1,1,1) )
	ParticleManager:ReleaseParticleIndex(nFX)
	
	local duration = TernaryOperator( self:GetSpecialValueFor("minion_duration"), target:IsMinion(), self:GetSpecialValueFor("duration") )
	local damage = self:GetSpecialValueFor("damage")
	
	if caster:HasTalent("special_bonus_unique_faceless_time_dilation_1") then
		local mult = caster:FindTalentValue("special_bonus_unique_faceless_time_dilation_1")
		duration = duration * mult
		damage = damage * mult
	end
	
	local delay = self:GetSpecialValueFor("damage_delay")
	Timers:CreateTimer(delay, function()
		self:Stun(target, duration, false)
		self:DealDamage(caster, target, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
		caster:PerformGenericAttack(target, true)
	end)
end

modifier_faceless_time_lock_handle = class({}) 
function modifier_faceless_time_lock_handle:IsPurgable()  return false end
function modifier_faceless_time_lock_handle:IsDebuff()    return false end
function modifier_faceless_time_lock_handle:IsHidden()    return true end

function modifier_faceless_time_lock_handle:OnCreated()
	self:OnRefresh()
end

function modifier_faceless_time_lock_handle:OnRefresh()
	self.chance = self:GetSpecialValueFor("chance")
end

function modifier_faceless_time_lock_handle:DeclareFunctions()
    local funcs = { MODIFIER_EVENT_ON_ATTACK_LANDED}
    return funcs
end

function modifier_faceless_time_lock_handle:OnAttackLanded(params)
	if IsServer() then
		local caster = params.attacker
		local target = params.target

		if caster == self:GetParent() and caster:RollPRNG(self.chance) then
			self:GetAbility():TimeLock(target)
		end
	end
end