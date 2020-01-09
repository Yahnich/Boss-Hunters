juggernaut_dance_of_blades = class({})

function juggernaut_dance_of_blades:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local momentum = 0
	if caster.GetMomentum then
		momentum = caster:GetMomentum()
	end
	local duration = self:GetTalentSpecialValueFor("duration") + momentum * self:GetTalentSpecialValueFor("bonus_duration")
	local ogBounces = bounces
	if caster.SetMomentum then
		caster:SetMomentum(0)
	end
	
	
	local radius = self:GetTalentSpecialValueFor("radius")
	local rate = self:GetTalentSpecialValueFor("bounce_rate") / 100
	local tick = caster:GetSecondsPerAttack() / rate
	caster:AddNewModifier(caster, self, "modifier_juggernaut_dance_of_blades", {duration = duration + 0.1})
	Timers:CreateTimer(function()
		if not caster:HasModifier("modifier_juggernaut_dance_of_blades") then return end
		tick = caster:GetSecondsPerAttack() / rate
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), radius) ) do
			target = enemy
			break
		end
		if not target or target:IsNull() or not target:IsAlive() then
			return caster:RemoveModifierByName("modifier_juggernaut_dance_of_blades") 
		end
		self:Bounce(target)
		return tick
	end)
end

function juggernaut_dance_of_blades:Bounce(target)
	local caster = self:GetCaster()
	
	if not target:TriggerSpellAbsorb( self ) then
		caster:PerformGenericAttack(target, true)
	end
	ParticleManager:FireParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_tgt.vpcf", PATTACH_POINT_FOLLOW, caster, {[0]=caster:GetAbsOrigin(), [1]=target:GetAbsOrigin()})
	ParticleManager:FireParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_trail.vpcf", PATTACH_POINT, caster, {[0]="attach_hitloc", [1]=target:GetAbsOrigin()})
	ParticleManager:FireParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_jugg.vpcf", PATTACH_POINT, caster, {[0]=target:GetAbsOrigin(), [1]=target:GetAbsOrigin()})
	EmitSoundOn("Hero_Juggernaut.OmniSlash", caster)
	EmitSoundOn("Hero_Juggernaut.OmniSlash.Damage", caster)
	
	local direction = CalculateDirection(target, caster)
	local distance = CalculateDistance(target, caster)
	caster:SetAbsOrigin( target:GetAbsOrigin() + direction * RandomInt(150, caster:GetAttackRange()) )
	caster:SetForwardVector( CalculateDirection(target, caster) )
end

modifier_juggernaut_dance_of_blades = class({})
LinkLuaModifier("modifier_juggernaut_dance_of_blades", "heroes/hero_juggernaut/juggernaut_dance_of_blades", LUA_MODIFIER_MOTION_NONE)


function modifier_juggernaut_dance_of_blades:OnCreated()
	local caster = self:GetCaster()
	self.bonus_damage = self:GetTalentSpecialValueFor("bonus_damage")
	self.talent_damage = self:GetCaster():FindTalentValue("special_bonus_unique_juggernaut_dance_of_blades_1")
	if IsServer() then
		caster:RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
		local rate = self:GetTalentSpecialValueFor("bounce_rate") / 100
		local tick = caster:GetSecondsPerAttack() / rate
		caster:StartGestureWithPlaybackRate(ACT_DOTA_OVERRIDE_ABILITY_4, 1/tick)
	end
end
function modifier_juggernaut_dance_of_blades:OnDestroy()
	local caster = self:GetCaster()
	if IsServer() then
		caster:RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_4)
		if caster:HasModifier("modifier_juggernaut_mirror_blades") then
			caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
		end
	end
end

function modifier_juggernaut_dance_of_blades:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE}
end

function modifier_juggernaut_dance_of_blades:GetModifierPreAttack_BonusDamage()
	return self.bonus_damage
end

function modifier_juggernaut_dance_of_blades:GetModifierBaseDamageOutgoing_Percentage()
	return self.talent_damage
end

function modifier_juggernaut_dance_of_blades:CheckState()
	return {[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_UNSELECTABLE] = true,
			[MODIFIER_STATE_ROOTED] = true,
			[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
			[MODIFIER_STATE_NO_HEALTH_BAR] = true,
			[MODIFIER_STATE_FLYING] = true,
			[MODIFIER_STATE_NO_TEAM_MOVE_TO] = true,
			[MODIFIER_STATE_NO_TEAM_SELECT] = true,
			[MODIFIER_STATE_DISARMED] = true,}
end

function modifier_juggernaut_dance_of_blades:GetStatusEffectName()
	return "particles/status_fx/status_effect_omnislash.vpcf"
end

function modifier_juggernaut_dance_of_blades:StatusEffectPriority()
	return 20
end