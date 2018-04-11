pudge_hook_lua = class({})
LinkLuaModifier( "modifier_meat_hook_lua", "heroes/hero_pudge/pudge_hook_lua.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_meat_hook_followthrough_lua", "heroes/hero_pudge/pudge_hook_lua.lua" ,LUA_MODIFIER_MOTION_NONE )

function pudge_hook_lua:GetCustomCastErrorLocation(loc)
	return "Already sent out your hook!"
end

function pudge_hook_lua:OnAbilityPhaseStart()
	self:GetCaster():StartGesture( ACT_DOTA_OVERRIDE_ABILITY_1 )
	return true
end

function pudge_hook_lua:OnAbilityPhaseInterrupted()
	self:GetCaster():RemoveGesture( ACT_DOTA_OVERRIDE_ABILITY_1 )
end

function pudge_hook_lua:CastFilterResultLocation(loc)
	if self.hook_launched then
		return UF_FAIL_CUSTOM
	else
		return UF_SUCCESS
	end
end

function pudge_hook_lua:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
	if self:GetCaster():HasScepter() then cooldown = self:GetTalentSpecialValueFor("scepter_cooldown") end
    if self:GetCaster():HasTalent("special_bonus_unique_pudge_hook_lua_2") then cooldown = cooldown * self:GetCaster():FindTalentValue("special_bonus_unique_pudge_hook_lua_2", "cdr") end
    return cooldown
end

function pudge_hook_lua:OnSpellStart()
	local caster = self:GetCaster()

	-- If another hook is already out, refund mana cost and do nothing
	if self.hook_launched then
		caster:GiveMana(self:GetManaCost(self:GetLevel()))
		self:EndCooldown()
		return nil
	end

	-- Set the global hook_launched variable
	self.hook_launched = true
	
	-- Parameters
	local hook_speed = self:GetTalentSpecialValueFor("speed")
	local hook_width = self:GetTalentSpecialValueFor("width")
	local hook_range = self:GetTrueCastRange()
	local hook_damage = self:GetTalentSpecialValueFor("damage")
	if caster:HasScepter() then hook_damage = self:GetTalentSpecialValueFor("scepter_damage") end
	local caster_loc = caster:GetAbsOrigin()
	local direction = CalculateDirection(self:GetCursorPosition(), caster_loc)
	local start_loc = GetGroundPosition(caster_loc + direction * hook_width, caster) + Vector(0,0,100)

	-- Prevent Pudge from using tps while the hook is out
	local flFollowthroughDuration = ( hook_range / hook_speed * 0.75 )
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_meat_hook_followthrough_lua", {duration = flFollowthroughDuration})

	-- Play Hook launch sound
	EmitSoundOn("Hero_Pudge.AttackHookExtend", caster)

	-- Create and set up the Hook dummy unit
	local hook_dummy = CreateUnitByName("npc_dummy_blank", start_loc + Vector(0, 0, 100), false, caster, caster, caster:GetTeam())
	hook_dummy:AddAbility("hide_hero"):SetLevel(1)
	hook_dummy:SetForwardVector(caster:GetForwardVector())
	hook_dummy:SetDayTimeVisionRange(hook_width*4)
	hook_dummy:SetNightTimeVisionRange(hook_width*4)
	
	-- Attach the Hook particle
	local hook_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_meathook.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleAlwaysSimulate(hook_pfx)
	ParticleManager:SetParticleControlEnt(hook_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", caster_loc, true)
	ParticleManager:SetParticleControl(hook_pfx, 1, start_loc)
	ParticleManager:SetParticleControl(hook_pfx, 2, Vector(hook_speed, hook_range, hook_width))
	ParticleManager:SetParticleControl(hook_pfx, 3, Vector(hook_range/hook_speed*5, 0, 0))
	ParticleManager:SetParticleControl(hook_pfx, 6, start_loc)
	--why the fuck does this cp work, is not even on the the particle
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

	local travel_distance = CalculateDistance(hook_loc, caster_loc)
	local hook_step = direction * hook_speed

	local target_hit = false
	local target

	-- Main Hook loop
	Timers:CreateTimer(0, function()
		-- Check for valid units in the area
		local units = caster:FindAllUnitsInRadius(hook_loc,hook_width, {flag=DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_INVULNERABLE, order=FIND_CLOSEST})
		for _,unit in pairs(units) do
			if unit ~= caster and unit ~= hook_dummy then
				if unit:GetTeam() ~= caster:GetTeam() or caster:HasTalent("special_bonus_unique_pudge_hook_lua_1") then
					EmitSoundOn("Hero_Pudge.AttackHookImpact", unit)
					target_hit = true
					target = unit
					break
				end
			end
		end

		-- If a valid target was hit, start dragging them
		if target_hit then

			-- Apply stun/root modifier, and damage if the target is an enemy
			if caster:GetTeam() ~= target:GetTeam() then
				self:DealDamage(caster, target, hook_damage, {}, OVERHEAD_ALERT_DAMAGE)
				target:AddNewModifier(caster, self, "modifier_meat_hook_lua", {})
				caster:ModifyThreat(self:GetTalentSpecialValueFor("threat_gain"))
			else
				caster:ModifyThreat(target:GetThreat())
				target:SetThreat(0)
			end

			-- Play the hit sound and particle
			target:EmitSound("Hero_Pudge.AttackHookImpact")
			ParticleManager:FireParticle("particles/units/heroes/hero_pudge/pudge_meathook_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster, {[0]=target:GetAbsOrigin()})

		elseif travel_distance < hook_range then
			ParticleManager:SetParticleControl(hook_pfx, 1, hook_loc + hook_step)
			ParticleManager:SetParticleControl(hook_pfx, 6, hook_loc + hook_step)

			-- Move the hook
			hook_dummy:SetAbsOrigin(hook_loc + hook_step)

			-- Recalculate position and distance
			hook_loc = GetGroundPosition(hook_dummy:GetAbsOrigin(), hook_dummy)  + Vector(0,0,100)
			travel_distance = (hook_loc - caster_loc):Length2D()
			return tick_rate
		end

		-- If we are here, this means the hook has to start reeling back; prepare return variables
		local direction = ( caster_loc - hook_loc )
		local current_tick = 0

		-- Stop the extending sound and start playing the return sound
		StopSoundOn("Hero_Pudge.AttackHookExtend", caster)
		EmitSoundOn("Hero_Pudge.AttackHookRetract", caster)
		

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
		Timers:CreateTimer(0, function()

			-- Recalculate position variables
			caster_loc = caster:GetAbsOrigin()
			hook_loc = GetGroundPosition(hook_dummy:GetAbsOrigin(), hook_dummy) + Vector(0,0,100)
			direction = ( caster_loc - hook_loc )
			hook_step = direction:Normalized() * hook_speed
			current_tick = current_tick + 1
			
			-- If the target is close enough, or the hook has been out too long, finalize the hook return
			if direction:Length2D() < hook_speed or current_tick > 300 then

				-- Stop moving the target
				if target_hit then
					local final_loc = caster_loc + caster:GetForwardVector() * 100
					FindClearSpaceForUnit(target, target:GetAbsOrigin(), false)

					local angles = target:GetAnglesAsVector()
					target:SetAngles(0, angles.y, 0)
					-- Remove the target's modifiers
					target:RemoveModifierByName("modifier_meat_hook_lua")
				end

				-- Destroy the hook dummy and particles
				hook_dummy:Destroy()
				ParticleManager:DestroyParticle(hook_pfx, false)
				ParticleManager:ReleaseParticleIndex(hook_pfx)

				-- Stop playing the reeling sound
				StopSoundOn("Hero_Pudge.AttackHookRetract", caster)
				EmitSoundOn("Hero_Pudge.AttackHookRetractStop", caster)

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
				ParticleManager:SetParticleControl(hook_pfx, 1, hook_loc + hook_step)
				ParticleManager:SetParticleControl(hook_pfx, 6, hook_loc + hook_step)

				if target_hit then
					target:SetAbsOrigin(hook_dummy:GetAbsOrigin()-Vector(0,0,100))
					target:SetForwardVector(direction:Normalized())
				end
				
				return tick_rate
			end
		end)
	end)
end

modifier_meat_hook_lua = class({})

function modifier_meat_hook_lua:OnCreated(table)
	if IsServer() then self:StartIntervalThink(FrameTime()) end
end

function modifier_meat_hook_lua:OnIntervalThink()
	if IsServer() then
		self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self:GetTalentSpecialValueFor("damage")*FrameTime(), {}, 0)
	end
end

function modifier_meat_hook_lua:IsDebuff()
	return true
end

function modifier_meat_hook_lua:IsStunDebuff()
	return true
end

function modifier_meat_hook_lua:RemoveOnDeath()
	return false
end

function modifier_meat_hook_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_meat_hook_lua:GetOverrideAnimation( params )
	return ACT_DOTA_FLAIL
end

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

--function modifier_meat_hook_lua:IsHidden()
	--return true
--end

modifier_meat_hook_followthrough_lua = class({})

function modifier_meat_hook_followthrough_lua:IsHidden()
	return true
end

function modifier_meat_hook_followthrough_lua:OnDestroy()
	if IsServer() then
		self:GetCaster():RemoveGesture( ACT_DOTA_OVERRIDE_ABILITY_1 )
		self:GetCaster():StartGesture(ACT_DOTA_CHANNEL_ABILITY_1)
	end
end

function modifier_meat_hook_followthrough_lua:CheckState()
	local state = {
	[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end