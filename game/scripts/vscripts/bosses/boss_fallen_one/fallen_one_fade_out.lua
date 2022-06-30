fallen_one_fade_out = class({})

function fallen_one_fade_out:OnAbilityPhaseStart()
	ParticleManager:FireTargetWarningParticle( self:GetCursorTarget() )
	return true
end

function fallen_one_fade_out:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	caster:EmitSound("Hero_VengefulSpirit.NetherSwap")
	if target:TriggerSpellAbsorb( self ) then return end
	local duration = self:GetSpecialValueFor("illu_duration")
	
	local illusions = target:ConjureImage( {outgoing_damage = self:GetSpecialValueFor("illu_out") - 100, incoming_damage = self:GetSpecialValueFor("illu_inc") - 100, position = caster:GetAbsOrigin(), ability = self, controllable = true}, duration, caster, 1 )
	local invuln = caster:AddNewModifier(caster, self, "modifier_fallen_one_fade_out", {duration = duration})
	illusions[1]:MoveToPositionAggressive( target:GetAbsOrigin() )
	illusions[1]:SetForceAttackTarget( target )
	Timers:CreateTimer(function()
		if not illusions or not illusions[1] or illusions[1]:IsNull() or not illusions[1]:IsAlive() then
			if invuln and not invuln:IsNull() then
				invuln:Destroy()
			end
			return nil
		end
		if not (illusions[1]:IsMoving() or illusions[1]:IsAttacking()) then
			illusions[1]:MoveToPositionAggressive( target:GetAbsOrigin() )
		end
		caster:SetAbsOrigin( illusions[1]:GetAbsOrigin() )
		ResolveNPCPositions( illusions[1]:GetAbsOrigin(), 32 )
		return 0.1
	end)
end

modifier_fallen_one_fade_out = class({})
LinkLuaModifier("modifier_fallen_one_fade_out", "bosses/boss_fallen_one/fallen_one_fade_out", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_fallen_one_fade_out:OnCreated()
		self:GetParent():AddNoDraw( ) 
	end
	
	function modifier_fallen_one_fade_out:OnDestroy()
		self:GetParent():StartGesture( ACT_DOTA_CHANNEL_END_ABILITY_4 )
		self:GetParent():RemoveNoDraw( )
	end
end

function modifier_fallen_one_fade_out:CheckState()
	return {[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_INVISIBLE] = true,
			[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_UNSELECTABLE] = true,
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
			[MODIFIER_STATE_NO_HEALTH_BAR] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_UNTARGETABLE] = true,}
end

function modifier_fallen_one_fade_out:IsHidden()
	return true
end