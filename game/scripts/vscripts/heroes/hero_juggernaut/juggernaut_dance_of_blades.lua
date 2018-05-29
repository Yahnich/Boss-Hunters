juggernaut_dance_of_blades = class({})

function juggernaut_dance_of_blades:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local talent = caster:HasTalent("special_bonus_unique_juggernaut_dance_of_blades_1")
	local bounces = self:GetTalentSpecialValueFor("jumps") + caster:GetMomentum()
	local ogBounces = bounces
	caster:SetMomentum(0)
	
	
	local radius = self:GetTalentSpecialValueFor("radius")
	local tick = self:GetTalentSpecialValueFor("bounce_tick")
	caster:AddNewModifier(caster, self, "modifier_juggernaut_dance_of_blades", {duration = bounces * tick + 0.1})
	Timers:CreateTimer(function()
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), radius) ) do
			target = enemy
			break
		end
		if not target or target:IsNull() or not target:IsAlive() then
			local cd = self:GetCooldownTimeRemaining()
			self:EndCooldown()
			self:StartCooldown( cd * (1 - ( bounces / ogBounces)) )
			return caster:RemoveModifierByName("modifier_juggernaut_dance_of_blades") 
		end
		self:Bounce(target)
		bounces = bounces - 1
		if bounces > 0 then
			return tick
		else
			caster:RemoveModifierByName("modifier_juggernaut_dance_of_blades")
		end
	end)
end

function juggernaut_dance_of_blades:Bounce(target)
	local caster = self:GetCaster()
	local damage = self:GetTalentSpecialValueFor("omni_slash_damage")
	
	if talent then
		caster:PerformGenericAttack(target, true, 0, 100)
	else
		self:DealDamage( caster, target, damage )
	end
	if not target then
		caster:RemoveModifierByName("modifier_juggernaut_dance_of_blades")
		return
	end
	
	ParticleManager:FireParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_tgt.vpcf", PATTACH_POINT_FOLLOW, caster, {[0]=caster:GetAbsOrigin(), [1]=target:GetAbsOrigin()})
	ParticleManager:FireParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_trail.vpcf", PATTACH_POINT, caster, {[0]="attach_hitloc", [1]=target:GetAbsOrigin()})
	ParticleManager:FireParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_jugg.vpcf", PATTACH_POINT, caster, {[0]=target:GetAbsOrigin(), [1]=target:GetAbsOrigin()})
	EmitSoundOn("Hero_Juggernaut.OmniSlash", caster)
	EmitSoundOn("Hero_Juggernaut.OmniSlash.Damage", caster)
	
	caster:SetAbsOrigin( target:GetAbsOrigin() + RandomVector(caster:GetAttackRange()) )
	caster:SetForwardVector( CalculateDirection(target, caster) )
	order = 
		{
			UnitIndex = caster:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = target:entindex(),
			AbilityIndex = ability,
			Queue = true
		}
	ExecuteOrderFromTable(order)
end

modifier_juggernaut_dance_of_blades = class({})
LinkLuaModifier("modifier_juggernaut_dance_of_blades", "heroes/hero_juggernaut/juggernaut_dance_of_blades", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_juggernaut_dance_of_blades:OnCreated()
		local caster = self:GetCaster()
		caster:RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
		caster:StartGestureWithPlaybackRate(ACT_DOTA_OVERRIDE_ABILITY_4, 1/self:GetTalentSpecialValueFor("bounce_tick"))
	end
	function modifier_juggernaut_dance_of_blades:OnDestroy()
		local caster = self:GetCaster()
		caster:RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_4)
		if caster:HasModifier("modifier_juggernaut_mirror_blades") then
			caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
		end
	end
end

function modifier_juggernaut_dance_of_blades:GetStatusEffectName()
	return "particles/status_fx/status_effect_omnislash.vpcf"
end

function modifier_juggernaut_dance_of_blades:StatusEffectPriority()
	return 20
end

function modifier_juggernaut_dance_of_blades:CheckState()
	return {[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_UNSELECTABLE] = true,
			[MODIFIER_STATE_ROOTED] = true,
			[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
			[MODIFIER_STATE_NO_HEALTH_BAR] = true,
			[MODIFIER_STATE_FLYING] = true,
			[MODIFIER_STATE_NO_TEAM_MOVE_TO] = true,
			[MODIFIER_STATE_NO_TEAM_SELECT] = true,}
end