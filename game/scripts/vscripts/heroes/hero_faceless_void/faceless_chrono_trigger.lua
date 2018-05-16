faceless_chrono_trigger = class({})
LinkLuaModifier( "modifier_faceless_chrono_trigger_handle", "heroes/hero_faceless_void/faceless_chrono_trigger.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_faceless_chrono_trigger_buff", "heroes/hero_faceless_void/faceless_chrono_trigger.lua",LUA_MODIFIER_MOTION_NONE )

function faceless_chrono_trigger:GetIntrinsicModifierName()
	return "modifier_faceless_chrono_trigger_handle"
end

function faceless_chrono_trigger:IsStealable()
	return false
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
    self.damage_time = self:GetTalentSpecialValueFor("backtrack_duration")

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

		if caster == self:GetParent() and caster:RollPRNG(self:GetTalentSpecialValueFor("chance")) then
			EmitSoundOn("Hero_FacelessVoid.TimeLockImpact", target)
			ParticleManager:FireParticle("particles/units/heroes/hero_faceless_void/faceless_clock_stopper.vpcf", PATTACH_POINT, caster, {})

			if not target:IsStunned() then
				self:GetAbility():Stun(target, self:GetTalentSpecialValueFor("duration"), false)
			end
			self:GetAbility():DealDamage(caster, target, self:GetTalentSpecialValueFor("damage"), {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)

			local reduction = self:GetTalentSpecialValueFor("cd_reduc")
			for i=0,caster:GetAbilityCount()-1 do 
				if caster:GetAbilityByIndex(i) ~= nil then
					local skill = caster:GetAbilityByIndex(i)
					if skill and not skill:IsCooldownReady() and skill ~= self:GetAbility() then
						local timeleft = skill:GetCooldownTimeRemaining()
						skill:EndCooldown()
						if timeleft > reduction then
							skill:StartCooldown(timeleft-reduction)
						end
					end
				end
			end
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

            if unit:RollPRNG( self:GetTalentSpecialValueFor("backtrack_chance") ) then
            	EmitSoundOn("Hero_FacelessVoid.TimeWalk", caster)
            	ParticleManager:FireParticle("particles/units/heroes/hero_faceless_void/faceless_void_backtrack.vpcf", PATTACH_POINT, caster, {})

            	local reduction = self:GetTalentSpecialValueFor("cd_reduc")
				for i=0,caster:GetAbilityCount()-1 do 
					if caster:GetAbilityByIndex(i) ~= nil then
						local skill = caster:GetAbilityByIndex(i)
						if skill and not skill:IsCooldownReady() and skill ~= self:GetAbility() then
							local timeleft = skill:GetCooldownTimeRemaining()
							skill:EndCooldown()
							if timeleft > reduction then
								skill:StartCooldown(timeleft-reduction)
							end
						end
					end
				end

		        -- Heal recent damage
			    if caster.time_walk_damage_taken then
			        caster:HealEvent(caster.time_walk_damage_taken, self:GetAbility(), caster, false)
			        ProjectileManager:ProjectileDodge(caster)
			    end
			end
        end
    end
end