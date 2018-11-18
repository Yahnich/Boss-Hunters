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
	
	local callback = (function( illusion, parent, caster, ability )
		illusion.hasBeenInitialized = true
		Timers:CreateTimer(0.5, function()
			illusion:MoveToPositionAggressive( parent:GetAbsOrigin() )
			caster:SetAbsOrigin( illusion:GetAbsOrigin() )
			if not illusion or illusion:IsNull() or not illusion:IsAlive() and invuln then
				invuln:Destroy()
			end
		end)
	end)
	
	local illusion = target:ConjureImage( caster:GetAbsOrigin(), duration, self:GetSpecialValueFor("illu_out") - 100, self:GetSpecialValueFor("illu_inc") - 100, nil, self, false, callback )
	local invuln = caster:AddNewModifier(caster, self, "modifier_fallen_one_fade_out", {duration = duration})
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