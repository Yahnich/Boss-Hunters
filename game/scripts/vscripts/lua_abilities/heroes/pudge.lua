pudge_dismember_lua = class({})
LinkLuaModifier( "modifier_pudge_dismember_lua", "lua_abilities/heroes/pudge.lua" ,LUA_MODIFIER_MOTION_NONE )

--[[Author: Valve
	Date: 26.09.2015.]]
--------------------------------------------------------------------------------

function pudge_dismember_lua:GetConceptRecipientType()
	return DOTA_SPEECH_USER_ALL
end

--------------------------------------------------------------------------------

function pudge_dismember_lua:SpeakTrigger()
	return DOTA_ABILITY_SPEAK_CAST
end

--------------------------------------------------------------------------------

function pudge_dismember_lua:GetChannelTime()
	self.duration = self:GetTalentSpecialValueFor( "duration" )

	if IsServer() then
		if self.hVictim ~= nil then
			return self.duration
		end

		return 0.0
	end

	return self.duration
end

--------------------------------------------------------------------------------

function pudge_dismember_lua:OnAbilityPhaseStart()
	if IsServer() then
		self.hVictim = self:GetCursorTarget()
	end

	return true
end

--------------------------------------------------------------------------------

function pudge_dismember_lua:OnSpellStart()
	if self.hVictim == nil then
		return
	end

	if self.hVictim:TriggerSpellAbsorb( self ) then
		self.hVictim = nil
		self:GetCaster():Interrupt()
	else
		self.hVictim:AddNewModifier( self:GetCaster(), self,  "modifier_pudge_dismember_lua", { duration = self.duration} )
		self.hVictim:Interrupt()
	end
end


--------------------------------------------------------------------------------

function pudge_dismember_lua:OnChannelFinish( bInterrupted )
	if self.hVictim ~= nil then
		self.hVictim:RemoveModifierByName("modifier_pudge_dismember_lua" )
	end
end

--------------------------------------------------------------------------------

modifier_pudge_dismember_lua = class({})

--------------------------------------------------------------------------------

function modifier_pudge_dismember_lua:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_pudge_dismember_lua:IsStunDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_pudge_dismember_lua:OnCreated( kv )
	self.dismember_damage = self:GetAbility():GetTalentSpecialValueFor( "dismember_damage" )
	self.tick_rate = self:GetAbility():GetTalentSpecialValueFor( "tick_rate" )
	self.strength_damage = self:GetAbility():GetTalentSpecialValueFor( "strength_damage" )
	self.stacks = self:GetAbility():GetTalentSpecialValueFor( "scepter_flesh_stacks" )

	if IsServer() then
		self:GetParent():InterruptChannel()
		self:OnIntervalThink()
		self:StartIntervalThink( self.tick_rate )
	end
end

--------------------------------------------------------------------------------

function modifier_pudge_dismember_lua:OnDestroy()
	if IsServer() then
		self:GetCaster():InterruptChannel()
	end
end

--------------------------------------------------------------------------------

function modifier_pudge_dismember_lua:OnIntervalThink()
	if IsServer() then
		if self:GetCaster():HasScepter() then
			local fleshheap = self:GetCaster():FindAbilityByName("pudge_flesh_heap_datadriven")
			if self:GetAbility():IsStolen() then
				local pudge = self:GetCaster().target
				fleshheap = pudge:FindAbilityByName("pudge_flesh_heap_datadriven")
				if fleshheap then
					local stacks = self:GetCaster():GetModifierStackCount( "modifier_hp_shift_datadriven_buff_counter" , fleshheap )
					local duration = fleshheap:GetSpecialValueFor("duration")
					for i=0, self.stacks do
						fleshheap:ApplyDataDrivenModifier(pudge, self:GetCaster(), "modifier_hp_shift_datadriven_buff", {duration = duration})
					end
					self:GetCaster():RemoveModifierByName("modifier_hp_shift_datadriven_buff_counter")
					fleshheap:ApplyDataDrivenModifier(pudge, self:GetCaster(), "modifier_hp_shift_datadriven_buff_counter", {duration = duration})
					self:GetCaster():SetModifierStackCount( "modifier_hp_shift_datadriven_buff_counter" , fleshheap, stacks + self.stacks )
				end
			elseif fleshheap then
				local stacks = self:GetCaster():GetModifierStackCount( "modifier_hp_shift_datadriven_buff_counter" , fleshheap )
				local duration = fleshheap:GetSpecialValueFor("duration")
				for i=0, self.stacks do
					fleshheap:ApplyDataDrivenModifier(self:GetCaster(), self:GetCaster(), "modifier_hp_shift_datadriven_buff", {duration = duration})
				end
				self:GetCaster():RemoveModifierByName("modifier_hp_shift_datadriven_buff_counter")
				fleshheap:ApplyDataDrivenModifier(self:GetCaster(), self:GetCaster(), "modifier_hp_shift_datadriven_buff_counter", {duration = duration})
				self:GetCaster():SetModifierStackCount( "modifier_hp_shift_datadriven_buff_counter" , fleshheap, stacks + self.stacks )
			end
			self:GetCaster():CalculateStatBonus()
		end
		local flDamage = self.dismember_damage
		flDamage = flDamage + ( self:GetCaster():GetStrength() * self.strength_damage )
		self:GetCaster():HealEvent( flDamage, self:GetAbility(), self:GetCaster() )
		local damage = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = flDamage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility()
		}
		ApplyDamage( damage )
		EmitSoundOn( "Hero_Pudge.Dismember", self:GetParent() )
	end
end

--------------------------------------------------------------------------------

function modifier_pudge_dismember_lua:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_INVISIBLE] = false,
	}

	return state
end

--------------------------------------------------------------------------------

function modifier_pudge_dismember_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_pudge_dismember_lua:GetOverrideAnimation( params )
	return ACT_DOTA_DISABLED
end

------------------------------------------------------------------------------

--------------------------------------------------------------------------------

pudge_rot_lua = class({})
LinkLuaModifier( "modifier_rot_lua", "lua_abilities/heroes/modifiers/modifier_rot_lua.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rot_death_lua", "lua_abilities/heroes/pudge.lua" ,LUA_MODIFIER_MOTION_NONE )

--[[Author: Valve
	Date: 26.09.2015.
	Applies the rot modifier on the caster depending on the toggle state]]
--------------------------------------------------------------------------------

function pudge_rot_lua:ProcsMagicStick()
	return false
end

--------------------------------------------------------------------------------

function pudge_rot_lua:GetIntrinsicModifierName()
	return	"modifier_rot_death_lua"
end

function pudge_rot_lua:OnHeroLevelUp()
	if not self:GetCaster():HasModifier("modifier_rot_death_lua") then
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_rot_death_lua", nil )
	end
end

--------------------------------------------------------------------------------

function pudge_rot_lua:OnToggle()
	-- Apply the rot modifier if the toggle is on
	if self:GetToggleState() then
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_rot_lua", nil )

		if not self:GetCaster():IsChanneling() then
			self:GetCaster():StartGesture( ACT_DOTA_CAST_ABILITY_ROT )
		end
	else
		-- Remove it if it is off
		local hRotBuff = self:GetCaster():FindModifierByName( "modifier_rot_lua" )
		if hRotBuff ~= nil then
			hRotBuff:Destroy()
		end
	end
end

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_rot_death_lua				
--------------------------------------------------------------------------------------------------------
if modifier_rot_death_lua == nil then modifier_rot_death_lua = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_rot_death_lua:IsPassive()
	return true
end

--------------------------------------------------------------------------------------------------------
function modifier_rot_death_lua:IsHidden()
	if self:GetAbility():GetLevel() == 0 then
		return true
	else return false end
end

function modifier_rot_death_lua:IsAura()
	if self:GetCaster():IsRealHero() then
		return true
	else return false end
end

function modifier_rot_death_lua:RemoveOnDeath()
	return false
end

function modifier_rot_death_lua:GetModifierAura()
	return "modifier_rot_death_lua_aura"
end

function modifier_rot_death_lua:GetAuraRadius()
	return 9999
end

function modifier_rot_death_lua:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS
end

function modifier_rot_death_lua:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_rot_death_lua:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL
end

--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

LinkLuaModifier( "modifier_rot_death_lua_aura", "lua_abilities/heroes/pudge.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
--		Aura Modifier: modifier_rot_death_lua_aura		
--------------------------------------------------------------------------------------------------------
if modifier_rot_death_lua_aura == nil then modifier_rot_death_lua_aura = class({}) end

function modifier_rot_death_lua_aura:IsHidden()
	return true
end

function modifier_rot_death_lua_aura:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_DEATH,
  }
  return funcs
end

function modifier_rot_death_lua_aura:OnDeath(params)
	if IsServer() and params.unit:HasModifier("modifier_rot_death_lua_aura") and params.unit:IsCore() and not params.unit.triggered then
		local modifier = self:GetCaster():FindModifierByName("modifier_rot_death_lua")
		modifier:SetStackCount(modifier:GetStackCount() +1)
		params.unit.triggered = true
	end
end

------------------------------------------
------------------------------------------

pudge_meat_hook_ebf = class({})
function pudge_meat_hook_ebf:GetCooldown(nLevel)
	if self:GetCaster():HasScepter() then
		return 4
	else
		return 12
	end
end


function pudge_meat_hook_ebf:GetCustomCastErrorLocation(loc)
	return "Already sent out your hook!"
end
if IsServer() then
	function pudge_meat_hook_ebf:OnAbilityPhaseStart()
		self:GetCaster():StartGesture( ACT_DOTA_OVERRIDE_ABILITY_1 )
		return true
	end

	--------------------------------------------------------------------------------

	function pudge_meat_hook_ebf:OnAbilityPhaseInterrupted()
		self:GetCaster():RemoveGesture( ACT_DOTA_OVERRIDE_ABILITY_1 )
	end

	--------------------------------------------------------------------------------
	function pudge_meat_hook_ebf:CastFilterResultLocation(loc)
		if self.hook_launched then
			return UF_FAIL_CUSTOM
		else
			return UF_SUCCESS
		end
	end
	function pudge_meat_hook_ebf:OnSpellStart()
		local caster = self:GetCaster()
		local ability_level = self:GetLevel() - 1

		-- If another hook is already out, refund mana cost and do nothing
		-- if self.hook_launched then
			-- caster:GiveMana(ability:GetManaCost(ability_level))
			-- ability:EndCooldown()
			-- return nil
		-- end

		-- Set the global hook_launched variable
		self.hook_launched = true
		
		-- Parameters
		local hook_speed = self:GetTalentSpecialValueFor("hook_speed")
		local hook_width = self:GetTalentSpecialValueFor("hook_width")
		local hook_range = self:GetTalentSpecialValueFor("hook_distance") + get_aether_multiplier( caster )
		local hook_damage = self:GetTalentSpecialValueFor("hook_damage")
		local hook_damage_scepter = self:GetTalentSpecialValueFor("damage_scepter")
		local enemy_disable_linger = self:GetTalentSpecialValueFor("enemy_disable_linger")
		local caster_loc = caster:GetAbsOrigin()
		local start_loc = caster_loc + ((self:GetCursorPosition() - caster_loc) * Vector(1,1,0)):Normalized() * hook_width

		-- Prevent Pudge from using tps while the hook is out
		local flFollowthroughDuration = ( hook_range / hook_speed * 0.75 )
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_meat_hook_followthrough_lua", {duration = flFollowthroughDuration})

		-- Play Hook launch sound
		caster:EmitSound("Hero_Pudge.AttackHookExtend")

		-- Create and set up the Hook dummy unit
		local hook_dummy = CreateUnitByName("npc_dummy_blank", start_loc + Vector(0, 0, 150), false, caster, caster, caster:GetTeam())
		hook_dummy:AddAbility("hide_hero"):SetLevel(1)
		hook_dummy:SetForwardVector(caster:GetForwardVector())
		
		-- Attach the Hook particle
		local hook_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_meathook_chain.vpcf", PATTACH_RENDERORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleAlwaysSimulate(hook_pfx)
		ParticleManager:SetParticleControlEnt(hook_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", caster_loc, true)
		ParticleManager:SetParticleControl(hook_pfx, 1, start_loc)
		ParticleManager:SetParticleControl(hook_pfx, 2, Vector(hook_speed, hook_range, hook_width) )
		ParticleManager:SetParticleControl(hook_pfx, 6, start_loc)
		ParticleManager:SetParticleControlEnt(hook_pfx, 6, hook_dummy, PATTACH_POINT_FOLLOW, "attach_overhead", start_loc, false)
		ParticleManager:SetParticleControlEnt(hook_pfx, 7, caster, PATTACH_CUSTOMORIGIN, nil, caster_loc, true)

		-- Remove the caster's hook
		local weapon_hook
		if caster:IsHero() then
			weapon_hook = caster:GetTogglableWearable( DOTA_LOADOUT_TYPE_WEAPON )
			if weapon_hook ~= nil then
				weapon_hook:AddEffects( EF_NODRAW )
			end
		end

		-- Initialize Hook variables
		local hook_loc = start_loc
		local tick_rate = 0.03
		hook_speed = hook_speed * tick_rate

		local travel_distance = (hook_loc - caster_loc):Length2D()
		local hook_step = ((self:GetCursorPosition() - caster_loc) * Vector(1,1,0)):Normalized() * hook_speed

		local target_hit = false
		local target

		-- Main Hook loop
		Timers:CreateTimer(tick_rate, function()

			-- Check for valid units in the area
			local units = FindUnitsInRadius(caster:GetTeamNumber(), hook_loc, nil, hook_width, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_CLOSEST, false)
			for _,unit in pairs(units) do
				if unit ~= caster and unit ~= hook_dummy then
					target_hit = true
					target = unit
					break
				end
			end

			-- If a valid target was hit, start dragging them
			if target_hit then

				-- Apply stun/root modifier, and damage if the target is an enemy
				if caster:GetTeam() ~= target:GetTeam() then
					ApplyDamage({attacker = caster, victim = target, ability = ability, damage = hook_damage, damage_type = DAMAGE_TYPE_PURE})
					caster:ModifyThreat(40)
				else
					target:ModifyThreat(self:GetTalentSpecialValueFor("threat_reduction"))
				end

				-- Play the hit sound and particle
				target:EmitSound("Hero_Pudge.AttackHookImpact")
				local hook_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_meathook_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)

				-- Increase hook return speed
				-- hook_speed = math.max(hook_speed, 3000 * tick_rate)
			elseif travel_distance < hook_range then

				-- Move the hook
				hook_dummy:SetAbsOrigin(hook_loc + hook_step)

				-- Recalculate position and distance
				hook_loc = hook_dummy:GetAbsOrigin()
				travel_distance = (hook_loc - caster_loc):Length2D()
				return tick_rate
			end

			-- If no target was hit and the maximum range is not reached, move the hook and keep going
			

			-- If we are here, this means the hook has to start reeling back; prepare return variables
			local direction = ( caster_loc - hook_loc )
			local current_tick = 0

			-- Stop the extending sound and start playing the return sound
			caster:StopSound("Hero_Pudge.AttackHookExtend")
			caster:EmitSound("Hero_Pudge.AttackHookRetract")

			-- Remove the caster's self-stun if it hasn't run out yet
			caster:RemoveModifierByName("modifier_meat_hook_followthrough_lua")

			-- Play sound reaction according to which target was hit
			if target_hit and target:IsRealHero() and target:GetTeam() ~= caster:GetTeam() then
				caster:EmitSound("pudge_pud_ability_hook_0"..RandomInt(1,9))
			elseif target_hit and target:IsRealHero() and target:GetTeam() == caster:GetTeam() then
				caster:EmitSound("pudge_pud_ability_hook_miss_01")
			elseif target_hit then
				caster:EmitSound("pudge_pud_ability_hook_miss_0"..RandomInt(2,6))
			else
				caster:EmitSound("pudge_pud_ability_hook_miss_0"..RandomInt(8,9))
			end

			-- Hook reeling loop
			Timers:CreateTimer(tick_rate, function()

				-- Recalculate position variables
				caster_loc = caster:GetAbsOrigin()
				hook_loc = hook_dummy:GetAbsOrigin()
				direction = ( caster_loc - hook_loc )
				hook_step = direction:Normalized() * hook_speed
				current_tick = current_tick + 1
				
				-- If the target is close enough, or the hook has been out too long, finalize the hook return
				if direction:Length2D() < hook_speed or current_tick > 300 then

					-- Stop moving the target
					if target_hit then
						local final_loc = caster_loc + caster:GetForwardVector() * 100
						FindClearSpaceForUnit(target, final_loc, false)

						-- Remove the target's modifiers
						target:RemoveModifierByName("modifier_meat_hook_lua")
					end

					-- Destroy the hook dummy and particles
					hook_dummy:Destroy()
					ParticleManager:DestroyParticle(hook_pfx, false)
					ParticleManager:ReleaseParticleIndex(hook_pfx)

					-- Stop playing the reeling sound
					caster:StopSound("Hero_Pudge.AttackHookRetract")
					caster:EmitSound("Hero_Pudge.AttackHookRetractStop")

					-- Give back the caster's hook
					if weapon_hook ~= nil then
						weapon_hook:RemoveEffects( EF_NODRAW )
					end

					-- Clear global variables
					self.hook_launched = false

				-- If this is not the final step, keep reeling the hook in
				else

					-- Move the hook and an eventual target
					hook_dummy:SetAbsOrigin(hook_loc + hook_step)
					ParticleManager:SetParticleControl(hook_pfx, 6, hook_loc + hook_step + Vector(0, 0, 90))

					if target_hit then
						target:SetAbsOrigin(hook_loc + hook_step)
						target:SetForwardVector(direction:Normalized())
					end
					
					return tick_rate
				end
			end)
		end)
	end
end

LinkLuaModifier( "modifier_meat_hook_lua", "lua_abilities/heroes/modifiers/pudge.lua" ,LUA_MODIFIER_MOTION_NONE )

modifier_meat_hook_lua = class({})
--------------------------------------------------------------------------------

function modifier_meat_hook_lua:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_meat_hook_lua:IsStunDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_meat_hook_lua:RemoveOnDeath()
	return false
end

--------------------------------------------------------------------------------

function modifier_meat_hook_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_meat_hook_lua:GetOverrideAnimation( params )
	return ACT_DOTA_FLAIL
end

--------------------------------------------------------------------------------

function modifier_meat_hook_lua:CheckState()
	if IsServer() then
		if self:GetCaster() ~= nil and self:GetParent() ~= nil then
			if self:GetCaster():GetTeamNumber() ~= self:GetParent():GetTeamNumber() and ( not self:GetParent():IsMagicImmune() ) then
				local state = {
				[MODIFIER_STATE_STUNNED] = true,
				}

				return state
			else
				local state = {
				[MODIFIER_STATE_ROOTED] = true,
				}

				return state
			end
		end
	end
end


LinkLuaModifier( "modifier_meat_hook_followthrough_lua", "lua_abilities/heroes/pudge.lua" ,LUA_MODIFIER_MOTION_NONE )

modifier_meat_hook_followthrough_lua = class({})

--------------------------------------------------------------------------------

function modifier_meat_hook_followthrough_lua:IsHidden()
	return true
end

function modifier_meat_hook_followthrough_lua:OnDestroy()
	if IsServer() then
		self:GetCaster():RemoveGesture( ACT_DOTA_OVERRIDE_ABILITY_1 )
	end
end

--------------------------------------------------------------------------------

function modifier_meat_hook_followthrough_lua:CheckState()
	local state = {
	[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

--------------------------------------------------------------------------------