faceless_chrono_trigger = class({})
LinkLuaModifier( "modifier_faceless_chrono_trigger_handle", "heroes/hero_faceless_void/faceless_chrono_trigger.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_faceless_chrono_trigger_buff", "heroes/hero_faceless_void/faceless_chrono_trigger.lua",LUA_MODIFIER_MOTION_NONE )

function faceless_chrono_trigger:GetIntrinsicModifierName()
	return "modifier_faceless_chrono_trigger_handle"
end

function faceless_chrono_trigger:IsStealable()
	return false
end

function faceless_chrono_trigger:TimeLock(target)
	local caster = self:GetCaster()
	EmitSoundOn("Hero_FacelessVoid.TimeLockImpact", target)
	if caster:HasTalent("special_bonus_unique_faceless_clock_stopper_1") and caster:HasModifier("modifier_faceless_clock_stopper_buff") then
		local nFX = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_time_lock_bash.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(nFX, 0, target:GetAbsOrigin() )
		ParticleManager:SetParticleControl(nFX, 1, target:GetAbsOrigin() )
		ParticleManager:SetParticleControl(nFX, 2, Vector(1,1,1) )
		ParticleManager:SetParticleControl(nFX, 4, target:GetAbsOrigin() )
		ParticleManager:SetParticleControl(nFX, 5, Vector(1,1,1) )
		ParticleManager:ReleaseParticleIndex(nFX)
		Timers:CreateTimer(0.25, function()
			self:Stun(target, self:GetSpecialValueFor("duration"), false)
			self:DealDamage(caster, target, self:GetSpecialValueFor("damage"), {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
			caster:PerformGenericAttack(target, true)
		end)
		local clockstopper = caster:FindModifierByName("modifier_faceless_clock_stopper_buff")
		if clockstopper then
			clockstopper:SetDuration( clockstopper:GetRemainingTime() + caster:FindTalentValue("special_bonus_unique_faceless_clock_stopper_1"), true )
		end
	else
		ParticleManager:FireParticle("particles/units/heroes/hero_faceless_void/faceless_void_time_lock_bash_hit.vpcf", PATTACH_POINT, target, {})
		self:Stun(target, self:GetSpecialValueFor("duration"), false)
		self:DealDamage(caster, target, self:GetSpecialValueFor("damage"), {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
	end
end

modifier_faceless_chrono_trigger_handle = class({}) 
function modifier_faceless_chrono_trigger_handle:IsPurgable()  return false end
function modifier_faceless_chrono_trigger_handle:IsDebuff()    return false end
function modifier_faceless_chrono_trigger_handle:IsHidden()    return true end

function modifier_faceless_chrono_trigger_handle:DeclareFunctions()
    local funcs = { MODIFIER_EVENT_ON_TAKEDAMAGE,
					MODIFIER_EVENT_ON_ATTACK_LANDED}
    return funcs
end

function modifier_faceless_chrono_trigger_handle:OnCreated()
    -- Ability properties
   	local caster = self:GetCaster()
    self.ability = self:GetAbility()

    -- Ability specials
    self.damage_time = self:GetSpecialValueFor("backtrack_duration")

    if IsServer() then
        if not caster.time_walk_damage_taken then
            caster.time_walk_damage_taken = 0
        end
    end
end

function modifier_faceless_chrono_trigger_handle:OnAttackLanded(params)
	if IsServer() then
		local caster = params.attacker
		local target = params.target

		if caster == self:GetParent() and caster:RollPRNG(self:GetSpecialValueFor("chance")) then
			self:GetAbility():TimeLock(target)
		end
	end
end

function modifier_faceless_chrono_trigger_handle:OnTakeDamage( keys )
    if IsServer() then
        local unit = keys.unit
        local damage_taken = keys.damage
        local caster = self:GetCaster()

        -- Only apply if the one taking damage is Faceless Void himself
        if unit == caster then
            -- Stores this instance of damage
            caster.time_walk_damage_taken = caster.time_walk_damage_taken + damage_taken

            -- Decrease damage counter after the duration is up
            Timers:CreateTimer(self.damage_time, function()
                if caster.time_walk_damage_taken then
                    caster.time_walk_damage_taken = caster.time_walk_damage_taken - damage_taken
                end
            end)

            if unit:RollPRNG( self:GetSpecialValueFor("backtrack_chance") ) then
            	EmitSoundOn("Hero_FacelessVoid.TimeWalk", caster)
            	ParticleManager:FireParticle("particles/units/heroes/hero_faceless_void/faceless_void_backtrack.vpcf", PATTACH_POINT, caster, {})

		        -- Heal recent damage
			    if caster.time_walk_damage_taken then
			        caster:HealEvent(caster.time_walk_damage_taken, self:GetAbility(), caster, false)
			        ProjectileManager:ProjectileDodge(caster)
			    end
			end
        end
    end
end